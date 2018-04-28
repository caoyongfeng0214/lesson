local express = NPL.load('express');
local cookie = express.Cookie;
local router = express.Router:new();


router:get('/', function(req, res, next)
	res:render('index',{
		homeCurrent = 'current'
	});
end);


NPL.export(router);