local express = NPL.load('express');
local router = express.Router:new();


router:post('/', function(req, res, next)
	if(req.files) then
		local re = req.files[1]:saveAs();
		res:send(re);
	else
		res:send({err = '参数错误'});
	end
end);


NPL.export(router);