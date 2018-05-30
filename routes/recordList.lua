local express = NPL.load('express')
local router = express.Router:new()


router:get('/:username', function(req, res, next)
	local username = req.params.username

	res:render('record_list', {
		username = username,
		recordCurrent = 'current'
	})
end)

NPL.export(router)