local express = NPL.load('express');
local router = express.Router:new();


router:get('/', function(req, res, next)

	res:render('record_list');
end);

NPL.export(router);