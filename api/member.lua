NPL.load("(gl)script/ide/commonlib.lua")
NPL.load("(gl)script/ide/System/os/GetUrl.lua")
local express = NPL.load('express')
local memberBll = NPL.load('../bll/member')
local router = express.Router:new()
local System = commonlib.gettable("System")
local sitecfg = NPL.load('../confi/siteConfig');

-- 验证身份
router:get('/auth', function(req, res, next)
    print('t ->', __rts__:GetName())
    local p = req.query
    local username = p.username
    local rq = rq(p, {'username'}, res)
    local where = {}
    where.username = username
    local member = memberBll.get(where)
    local rs = {}
    if(member == nil) then
        member = {
            username = username
        }
        memberBll.save(member)
    end
    rs = {
        err = 0,
        data = member
    }
    res:send(rs)
end)

NPL.export(router);