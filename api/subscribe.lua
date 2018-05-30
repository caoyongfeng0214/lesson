local express = NPL.load('express')
local router = express.Router:new()
local subscribeBll = NPL.load('../bll/subscribe')
local commonBll = NPL.load('../bll/common')

router:post('/add', function(req, res, next)
    local p = req.query
    local rs = {err = 0, msg = 'add subscribe success.'}
    local packageId = p.packageId
    local rq = {p, {'packageId'}, res}
    local addPackage = function(user)
        -- 判断是否已购买该课程
        local object = {
            username = user.username,
            packageId = packageId
        }
        local subscribeVo = subscribeBll.get(object)
        if(subscribeVo) then
            res:send({
                err = 103,
                msg = 'u have already bought this package.'
            })
            return
        end
        local issucc = subscribeBll.addPackage(object)
        if(not issucc) then
            res:send({
                err = 101,
                msg = 'add subscribe fail.'
            })
        else
            res:send({
                err = 0,
                msg = 'add subscribe success.'
            })
        end
    end
    -- token
    local token = req.cookies.token
    commonBll.auth(token, addPackage, function()
        res:send({
            err = 102,
            msg = 'plz login.'
        })
    end)
end)

NPL.export(router)