local express = NPL.load('express')
local router = express.Router:new()
local orderBll = NPL.load('../bll/orders')

-- 确认订单
router:post('/create', function(req, res, next)
    local rs = {}
    local p = req.query
    local username = p.username
    local goodsType = p.goodsType
    local rq = rq(p, {'username', 'goodsType'}, res)
    if(not rq) then return end
    goodsType = tonumber(goodsType)
    -- TODO: 设置订单价格 
    if(goodsType == 0) then -- 购买半年

    elseif(goodsType == 1) then -- 购买一年
    
    end
    -- save order
    local num, lastId = orderBll.save( {
        username = username,
        goodsType = goodsType
    })
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

-- keepwork 支付回调
router:post('/keepworkPayHandler', function(req, res,next)
    -- TODO: 查询订单信息，检查订单金额是否正确，更新订单状态
end)

NPL.export(router)