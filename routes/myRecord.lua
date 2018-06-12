local express = NPL.load('express')
local router = express.Router:new()
local memberBll = NPL.load('../bll/member')
local commonBll = NPL.load('../bll/common')

router:get('/', function(req, res, next)

	local getMyRecord = function(user) 
		local username = user.username
		local where = {}
		where.username = username
		local memberStatis = memberBll.statis(where)
		local teached = tonumber(memberStatis.teached)
		local learnedDuration = tonumber(memberStatis.learnDuration)
		if(memberStatis and (teached > 0 or memberStatis.learned >0) ) then
			memberStatis.haveRecordFlag = true
			if(teached and teached > 0) then
				memberStatis.haveTeachedFlag = true
				memberStatis.teachHours = math.floor(teached * 45 / 60)
				memberStatis.teachMin = teached * 45 % 60
			end
			if(learnedDuration and memberStatis.learned > 0) then
				memberStatis.haveLearnedFlag = true
				memberStatis.learnHours = math.floor(learnedDuration / 60)
				memberStatis.learnMin = learnedDuration % 60
			end
		end
		res:render('my_record', {
			data = memberStatis,
			recordCurrent = 'current'
		})
	end

	local token = req.cookies.token
	commonBll.auth(token, getMyRecord, function()
		res:render('to_login', {
			recordCurrent = 'current'
		})
	end)
end)

NPL.export(router)