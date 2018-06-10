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
        if(subscribeVo and subscribeVo.state == 1) then
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
    local packageId = p.packageId
    local rq = rq(p, {'packageId'}, res)
    if(not rq) then return end
    local token = req.cookies.token

    local getMineState = function(user)
        -- 先检测购买状态，再检测学习状态
        local object = {
            username = user.username,
            packageId = packageId,
            state = 1
        }
        local subscribeVo = subscribeBll.get(object)
        if(subscribeVo) then
            -- 已添加课程包
            local packageState = subscribeBll.state({
                ['sb.username'] = user.username,
                ['sb.packageId'] = packageId
            })
            if(packageState) then
                packageState.lessons = commonlib.Json.Decode(packageState.lessons)
                res:send({
                    err = 0,
                    data = packageState
                })
            else
                res:send({
                    err = 101,
                    msg = 'get mine package state fail.'
                })
            end
        else
            res:send({
                err = 400,
                msg = 'package state: no bought.'
            })
        end
    end

    commonBll.auth(token, getMineState, function()
        res:send({
            err = 102,
            msg = 'plz login.'
        })
    end)
end)

NPL.export(router)