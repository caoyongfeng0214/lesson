local express = NPL.load('express')
local router = express.Router:new()

router:get('/', function(req, res, next)
	res:render('lesson_list',{
		lessonCurrent = 'current'
	})
end)


NPL.export(router)