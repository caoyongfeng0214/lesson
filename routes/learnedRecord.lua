local express = NPL.load('express')
local router = express.Router:new()

router:get('/:username/:lessonNo', function(req, res, next)
	local username = req.params.username
	local lessonNo = req.params.lessonNo
	res:render('learned_record',{
		username = username,
		lessonNo = lessonNo
	})
end)

router:get('/:sn', function(req, res, next)
	local sn = req.params.sn
	res:render('learned_details', {
		sn = sn
	})
end)

NPL.export(router)