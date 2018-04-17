--[[
	Author: CYF
	Date: 2017年6月19日
	EMail: me@caoyongfeng.com
	Desc: 对mysql操作的封装
]]

NPL.load('common');
local driver = require('luasql.mysql');


local mysql = {};


--[[
	user: 用户名
	pwd: 密码
	db: 要连接的数据库名
	host: 要连接的数据库的ip或域名，默认 '127.0.0.1'
	port: 要连接的数据库的端口，默认 3306
]]
function mysql:new(o)
	o = o or {};
	if(not o.host) then
		o.host = '127.0.0.1';
	end
	if(not o.port) then
		o.port = 3306;
	end
	setmetatable(o, self);
	self.__index = self;
	return o;
end


function mysql:connect()
	local env = driver.mysql();
	local cn = env:connect(self.db, self.user, self.pwd, self.host, self.port);
	rawset(cn.__index, 'env', env);
	cn:execute('SET NAMES UTF8');
	return cn, env;
end


function mysql:exec(sql, sqlParams, cn)
	if(not cn) then
		cn = self:connect();
	end
	
	if(sqlParams) then
		for k, v in pairs(sqlParams) do
			sql = sql:replace('%?([%w_]+)', function(w)
				local v = sqlParams[w];
				local ty = type(v);
				if(ty == 'boolean') then
					if(v) then
						v = 1;
					else
						v = 0;
					end
				elseif(ty == 'string') then
					v = '"' .. cn:escape(v) .. '"';
				end
				return v;
			end);
		end
	end

	 echo(sql);
	
	return cn:execute(sql), cn, cn.env;
end


-- cn 参数是可选的
-- 执行一条带参数的非查询sql，返回受影响的行数和新插入数据的id（如果有）,
-- 不关闭连接，连接对象会作为第一个数据返回
-- return cn, cnt, lastId
function mysql:_execNonQuery(sql, sqlParams, cn)
	local cur, cn2 = self:exec(sql, sqlParams, cn);
	local cur_type = type(cur);
	local lastId = nil;
	if(cur_type == 'number') then
		lastId = cn2:getlastautoid();
	end
	return cn2, cur, lastId;
end


-- cn 参数是可选的
-- 执行一条带参数的非查询sql，返回受影响的行数和新插入数据的id
-- 关闭连接，如果在执行时传递了cn参数，则不会关闭连接
-- return cnt, lastId
-- 若失败，cnt为nil
function mysql:execNonQuery(sql, sqlParams, cn)
	local cn2, cnt, lastId = self:_execNonQuery(sql, sqlParams, cn);
	if(not cn) then
		cn2:close();
		cn2.env:close();
	end
	return cnt, lastId;
end


-- cn 参数是可选的
-- 执行一条带参数的查询sql，
-- 不关闭连接，连接对象会作为第一个数据返回
-- return cn, rows
function mysql:_execRows(sql, sqlParams, cn)
	local cur, cn2 = self:exec(sql, sqlParams, cn);
	local results = nil;
	local cur_type = type(cur);
	if(cur_type == 'userdata') then
		results = {};
		local cols = cur:getcolnames();
		--print('FFFFFFFFFFFFFFFFFFFFFFFf');
		--for k, v in pairs(cols) do
		--	print(k);
		--	print('=');
		--	print(v);
		--end
		local types = cur:getcoltypes();
		--print('TTTTTTTTTTTTTTTTTTTTT');
		--for k, v in pairs(types) do
		--	print(k);
		--	print('=');
		--	print(v);
		--end
		local key_type = {};
		for k, v in pairs(cols) do
			local ty = types[k];
			if(ty:startsWith('number')) then
				ty = 'number'
			end
			key_type[cols[k]] = ty;
		end
		local row = cur:fetch({}, 'a');
		while row do
			local tb = {};
			for k, v in pairs(row) do
				if(key_type[k] == 'number') then
					v = tonumber(v);
				end
				tb[k] = v;
			end
			table.insert(results, tb);
			row = cur:fetch(row, 'a')
		end
		cur:close();
	end
	return cn2, results;
end


-- cn 参数是可选的
-- 执行一条带参数的查询sql，
-- 关闭连接，如果在执行execRows()时传递了cn参数，则不会关闭连接
-- return rows
function mysql:execRows(sql, sqlParams, cn)
	local cn2, rows = self:_execRows(sql, sqlParams, cn);
	if(not cn) then
		cn2:close();
		cn2.env:close();
	end
	return rows;
end


-- cn 参数是可选的
-- 执行一条带参数的查询sql，返回查询到的第一条数据，
-- 不关闭连接，连接对象会作为第一个数返回
-- modestring: 'n' or 'a'，默认 'a'
-- return cn, row
function mysql:_execRow(sql, sqlParams, cn, modestring)
	modestring = modestring or 'a'
	local cur, cn2 = self:exec(sql, sqlParams, cn);
	local result = nil;
	local cur_type = type(cur);
	if(cur_type == 'userdata') then
		local types = cur:getcoltypes();
		local key_type = types;
		if(modestring == 'a') then
			-- print('aaaaaaaaaaaaaaaaaaaaaaaaaa');
			key_type = {};
			local cols = cur:getcolnames();
			for k, v in pairs(cols) do
				local ty = types[k];
				if(ty:startsWith('number')) then
					ty = 'number'
				end
				key_type[cols[k]] = ty;
			end
		else
			for k, v in pairs(types) do
				if(v:startsWith('number')) then
					key_type[k] = 'number';
				end
			end
		end

		local row = cur:fetch({}, modestring);
		if row then
			result = {};
			for k, v in pairs(row) do
				if(key_type[k] == 'number') then
					v = tonumber(v);
				end
				result[k] = v;
			end
		end
		cur:close();
	end
	return cn2, result;
end


-- cn 参数是可选的
-- 执行一条带参数的查询sql，返回查询到的第一条数据，
-- 关闭连接，如果在执行时传递了cn参数，则不会关闭连接
-- modestring: 'n' or 'a'，默认 'a'
-- return row
function mysql:execRow(sql, sqlParams, cn, modestring)
	local cn2, result = self:_execRow(sql, sqlParams, cn, modestring);
	if(not cn) then
		cn2:close();
		cn2.env:close();
	end
	return result;
end



-- cn 参数是可选的
-- 执行一条带参数的查询sql，返回查询到的第一条数据中的第一列的值，
-- 不关闭连接，连接对象会作为第一个数据返回
-- return cn, val
function mysql:_execScalar(sql, sqlParams, cn)
	local cn2, row = self:_execRow(sql, sqlParams, cn, 'n');
	--print(row);
	--for k, v in pairs(row) do
	--	print(k);
	--	print('=');
	--	print(v);
	--end
	local val = nil;
	if(row) then
		val = row[1];
	end
	return cn2, val;
end


-- cn 参数是可选的
-- 执行一条带参数的查询sql，返回查询到的第一条数据中的第一列的值，
-- 关闭连接，如果在执行时传递了cn参数，则不会关闭连接
-- return val
function mysql:execScalar(sql, sqlParams, cn)
	local cn2, val = self:_execScalar(sql, sqlParams, cn);
	if(not cn) then
		cn2:close();
		cn2.env:close();
	end
	return val;
end



-- 在事务中执行。
-- 第一个参数是包含在事务中执行的语句的function，该function会接收两个参数：
--		cn, returnTrans
--		第二个参数 returnTrans 是一个function，当数据操作完毕后，需要调此function通知事务程序已经执行完毕事务了，
--			此function可接收两个参数，
--				第一个参数为true或false，当为true时，事务将提交，否则回滚。
--				第二个参数是可选的，如果希望在回调中
function mysql:execInTrans(execFun, callbackFun)
	local cn = self:connect();
	cn:setautocommit(false);
	execFun(cn, function(issuccess, result)
		if(issuccess) then
			cn:commit();
		else
			cn:rollback();
		end
		cn:close();
		cn.env:close();
		if(callbackFun) then
			callbackFun(issuccess, result);
		end
	end);
	
	return cn;
end


return mysql;
