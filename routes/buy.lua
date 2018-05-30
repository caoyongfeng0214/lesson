local express = NPL.load('express')
local router = express.Router:new()
local orderBll = NPL.load('../bll/orders')
local commonBll = NPL.load('../bll/common')

router:get('/', function(req, res, next)
	res:render('buy', { buyCurrent = 'current'})
end)

router:get('/history', function(req, res, next)
	local token = req.cookies.token
	commonBll.auth(token, function(user)
		res:render('buy_history', { buyCurrent = 'current', username = user.username })
	end, function()
		res:render('to_login',{})
	end)
end)

router:get('/error', function(req, res, next)
	res:render('buy_status', { buyCurrent = 'current'})
end)

-- 确认订单
router:get('/order/:type', function(req, res, next)
	local createOrder = function(user)
		local username = user.username
		local p = req.params
		local type = p.type
		local rq = rq(p, {'type'}, res)
		if(not rq) then return end
		type = tonumber(type)
		local orderVo = {
			username = username,
			goodsType = type
		}
		-- TODO: 优惠券处理
		if(type == 0) then -- 购买半年
			orderVo.amount = 1260
		elseif(type == 1) then -- 购买一年
			orderVo.amount = 2420
		end
		local num, lastId = orderBll.save( orderVo )
		if(lastId) then
			res:redirect('http://release.keepwork.com/wiki/pay?username='..username..'&app_name=lessons&app_goods_id=1&price='..orderVo.amount..'&additional={%22order_no%22:'..lastId..'}&redirect=http://lesson.keepwork.com/buy/result/'..lastId)
		else
			-- 下订单失败
		end
	end
	
	local token = req.cookies.token
	commonBll.auth(token, createOrder, function()
		res:render('to_login',{})
	end)

	
end)

-- 支付结果
router:get('/result/:sn', function(req, res, next)
	local orderSn = req.params.sn
	local orderVo = orderBll.detail( { sn = orderSn } )
	local successFlag = false
	if( orderVo == nil ) then
		-- 失败
		successFlag = false
	elseif( orderVo.state == 0 ) then
		-- 确认中
		successFlag = false
	elseif( orderVo.state == 1 or orderVo.state == 2 ) then
		-- 支付成功
		successFlag = true
	elseif( orderVo.state == 4 ) then
		-- 失效订单
		successFlag = false
	end
	res:render('buy_status', { 
		buyCurrent = 'current',
		successFlag = successFlag,
		orderVo = orderVo
	})
end)

NPL.export(router)