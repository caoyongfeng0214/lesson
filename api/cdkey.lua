NPL.load("(gl)script/ide/commonlib.lua")
local express = NPL.load('express')
local cdkeyBll = NPL.load('../bll/cdkey')
local router = express.Router:new()
local uuid = NPL.load('uuid')

-- GenUUID 生成激活码
router:post('/build', function(req, res, next)
    local p = req.body
    local number = p.number
    local rq = rq(p, {'number'}, res)
    if(not rq) then return end
    number = tonumber(number)
    if(number <= 0 or number > 100) then
        res:seed({
            err = 109,
            msg = 'number permissible range is 1~100.'
        })
        return
    end
    uuid.seed()
    local cdkeyArr = {}
    for i=1, number do
        table.insert( cdkeyArr, uuid() )
    end
    local objs = {}
    for i,v in ipairs(cdkeyArr) do
        cdkeyArr[i] = v:replace('-', '')
        local obj = {}
        obj[1] = cdkeyArr[i]
        obj[2] = 1
        table.insert( objs, obj )
    end
    local num = cdkeyBll.addBatch({'`key`', 'state'}, objs)
    if(num == nil) then
        res:send({
            err = 101,
            msg = 'build cdkey fail.'
        })
        return
    end
    res:send({
        err = 0,
        data = cdkeyArr
    })
end)

-- 激活码列表
router:get('/list', function(req, res, next)
    local rs = {}
    local p = req.query
    local where = {}
    if(p.key) then
        where['~`key`'] = '%'..p.key..'%'
    end
    local order = nil
    -- 排序
    if(p.sort) then
        local sort = tonumber(p.sort)
        if(sort == 1) then
            -- 生成时间正序
            order = { createTime = 'ASC' }
        elseif(sort == 101) then
            -- 生成时间倒序
            order = { createTime = 'DESC'}
        elseif(sort == 2) then
            -- 使用时间正序
            order = { useTime = 'ASC' }
        elseif(sort == 102) then
            -- 使用时间倒序
            order = { useTime = 'DESC' }
        end
    end
    local limit = {
        pageSize = p.psize,
        pageNo = p.pno
    }
    local list, page = cdkeyBll.list(where, nil, order, limit)
    if(list) then
        rs.err = 0
        rs.data = list
        rs.page = page
    else
        rs.err = 101
        rs.msg = 'get cdkey list fail.'
    end
    res:send(rs)
end)

NPL.export(router)