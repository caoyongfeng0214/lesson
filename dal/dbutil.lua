--[[
	对mysql操作的CRUD、包含分页,统计等常用 SQL 操作
]]
NPL.load("(gl)script/ide/commonlib.lua");
local dbcfg = NPL.load('../confi/dbConfi');
local mysql = NPL.load('mysql'):new({
    db = dbcfg.db,
    user = dbcfg.user,
    pwd = dbcfg.pwd,
    host = dbcfg.host,
});

local showSql = false;  -- 是否打印 SQL 开关
local lastSqlString = "";  -- 记录被执行的最后一条 SQL
local beforeWhereString = ""; -- where 子句的前置条件

local dbutil = {};

-- cn 参数是可选的
-- 执行一条带参数的非查询sql，返回受影响的行数和新插入数据的id
-- 关闭连接，如果在执行时传递了cn参数，则不会关闭连接
-- return cnt, lastId
-- 若失败，cnt为nil
dbutil.execute = function (sql, sqlParams, cn)
	lastSqlString = sql;
	dbutil.showSqlStr();
	return mysql:execNonQuery(sql,sqlParams,cn);
end

dbutil.execScalar = function (sql, sqlParams, cn)
	lastSqlString = sql;
	dbutil.showSqlStr();
	return mysql:execScalar(sql, sqlParams, cn);
end

-- 在事务中执行。
-- 第一个参数是包含在事务中执行的语句的function，该function会接收两个参数：
--		cn, returnTrans
--		第二个参数 returnTrans 是一个function，当数据操作完毕后，需要调此function通知事务程序已经执行完毕事务了，
--			此function可接收两个参数，
--				第一个参数为true或false，当为true时，事务将提交，否则回滚。
--				第二个参数是可选的，如果希望在回调中
-- eg:
-- 事务中必须带上cn 否则 第一个方法中的 sql 执行非处于一个原子性操作中
-- lecture_question.trans = function(obj)
--     local issucc;
--     db.execInTrans(function(cn, returnTrans)
--         local num1 = db.updateNumberBatch(tbl,{wrong_times = "wrong_times + 1"},obj,cn);
--         local num2 = db.updateNumberBatch(tbl,{right_times = "right_times + 1"},obj,cn);
--         if num1 == nil or num2 == nil then
-- 			returnTrans(false);
-- 		else
-- 			returnTrans(true);
--         end 
--     end,function(issuccess, result) 
--         issucc = issuccess;
--     end
--     );
--     return issucc;
-- end
dbutil.execInTrans = function(execFun, callbackFun)
	return mysql:execInTrans(execFun, callbackFun);
end

-- cn 参数是可选的
-- 执行一条带参数的查询sql，
-- 不关闭连接，连接对象会作为第一个数据返回
-- return cn, rows
dbutil.queryAll = function(sql, sqlParams, cn)
	lastSqlString = sql;
	dbutil.showSqlStr();
	return mysql:execRows(sql,sqlParams,cn);
end


-- cn 参数是可选的
-- 执行一条带参数的查询sql，返回查询到的第一条数据，
-- 不关闭连接，连接对象会作为第一个数返回
-- modestring: 'n' or 'a'，默认 'a'
-- return cn, row
dbutil.queryFirst = function(sql, sqlParams, cn, modestring)
	lastSqlString = sql;
	dbutil.showSqlStr();
	return mysql:execRow(sql, sqlParams, cn, modestring);
end

-- 返回一个 table (这里是指 Lua 里面的 table 类型数据) 里面的元素个数
local function countTable(tbl)
	local count = 0;
	if tbl then
		for i,v in pairs(tbl) do
			count = count + 1;
		end
	end
	return count;
end

-- 按照 keys 的顺序来变里 t
local function pairsByKeys(t, keys)
    local a = {}
    for n in pairs(keys) do a[#a + 1] = t[n] end
    local i = 0
    return function ()
        i = i + 1
        return keys[i], t[keys[i]]
    end
end


-- 插入操作 
-- 	tableName : 表名
--	obj ：插入的对象 table
--	cn ：cn 参数是可选的
-- return 受影响行数 cnt, lastId
dbutil.insert = function(tableName,obj,cn)
	local length = countTable(obj); 
	local index = 0;
	local keys = "";
	local values = "";
	for k, v in pairs(obj) do 
		index = index + 1;
		if(index ~= length) then
			keys = keys..k..",";
			values = values.."?"..k..",";
		else
			keys = keys..k;
			values = values.."?"..k;
		end
	end
	local sql = "insert into "..tableName.." ("..keys..") values ("..values.. ")";
	lastSqlString = sql;
	dbutil.showSqlStr();
	return mysql:execNonQuery(sql,obj,cn);
end

-- 插入或更新
--	tableName: 表名
--	obj: 插入或更新的对象 table
--	cn: cn 参数是可选的
-- return: 受影响行数 cnt
dbutil.upsert = function(tableName, obj, cn)
	local length = countTable(obj);
	local index = 0;
	local keys = "";
	local values = "";
	for k, v in pairs(obj) do 
		index = index + 1;
		if(index ~= length) then
			keys = keys..k..",";
			values = values.."?"..k..",";
		else
			keys = keys..k;
			values = values.."?"..k;
		end
	end
	local sql = "insert into "..tableName.." ("..keys..") values ("..values.. ") ON DUPLICATE KEY UPDATE "..dbutil._parsePlaceholderSet(obj);
	lastSqlString = sql;
	dbutil.showSqlStr();
	return mysql:execNonQuery(sql,obj,cn);
end

-- 根据 条件 查询数据 支持分页
-- args  (where,group,order,limit 子句均为可选参数,可传 nil)
-- 	tableName : 表名
--	where ： 条件
--  group ： 聚合
--  order ： 排序
--  limit ： 分页  
--	cn ：cn 参数是可选的
-- return : 查询的对象集合
dbutil.find = function(tableName,where,group,order,limit,cn)
	local sql = "select * from "..tableName;
	if(where) then
		sql = sql..dbutil.parseWhere(where);
	end
	if(group) then
		sql = sql..dbutil.parseGroup(group);
	end
	if(order) then
		sql = sql..dbutil.parseOrder(order);
	end
	if(limit) then
		-- 做分页的时候需要返回 page 对象 -> 总页数totalPage 总记录数totalCount 索引号  (传过来的参数)页码pageNo 页面大小pageSize
		local page = {};
		page.totalCount = dbutil.count(tableName,where);
		page.pageNo = (limit.pageNo == nil) and 1 or tonumber(limit.pageNo);		-- 默认页号为 1
		page.pageSize = (limit.pageSize == nil) and 20 or tonumber(limit.pageSize);	-- 默认页面大小 20
		page.totalPage = math.floor((page.totalCount - 1)/page.pageSize) + 1; -- math.floor() 向下取整
		echo(page);
		-- 当前页号小于 1 时将页号置为 1
		-- if(page.pageNo < 1) then
		-- 	page.pageNo = 1;
		-- 当前页号大于总页数时将页号置为总页数大小(尾页)
		-- elseif(page.pageNo > page.totalPage) then 
		-- 	page.pageNo = page.totalPage;
		-- end
		sql = sql..dbutil.parseLimit(page);
		lastSqlString = sql;
		dbutil.showSqlStr();
		local data = mysql:execRows(sql,nil,cn);
		return data,page;
	end
	lastSqlString = sql;
	dbutil.showSqlStr();
	return mysql:execRows(sql,nil,cn);
end

-- 根据 条件 级联查询数据 支持分页 准确来说是 sql 查询 只需要传入主要 sql 部分
-- args  (where,group,order,limit 子句均为可选参数,可传 nil)
-- 	sql :  Join 表之前的sql 包含 select [x] from [x] join [x] on [x],这里是为了灵活使用设计成这样
--	where ： 条件
--  group ： 聚合
--  order ： 排序
--  limit ： 分页
--	cn ：cn 参数是可选的
-- return： 查询的对象集合
dbutil.findJoin = function(sql,where,group,order,limit,cn)
	if(where) then
		sql = sql..dbutil.parseWhere(where);
	end
	if(group) then
		sql = sql..dbutil.parseGroup(group);
	end
	if(order) then
		sql = sql..dbutil.parseOrder(order);
	end
	if(limit) then
		-- 做分页的时候需要返回 page 对象 -> 总页数totalPage 总记录数totalCount 索引号  (传过来的参数)页码pageNo 页面大小pageSize
		local page = {};
		page.totalCount = dbutil.countJoin(sql);
		page.pageNo = (limit.pageNo == nil) and 1 or tonumber(limit.pageNo);		-- 默认页号为 1
		page.pageSize = (limit.pageSize == nil) and 20 or tonumber(limit.pageSize);	-- 默认页面大小 20
		page.totalPage = math.floor((page.totalCount - 1)/page.pageSize) + 1; -- math.floor() 向下取整
		echo('<--------------------------------------------------page----------------------------------------------------->')
		echo(page);
		-- 当前页号小于 1 时将页号置为 1
		-- if(page.pageNo < 1) then
		-- 	page.pageNo = 1;
		-- 当前页号大于总页数时将页号置为总页数大小(尾页)
		-- elseif(page.pageNo > page.totalPage) then 
		-- 	page.pageNo = page.totalPage;
		-- end
		sql = sql..dbutil.parseLimit(page);
		lastSqlString = sql;
		dbutil.showSqlStr();
		local data = mysql:execRows(sql,nil,cn);
		return data,page;
	end
	lastSqlString = sql;
	dbutil.showSqlStr();
	return mysql:execRows(sql,nil,cn);
end

-- 查询第一条数据
--	args: tableName 表名 where 条件子句
-- return: 结果集中的第一条数据
dbutil.first = function(tableName, where,group,order,cn)
	local sql = "select * from "..tableName;
	if(where) then
		sql = sql..dbutil.parseWhere(where);
	end
	if(group) then
		sql = sql..dbutil.parseGroup(group);
	end
	if(order) then
		sql = sql..dbutil.parseOrder(order);
	end
	lastSqlString = sql;
	dbutil.showSqlStr();
	return mysql:execRow(sql,nil,cn);
end

-- 查询一条数据的详情 使用 sql 的方式
dbutil.detail = function(sql,where,group,order,cn)
	if(where) then
		sql = sql..dbutil.parseWhere(where);
	end
	if(group) then
		sql = sql..dbutil.parseGroup(group);
	end
	if(order) then
		sql = sql..dbutil.parseOrder(order);
	end
	lastSqlString = sql;
	dbutil.showSqlStr();
	return mysql:execRow(sql,nil,cn);
end

-- 查询在范围内数据
-- 	args: tableName 表名 inCase in 条件子句
-- return：查询的对象集合
dbutil.findIn = function(tableName, inCase,cn)
	local sql = "select * from "..tableName;
	if(inCase) then
		sql = sql..dbutil.parseIn(inCase);
	end
	lastSqlString = sql;
	dbutil.showSqlStr();
	return mysql:execRows(sql,nil,cn);
end

-- 查询在范围内数据
-- 	args: case 字符串 tableName 表名 inCase in 条件子句
-- return：查询的对象集合
dbutil.findCaseIn = function(sql, inCase, cn)
	if(inCase) then
		sql = sql..dbutil.parseInWithQuote(inCase);
	end
	lastSqlString = sql;
	dbutil.showSqlStr();
	return mysql:execRows(sql,nil,cn);
end

-- 查询不在范围内数据
--	args：tableName 表名 notInCase not in 条件子句
-- reutrn:查询的对象结果集
dbutil.findNotIn = function(tableName, notInCase,cn)
	local sql = "select * from "..tableName;
	if(notInCase) then
		sql = sql..dbutil.parseNotIn(notInCase);
	end
	lastSqlString = sql;
	dbutil.showSqlStr();
	return mysql:execRows(sql,nil,cn);
end

-- 根据 Id 查询数据
-- 	tableName : 表名
--	priId ：主键Id 
--	cn ：cn 参数是可选的
-- return 查询的对象
dbutil.findById = function(tableName,priId,cn)
	local sql = "select * from "..tableName.." where id= ?id";
	lastSqlString = sql;
	dbutil.showSqlStr();
	local sqlParams = {id = priId};
	return mysql:execRow(sql, sqlParams,cn);
end

-- 根据 sn 查询数据
-- 	tableName : 表名
--	sn ：主键sn
--	cn ：cn 参数是可选的
-- return 查询的对象
dbutil.findBySn = function(tableName,sn,cn)
	local sql = "select * from "..tableName.." where sn= ?sn";
	lastSqlString = sql;
	dbutil.showSqlStr();
	local sqlParams = {sn = sn};
	return mysql:execRow(sql, sqlParams,cn);
end

-- 更新操作 
--	tableName : 表名
--	obj ： 要修改的对象
--	where ： 更新条件
--	cn ：cn 参数是可选的
-- return 受影响的行数
dbutil.update = function(tableName,obj,where,cn)
	local sql = "update "..tableName..dbutil.parsePlaceholderSet(obj)..dbutil.parseWhere(where);
	lastSqlString = sql;
	dbutil.showSqlStr();
	return mysql:execNonQuery(sql,obj,cn);
end

-- 根据 Id 更新操作
--	tableName : 表名
--	obj ： 要修改的对象
--	cn ：cn 参数是可选的
-- return 受影响的行数
dbutil.updateById = function(tableName,obj,cn)
	local length = countTable(obj);
	local where = {id = obj.id}; 
	obj.id = nil;
	return dbutil.update(tableName,obj,where,cn);
end

-- 根据 sn 更新操作
--	tableName : 表名
--	obj ： 要修改的对象
--	cn ：cn 参数是可选的
-- return 受影响的行数
dbutil.updateBySn = function(tableName,obj,cn)
	local length = countTable(obj);
	local where = {sn = obj.sn}; 
	obj.sn = nil;
	return dbutil.update(tableName,obj,where,cn);
end

-- 根据条件删除
--  tableName : 表名
--  where : 条件
--  cn ：cn 参数是可选的
-- return : 受影响的行数
dbutil.delete = function(tableName,where,cn)
	local sql = "delete from "..tableName..dbutil.parseWhere(where);
	lastSqlString = sql;
	dbutil.showSqlStr();
	return mysql:execNonQuery(sql,nil,cn);
end

-- 按条件批量删除
--  tableName : 表名
--  inCase ： 条件
--  cn : cn 参数是可选的
-- return : 受影响的行数
dbutil.deleteBatch = function(tableName,inCase,cn)
	local sql = "delete from "..tableName..dbutil.parseIn(inCase);
	lastSqlString = sql;
	dbutil.showSqlStr();
	return mysql:execNonQuery(sql,nil,cn);
end

-- 批量添加
--  tableName : 表名
--  fields : 字段  eg:{subject_id,teacher_name}
--  objs :  插入的数据  eg:{{1,'a'},{3,'b'},{4,'c'}}
-- return : 受影响行数
dbutil.addBatch = function(tableName,fields,objs,cn)
	local sql = "insert into "..tableName.." ("..dbutil.parseFields(fields)..") values "..dbutil.parseObjects(objs);
	lastSqlString = sql;
	dbutil.showSqlStr();
	return mysql:execNonQuery(sql,nil,cn);
end

-- 按条件批量更新 (通常用于更新状态值)
--  tableName : 表名
--  inCase : 条件
--  cn ： cn参数是可选的
-- return ： 受影响的行数
dbutil.updateStatusBatch = function(tableName,set,inCase,cn)
	local sql = "update "..tableName..dbutil.parseSet(set)..dbutil.parseIn(inCase);
	lastSqlString = sql;
	dbutil.showSqlStr();
	return mysql:execNonQuery(sql,nil,cn);
end

-- 按条件批量更新 (通常用于更新统计值) set right_times =  right_times + 1
--  tableName : 表名
--  inCase : 条件
--  cn ： cn参数是可选的
-- return ： 受影响的行数
dbutil.updateNumberBatch = function(tableName,set,inCase,cn)
	local sql = "update "..tableName..dbutil.parseSetWithoutQuote(set)..dbutil.parseIn(inCase);
	lastSqlString = sql;
	dbutil.showSqlStr();
	return mysql:execNonQuery(sql,nil,cn);
end

-- 统计 查询数
--  args : tableName 表名 where 条件子句 
-- return : 统计数
dbutil.count = function(tableName,where,cn)
	local sql = "select count(1) from "..tableName;
	if(where) then
		sql = sql..dbutil.parseWhere(where);
	end
	lastSqlString = sql;
	dbutil.showSqlStr();
	return mysql:execScalar(sql);
end

-- 级联统计
-- args : 
-- 	sql :  Join 表之前的sql 包含 select [x] from [x] join [x] on [x],这里是为了灵活使用设计成这样
--	where ： 条件
-- return :  级联查询的记录数
dbutil.countJoin = function(sql,where,cn)
	sql = "SELECT COUNT(1) FROM ( "..sql.." ) a" ; -- 将查询语句作为子句放在 count(1) from 后面相当于统计结果集中的记录数
	if(where) then
		sql = sql..dbutil.parseWhere(where);
	end
	lastSqlString = sql;
	dbutil.showSqlStr();
	return mysql:execScalar(sql);
end

dbutil.setBeforeWhere = function(whereStr)
	beforeWhereString = whereStr;
end

dbutil.cleanBeforeCase = function()
	beforeWhereString = '';
end

-- 解析 where 子句
-- 	obj ： where 条件 table(k-v) 支持取等于条件、取反、大于、小于 eg: { user_name = "xiaoping112222151554",sex ="男"} where['!h.status'] = 1; where['>price'] = 5; where['<price'] = 100;
-- return where 子句字符串
dbutil.parseWhere = function(obj)
	local length = countTable(obj);
	local index = 0;
	local where = "";
	if(string.len(beforeWhereString) > 0) then
		where = beforeWhereString;
		if(obj ~= nil and length > 0) then
			where = where..' AND ';
		end
	end
	if((length == nil or length == 0) and where == "") then
		return '';
	end 
	
	for k, v in pairs(obj) do 
		index = index + 1;
		if(index ~= length) then
			if( k:startsWith('!') ) then
				where = where..k:replace('!', '').." != '"..v.."' and ";
			elseif( k:startsWith('>=') ) then
				where = where..k:replace('>=','').." >= '"..v.."' and ";
			elseif( k:startsWith('<=') ) then
				where = where..k:replace('<=','').." <= '"..v.."' and ";
			elseif( k:startsWith('>') ) then
				where = where..k:replace('>','').." > '"..v.."' and ";
			elseif( k:startsWith('<') ) then
				where = where..k:replace('<','').." < '"..v.."' and ";
			elseif( k:startsWith('~') ) then
				where = where..k:replace('~','').." like '"..v.."' and ";
			else
				where = where..k.." = '"..v.."' and ";
			end
		else
			if( k:startsWith('!') ) then
				where = where..k:replace('!', '').." != '"..v.."'";
			elseif( k:startsWith('>=') ) then
				where = where..k:replace('>=','').." >= '"..v.."'";
			elseif( k:startsWith('<=') ) then
				where = where..k:replace('<=','').." <= '"..v.."'";
			elseif( k:startsWith('>') ) then
				where = where..k:replace('>','').." > '"..v.."'";
			elseif( k:startsWith('<') ) then
				where = where..k:replace('<','').." < '"..v.."'";
			elseif( k:startsWith('~') ) then
				where = where..k:replace('~','').." like '"..v.."'";
			else
				where = where..k.." = '"..v.."'";
			end
		end
	end
	return " where "..where;
end

-- 解析 set 子句 (用于更新语句 - 无特殊符号的更新)
--  obj ： 更新项 table(k-v)  返回结果带引号
-- return set 子句字符串
dbutil.parseSet = function(obj)
	local length = countTable(obj);
	local index = 0;
	local set = "";
	for k, v in pairs(obj) do 
		index = index + 1;
		if(index ~= length) then
			set = set..k.." = '"..v.."' , ";
		else
			set = set..k.." = '"..v.."'";
		end
	end
	return " set "..set;
end

-- 解析 set 子句 (占位符的方式) 推荐写操作都使用占位符方式
--  obj : 更新项 table(k-v) 返回结果为占位符形式 set id = ?id 
-- return set 子句字符串
dbutil.parsePlaceholderSet = function(obj)
	return " set "..dbutil._parsePlaceholderSet(obj);
end

dbutil._parsePlaceholderSet = function(obj)
	local length = countTable(obj); 
	local index = 0;
	local set = "";
	for k, v in pairs(obj) do 
		index = index + 1;
		if(index ~= length) then
			set = set..k.." = ?"..k.." , ";
		else
			set = set..k.." = ?"..k;
		end
	end
	return set;
end

-- 解析 set 子句 (用于更新语句)
--   obj ： 更新项 table(k-v)  返回结果不带引号
-- return set 子句字符串
dbutil.parseSetWithoutQuote = function(obj)
	return " set "..dbutil._parseSetWithoutQuote(obj);
end

dbutil._parseSetWithoutQuote = function(obj)
	local length = countTable(obj);
	local index = 0;
	local set = "";
	for k, v in pairs(obj) do 
		index = index + 1;
		if(index ~= length) then
			set = set..k.." = "..v.." , ";
		else
			set = set..k.." = "..v;
		end
	end
	return set;
end

-- 解析 group by 子句
--	obj : group by 字段 table (v) eg:{"sex","age"}
-- return group 子句字符串
dbutil.parseGroup = function(obj)
	local length = countTable(obj); 
	local index = 0;
	local group = "";
	for k, v in pairs(obj) do 
		index = index + 1;
		if(index ~= length) then
			group = group..v..", ";
		else
			group = group..v;
		end
	end
	return " group by "..group;
end

-- 解析 order by 子句
--	obj ： order by 字段 table (k-v) eg:{user_name="ASC",id="DESC"}
--  	   order._keys 为多个 orderby 项的优先排序如： {'id','user_name'}
-- return order 子句字符串
dbutil.parseOrder = function(obj)
	local length = countTable(obj); 
	local index = 0;
	local order = "";
	if(obj._keys) then
		for k, v in pairsByKeys(obj, obj._keys) do 
			index = index + 1;
			--  由于 obj._keys 占一个地方
			if(index ~= length - 1) then
				order = order..k.." "..v.." , ";
			else
				order = order..k.." "..v;
			end
		end
	else
		for k, v in pairs(obj) do 
			index = index + 1;
			if(index ~= length) then
				order = order..k.." "..v.." , ";
			else
				order = order..k.." "..v;
			end
		end
	end
	
	return " order by "..order;
end

-- 解析 in 子句
--	obj ： in 字段 table (k-v) eg:{"id",{1,2,3,4,5} }
-- return in 子句字符串
dbutil.parseIn = function(obj)
	local tbl = obj[2];
	local inStr = "";
	for i,v in ipairs(tbl) do
		if(i ~= #tbl) then
			inStr = inStr..v.." , ";
		else
			inStr = inStr..v;
		end
	end
	return " where "..obj[1].." in ( "..inStr.." ) ";
end

-- 解析 in 子句 包含引号
dbutil.parseInWithQuote = function(obj)
	local tbl = obj[2];
	local inStr = "";
	for i,v in ipairs(tbl) do
		if(i ~= #tbl) then
			inStr = inStr..'"'.. v..'", ';
		else
			inStr = inStr..'"'..v..'"';
		end
	end
	return " where "..obj[1].." in ( "..inStr.." ) ";
end

-- 解析 not in 子句
--	obj ：not in 字段 table (k-v) eg:{"id",{1,2,3,4,5} }
-- return not in 子句字符串
dbutil.parseNotIn = function(obj)
	local tbl = obj[2];
	local notInStr = "";
	for i,v in ipairs(tbl) do
		if(i ~= #tbl) then
			notInStr = notInStr..v.." , ";
		else
			notInStr = notInStr..v;
		end
	end
	return " where "..obj[1].." not in ( "..notInStr.." ) ";
end

-- 解析 Limit 子句
--  obj ： 分页对象 pageSize 页面大小 pageNo 页号
-- return : limit 子句字符串
dbutil.parseLimit = function(obj)
	-- 当前页索引 = (当前页号 - 1) * 页面大小 从 0 开始
	if(obj.pageNo <= 0) then
		obj.pageNo = 1;
	end
	-- (pageIndex - 1) * pageSize
	local pageStart  = (obj.pageNo - 1) * obj.pageSize;
	local pageSept = obj.pageSize;
	return " limit "..pageStart.." , "..pageSept;
end

-- 解析 fields 子句 不带括号
--  obj ： table 字段 {subject_id,teacher_name}
-- return ： 字段字符串
dbutil.parseFields = function(obj)
	local length = #obj;
	local fields = "";
	for k, v in ipairs(obj) do 
		if(k ~= length) then
			fields = fields..v.." , ";
		else
			fields = fields..v;
		end
	end
	return " "..fields.." ";
end

-- 解析 对象集合
--   obj : 对象集合 eg : {{1,'a'},{3,'b'},{4,'c'}}
-- return :  批量添加字符串 eg : (1,'a'),(1,'b'),(1,'c'),(1,'d'),(1,'e'),(1,'f')
dbutil.parseObjects = function(objs)
	local length = countTable(objs);
	local res = "";
	for k, v in ipairs(objs) do 
		for key,value in ipairs(v) do
			if(key == 1) then
				res = res.."('"..value.."', ";
			elseif(key ~= #v) then
				res = res.."'"..value.."', ";
			else
				res = res.."'"..value.."')"
			end
		end
		if(k ~= #objs) then
			res = res.." , ";
		end
	end
	return res;
end


-- 打印 SQL 建议 dev 模式打开
dbutil.showSqlStr = function()
	if(showSql) then
		echo(lastSqlString);
	end
end

-- 校验必填参数
--  args: obj 校验对象 requireArr 必填项数组 res 响应对象
function rq(obj, requireArr, res)
	for i = 1,#requireArr do
		if(obj[requireArr[i]] == nil) then
			local rs = {type = 'error', err = 499, result = 'params error: '..requireArr[i]..' is not require.'};
			res:send(rs);
			return false;
		end
	end
	return true;
end

NPL.export(dbutil);