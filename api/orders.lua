local express = NPL.load('express')
local router = express.Router:new()
local orderBll = NPL.load('../bll/orders')

-- 确认订单
router:post('/create'， function(req, res, next)
    local rs = {}
    local p = req.body
    local username = p.username
    local goodsType = p.goodsType
    local rq = rq(p, {'username', 'goodsType'}, res)
    if(not rq) then return end
    -- save order
    local num, lastId = orderBll.save( {
        username = username,
        goodsType = goodsType
    });
    if(lastId) then
        rs = {
            err = 0,
            data = lastId
        }
    else
        rs = {
            err = 101,
            msg = 'save order fail.'
        }
    end
    res:send(rs)
end)

NPL.export(router)