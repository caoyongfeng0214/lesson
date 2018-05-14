local db = NPL.load('../dal/dbutil')
local memberBll = NPL.load('./member')

local orders = {}

local tbl = 'orders'

orders.save = function( order, cn )
    return db.insert(tbl, order, cn)
end

orders.update = function( order, cn )
    return db.updateBySn(tbl, order, cn)
end

orders.detail = function( where, group, order, sn )
    local sql = [[SELECT sn, username, orderTime, payTime, amount, reallyPayAmount, lessAmount, couponID, endTime, goodsType, state FROM orders]]
    return db.detail(sql, where, group, order, cn)
end

orders.finish = function( order )
    -- 更新订单状态， 更新用户会员到期时间
    echo('#DEBUG: ')
    -- {amount=2420,reallyPayAmount=2420,sn=10,orderTime="2018-05-14 10:57:26",state=0,username="keep",lessAmount=0,goodsType=1,}
    echo(order)
    local issucc
    db.execInTrans(function(cn, returnTrans)
        local member = memberBll.findOrInsertByName( order.username )
        local num1 = nil
        local num2 = nil
        order.state = 1 -- 已支付
        order.payTime = os.date("%Y-%m-%d %H:%M:%S")
        local goodsType = tonumber(order.goodsType)
        -- 计算当前订单的 endTime = 当前会员截止日期 + 购买套餐日期
        -- member.vipEndTime = endTime
        local addTime = 0
        if( goodsType == 0 ) then
            -- 购买半年 30 days * 6
            addTime = 6 * 30 * 24 * 60 * 60
        elseif( goodsType == 1 ) then
            -- 购买一年 30 days * 12
            addTime = 12 * 30 * 24 * 60 * 60
        end
        local currentTime = os.time()
        local targetTime
        if(member.vipEndUnixTime == nil) then
            -- 没有开过会员
            targetTime = currentTime + addTime
        elseif( tonumber( member.vipEndUnixTime ) < currentTime ) then
            -- 会员已到期
            targetTime = currentTime + addTime
        else
            -- 会员未过期
            targetTime = tonumber(member.vipEndUnixTime) + addTime
        end
        local endTimeDate = os.date("%Y-%m-%d %H:%M:%S", targetTime)
        order.endTime = endTimeDate
        member.vipEndTime = endTimeDate
        num1 = orders.update( order, cn ) -- 更新订单信息
        member.vipEndUnixTime = nil
        member.vipDay = nil
        num2 = memberBll.update( member, cn ) -- 更新会员信息
        if num1 == nil or num2 == nil then
			returnTrans(false)
		else
			returnTrans(true)
        end
    end, function(issuccess, result)
        issucc = issuccess
    end)
    return issucc
end

orders.list = function( where, group, order, limit, cn )
    local sql = [[SELECT sn, username, orderTime, payTime, payWay, amount, reallyPayAmount, lessAmount, endTime, goodsType, state, TIMESTAMPDIFF( DAY,NOW() , endTime ) vipDay FROM orders]]
    return db.findJoin(sql, where, group, order, limit, cn)
end

NPL.export(orders)