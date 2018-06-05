local express = NPL.load('express')
local router = express.Router:new()
local commonBll = NPL.load('../bll/common')

router:get('/', function(req, res, next)
	local getMyRecord = function(user) 
		res:render('learning_record', {
			learningCurrent = 'current'
		})
	end

	local token = req.cookies.token
	commonBll.auth(token, getMyRecord, function()
		res:render('to_login',{})
	end)
end)

NPL.export(router)