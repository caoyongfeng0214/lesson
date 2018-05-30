NPL.load("(gl)script/ide/commonlib.lua")
NPL.load("(gl)script/ide/System/os/GetUrl.lua")
local express = NPL.load('express')
local memberBll = NPL.load('../bll/member')
local router = express.Router:new()
local System = commonlib.gettable("System")
local sitecfg = NPL.load('../confi/siteConfig')

-- 验证身份
router:get('/auth', function(req, res, next)
    print('t ->', __rts__:GetName())
    local token = req.cookies.token
    echo('#debug')
    echo(token)
    local p = req.query
    local username = p.username
    local portrait = p.portrait
    local rq = rq(p, {'username'}, res)
    if(not rq) then return end
    local member = memberBll.findOrInsertByName(username, portrait)
    local rs = {}
    rs = {
        err = 0,
        data = member
    }
    -- res:setHeader('Access-Control-Allow-Origin','http://localhost:8080')
    res:send(rs)
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

NPL.export(router)