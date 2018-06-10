NPL.load("(gl)script/ide/commonlib.lua")
NPL.load("(gl)script/ide/System/os/GetUrl.lua")
local express = NPL.load('express')
local memberBll = NPL.load('../bll/member')
local commonBll = NPL.load('../bll/common')
local cdkeyBll = NPL.load('../bll/cdkey')
local router = express.Router:new()
local System = commonlib.gettable("System")
local sitecfg = NPL.load('../confi/siteConfig')

-- 验证身份
router:get('/auth', function(req, res, next)
    local token = req.cookies.token
    local findMember = function(user)
        local username = user.username
        local portrait = user.portrait
        local member = memberBll.findOrInsertByName(username, portrait)
        local rs = {}
        rs = {
            err = 0,
            data = member
        }
        res:send(rs)
    end
    commonBll.auth(token, findMember, function()
        res:send({
            err = 102,
            msg = 'plz login.'
        })
    end)
end)

-- 获取我的记录
router:get('/statis', function(req, res, next)
    local p = req.query
    local username = p.username
    local rq = rq(p, {'username'}, res)
    if(not rq) then return end
    local where = {}
    where.username = username
    local memberStatis = memberBll.statis(where)
    res:send({
        err = 0,
        data = memberStatis
    })
end)

-- 添加推荐人
router:post('/addPresenter', function(req, res, next)
    local rs = {}
    local p = req.body
    local presenter = p.presenter
    local rq = rq(p, {'presenter'}, res)
    if(not rq) then return end
    local presenterVo = memberBll.get({username = presenter})
    if(presenterVo == nil) then
        res:send({
            err = 104,
            msg = 'presenter not found.'
        })
        return
    end
    -- 查询自己现在是否有推荐人
    local addPresenter = function(user)
        local mineInfo = memberBll.get({username = user.username})
        if(mineInfo and mineInfo.presenter ~= nil) then
            res:send({
                err = 105,
                msg = 'not allow add more then two presenter'
            })
            return
        end
        local isSucces = memberBll.addPresenter(mineInfo, presenterVo)
        if(not isSucces) then
            res:send({
                err = 101,
                msg = 'add presenter fail.'
            })
        else
            -- 添加推荐人，给自己和对方各添加 20 知识币
            res:send({
                err = 0,
                data = mineInfo
            })
        end
    end
    local token = req.cookies.token
    commonBll.auth(token, addPresenter, function()
        res:send({
            err = 102,
            msg = 'plz login.'
        })
    end)

end)

-- firstIn
router:post('/firstIn', function(req, res, next)
    local firstIn = function(user)
        memberBll.firstIn(user.username)
        res:send({
            err = 0,
            msg = 'success.'
        })
    end 
    local token = req.cookies.token
    commonBll.auth(token, firstIn, function()
        res:send({
            err = 102,
            msg = 'plz login.'
        })
    end)
end)

-- 激活账户成为教育账户
router:post('/activate', function(req, res, next)
    local p = req.body
    local key = p.key
    local rq = rq(p, {'key'}, res)
    if(not rq) then return end
    
    local token = req.cookies.token    
    local activateMember = function(user)
        local cdkeyVo = cdkeyBll.get({
            ['`key`'] = key
        })
        if(cdkeyVo == nil) then
            res:send({
                err = 124,
                msg = 'cdkey not found.'
            })
            return
        else
            if(cdkeyVo.state ~= 1) then
                res:send({
                    err = 125,
                    msg = 'this cdkey is disabled.'
                })
                return
            end
        end
        local mineInfo = memberBll.get({username = user.username})
        if(mineInfo and mineInfo.identity == 2) then
            res:send({
                err = 123,
                msg = 'u are activated account now.'
            })
            return
        end
        for k,v in pairs(req) do
            if(k == 'X-Real-IP') then
                cdkeyVo.userIp = v
            end
        end
        local isSucces = memberBll.activateAccount( mineInfo, cdkeyVo )
        if(not isSucces) then
            res:send({
                err = 101,
                msg = 'activate fail.'
            })
        else
            res:send({
                err = 0,
                msg = 'activate success.'
            })
        end
    end

    commonBll.auth(token, activateMember, function()
        res:send({
            err = 102,
            msg = 'plz login.'
        })
    end)
end)

NPL.export(router)