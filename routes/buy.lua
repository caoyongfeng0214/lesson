local express = NPL.load('express');
local router = express.Router:new();

router:get('/', function(req, res, next)
	res:render('buy',{});
end);

router:get('/history', function(req, res, next)
	res:render('buy_history',{});
end);

router:get('/error', function(req, res, next)
	res:render('buy_status',{});
end);


NPL.export(router);