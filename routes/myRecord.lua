local express = NPL.load('express');
local router = express.Router:new();
local memberBll = NPL.load('../bll/member')

router:get('/:username', function(req, res, next)
	local username = req.params.username
	local where = {}
    where.username = username
    local memberStatis = memberBll.statis(where)
	if(memberStatis and (memberStatis.teached > 0 or memberStatis.learned >0) ) then
		memberStatis.haveRecordFlag = true
		if(memberStatis.teached) then
			memberStatis.teachHours = math.floor(memberStatis.teached * 45 / 60)
			memberStatis.teachMin = memberStatis.teached * 45 % 60
		end
		if(memberStatis.learned) then
			memberStatis.learnHours = math.floor(memberStatis.learnDuration / 60)
			memberStatis.learnMin = memberStatis.learned % 60
		end
	end
	res:render('my_record', {
		data = memberStatis
	});
end);

NPL.export(router);