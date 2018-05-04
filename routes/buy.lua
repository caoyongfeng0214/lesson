local express = NPL.load('express');
local router = express.Router:new();

router:get('/', function(req, res, next)
	res:render('buy', { buyCurrent = 'current'});
end);

router:get('/history', function(req, res, next)
	res:render('buy_history', { buyCurrent = 'current'});
end);

router:get('/error', function(req, res, next)
	res:render('buy_status', { buyCurrent = 'current'});
end);


NPL.export(router);