local express = NPL.load('express')
local adminBll = NPL.load('../bll/_mg_admin')
local router = express.Router:new()
local md5 = NPL.load('md5')

-- 获取管理员列表
router:get('/list', function(req, res, next)
    local rs = {}
    local p = req.query
    local where = {}
    if(p.key) then
        where['~`username`'] = '%' .. p.key..'%'
    end
    local order = nil
    -- 排序
    if(p.sort) then
        local sort = tonumber(p.sort)
    end
    local limit = {
        pageSize = p.psize,
        pageNo = p.pno
    }
    local list, page = adminBll.list(where, nil, order, limit)
    if(list) then
        rs.err = 0
        rs.data = list
        rs.page = page
    else
        rs.err = 101
        rs.msg = 'get admin list fail.'
    end
    res:send(rs)
end)

-- 获取类型列表
router:get('/typeList', function(req, res, next)
    local rs = {}
    local p = req.query
    local where = {}
    local order = nil
    -- 排序
    if(p.sort) then
        local sort = tonumber(p.sort)
    end
    local limit = {
        pageSize = p.psize,
        pageNo = p.pno
    }
    local list, page = adminBll.listType(where, nil, order, limit)
    if(list) then
        rs.err = 0
        rs.data = list
        rs.page = page
    else
        rs.err = 101
        rs.msg = 'get type list fail.'
    end
    res:send(rs)
end)

-- 新增或修改管理员
router:post('/upsert', function(req, res, next)
    local rs = {}
    local p = req.body
    if(p.sn) then
        -- update
        if(p.pwd) then
            p.pwd = md5(p.pwd)
        end
    else
        -- insert
        local rq = rq(p, {'username', 'type', 'pwd'}, res)
        if(not rq) then return end
        p.pwd = md5(p.pwd)
    end
    local num, lastSn = adminBll.upsert(p)
    if(num == nil) then
        rs = {
            err = 101,
            msg = 'upsert admin fail.'
        }
    else
        rs = {
            err = 0,
            msg = 'upsert success.',
            sn = lastSn
        }
    end
    res:send(rs)
end)

-- 新建或更新类型
router:post('/upsertType', function(req, res, next)
    local rs = {}
    local p = req.body
    if(p.sn) then
        -- update
    else
        -- insert
        local rq = rq(p, {'name'}, res)
        if(not rq) then return end
    end
    local num,lastSn = adminBll.upsertType(p)
    if(num == nil) then
        rs = {
            err = 101,
            msg = 'upsert type fail.'
        }
    else
        rs = {
            err = 0,
            msg = 'upsert success.',
            sn = lastSn
        }
    end
    res:send(rs)
end)

-- 删除指定管理员
router:post('/remove', function(req, res, next)
    local rs = {}
    local p = req.body
    local rq = rq(p, {'sn'}, res)
    if(not rq) then return end
    local num = adminBll.del({sn = p.sn})
    if(num == nil) then
        rs = {
            err = 101,
            msg = 'remove admin fail.'
        }
    else
        rs = {
            err = 0,
            msg = 'remove success.'
        }
    end
    res:send(rs)
end)

router:post('/login', function(req, res, next)
	local re = adminBll.auth(req, res)
	res:send(re)
end)


router:post('/logout', function(req, res, next)
	adminBll.logout(req, res)
	res:send({err=0})
end)

router:post('/current', function(req, res, next)
    local re = adminBll.current(req, res)
    local rs = {}
    if(re == nil) then
        rs = {
            err = 102,
            msg = 'no auth.'
        }
    else
        rs = {
            err = 0,
            data = re
        }
    end
    res:send(rs)
end)

NPL.export(router)