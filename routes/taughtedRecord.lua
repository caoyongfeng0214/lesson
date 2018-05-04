local express = NPL.load('express');
local router = express.Router:new();

-- 我的记录-授课记录 授课详情
router:get('/:class_id', function(req, res, next)
	local classId = req.params.class_id

	res:render('taughted_record', {
		classId = classId
	});
end);

router:get('/details/:sn/:studentNo', function(req, res, next)
	local recordSn = req.params.sn;
	local studentNo = req.params.studentNo;
	res:render('taughted_details', {
		recordSn = recordSn,
		studentNo = studentNo
	});
end);

NPL.export(router);