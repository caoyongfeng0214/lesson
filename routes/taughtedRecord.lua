local express = NPL.load('express');
local router = express.Router:new();

-- 我的记录-授课记录 授课详情
router:get('/:class_id', function(req, res, next)
	local classId = req.params.class_id

	res:render('taughted_record', {
		classId = classId,
		recordCurrent = 'current'
	});
end);

NPL.export(router);