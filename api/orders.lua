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
    local orderVo = {
        username = username,
        goodsType = goodsType
    }
    -- 设置订单价格 
    if(goodsType == 0) then -- 购买半年
        orderVo.amount = 1260
    elseif(goodsType == 1) then -- 购买一年
        orderVo.amount = 2420
    end
    -- save order

    local num, lastId = orderBll.save( orderVo )
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

router:get('/list', function(req, res, next)
    local rs = {}
    local p = req.query
    local username = p.username
    local rq = rq(p, {'username'}, res)
    if(not rq) then return end
    local limit = {
        pageSize = p.psize,
        pageNo = p.pno
    }
    local list, page = orderBll.list( { username = username, state = 1 }, nil, {orderTime = 'DESC'}, limit )
    if(list) then
        rs.err = 0
        rs.data = list
        rs.page = page
    else
        rs.err = 101
        rs.msg = 'get order list fail.'
    end
    res:send(rs)
end)

-- keepwork 支付回调
router:post('/keepworkPayHandler', function(req, res,next)
    -- TODO: 查询订单信息，检查订单金额是否正确，更新订单状态
    echo('----------------keepworkPayHandler------------------keepworkPayHandler---------------');
	echo('----------------body------------------body---------------');
	echo(req.body);
	echo('----------------query------------------query---------------');
	echo(req.query);
	echo('----------------host------------------host---------------');
	echo(req.Host);
	echo('----------------client------------------client---------------');
	echo(req.client);
	echo('----------------req------------------req---------------');
    -- 检查请求来源 ip 是否来自 keepwork
	for k,v in pairs(req) do
		if(k == 'X-Real-IP') then
			echo(v);
			-- 10.28.18.2 release 环境
			-- 10.28.18.6 online 环境
			if(v ~= '10.28.18.6') then
				data['msg'] = 'Not allow IP!';
				data['err'] = 103;
				res:send(data);
				echo(data);
				return;
			end
		end
	end
	local orderInfo = req.query;
    if(orderInfo == nil or orderInfo.order_no == nil) then
        res:send({
            err = 101,
            msg = 'error order.'
        })
        return
    end
    local orderVo = orderBll.detail({sn = orderInfo.order_no})
    
    if(orderVo == nil) then
        res:send({
            err = 101,
            msg = 'error order.'
        })
        return
    else
        if(orderVo.lessAmount == nil) then
            orderVo.lessAmount = 0
        end
        local orderPrice = 0 + (orderVo.amount - orderVo.lessAmount)
        if(orderVo.state == 0 and (orderPrice - orderInfo.price) == 0) then
            orderVo.reallyPayAmount = orderVo.amount - orderVo.lessAmount
            local succ = orderBll.finish(orderVo)
        else
            -- 异常订单
            res:send({
                err = 101,
                msg = 'error order.'
            })
            return
        end
    end
    res:send( { err = 0 } )
end)

NPL.export(router)