local express = NPL.load('express');
local router = express.Router:new();


router:get('/', function(req, res, next)

	res:render('learned_record');
end);

NPL.export(router);