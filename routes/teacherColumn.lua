local express = NPL.load('express')
local router = express.Router:new()
local commonBll = NPL.load('../bll/common')
local memberBll = NPL.load('../bll/member')

router:get('/', function(req, res, next)
	local getMyRecord = function(user) 
		local memberVo = memberBll.findOrInsertByName(user.username)
		if(memberVo.identity and memberVo.identity == 2) then
			res:render('teacher_column_detail', {teacherCurrent = 'current'})
			return
		end
		res:render('teacher_column', {
			teacherCurrent = 'current'
		})
	end

	local token = req.cookies.token
	commonBll.auth(token, getMyRecord, function()
		res:render('to_login',{teacherCurrent = 'current'})
	end)
end)

router:get('/detail', function(req, res, next)
	res:render('teacher_column_detail', {teacherCurrent = 'current'})
end)

NPL.export(router)