local db = NPL.load('../dal/dbutil')
local md5 = NPL.load('md5')

local admin = {}

admin.auth_session_key = '__admin_auth__'

local tbl_admin = 'admins'
local tbl_type = 'admintype'

admin.list = function(where, group, order, limit, cn)
    local sql = 'SELECT a.sn, a.username, a.type, a.createTime, a.lastLoginIp, a.lastLoginTime, a.state, t.`name` typeName FROM admins a LEFT JOIN admintype t ON a.`type` = t.`sn`'
    return db.findJoin(sql, where, group, order, limit, cn)
end

admin.upsert = function(admin, cn)
    return db.upsert(tbl_admin, admin, cn)
end

admin.del = function(where, cn)
	return db.delete(tbl_admin, where)
end

admin.get = function(where, group, order, cn)
    local sql = 'SELECT * FROM admins'
    return db.detail(sql, where, group, order, cn)
end

admin.listType = function(where, group, order, limit, cn)
    local sql = 'SELECT * FROM admintype'
    return db.findJoin(sql, where, group, order, limit, cn)
end

admin.upsertType = function(admintype, cn)
    return db.upsert(tbl_type, admintype, cn)
end

-- 检测是否处于登录状态
-- 若返回一个用户数据，表示是登录状态，
-- 若返回nil，表示非登录状态
admin.checkAuth = function(req, res)
	local s = req.session:get(admin.auth_session_key)
	if(s) then
		req.session:set({
			name = admin.auth_session_key,
			value = s.value
		});
		return s.value
	end
	return nil
end;

-- 登录
admin.auth = function(req, res)
	local username = req.body.username
	local pwd = req.body.pwd
	local re = {err = 0}
	if(username and pwd) then
		local u = admin.get({username = username})
		if(u) then
			if(u.pwd == md5(pwd)) then
				req.session:set({
					name = admin.auth_session_key,
					value = u
				})
			else
				re.err = 487 -- 密码错误
			end
		else
			re.err = 488 -- 用户不存在
		end
	else
		re.err = 499 -- 参数不符合要求
	end
	return re
end

-- 当前登录管理员
admin.current = function(req, res)
	local mysession = req.session:get(admin.auth_session_key);
	local v = nil;
    if(mysession) then
        v = mysession.value;
	end
	return v
end

-- 登出
admin.logout = function(req, res)
	req.session:remove(admin.auth_session_key)
end


NPL.export(admin)