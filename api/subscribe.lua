local express = NPL.load('express')
local router = express.Router:new()
local commonBll = NPL.load('../bll/common')
local subscribeBll = NPL.load('../bll/subscribe')

router:post('/add', function(req, res, next)
    local p = req.body
    local packageId = p.packageId
    local rq = rq(p, {'packageId'}, res)
    if(not rq) then return end

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

-- 获取课程包的学习与购买状态
router:get('/state', function(req, res, next)
    local p = req.query
    local rs = {}
    local packageId = p.packageId
    local rq = rq(p, {'packageId'}, res)
    if(not rq) then return end
    local token = req.cookies.token

    local getMineState = function(user)

    end

    commonBll.auth(token, getMineState, function()
        res:send({
            err = 102,
            msg = 'plz login.'
        })
    end)
end)

NPL.export(router)