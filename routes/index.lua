local express = NPL.load('express');
local cookie = express.Cookie;
local router = express.Router:new();


router:get('/', function(req, res, next)
	-- cookie 示例
	local c = cookie:new({
		name = 'myname',
		value = 'caoyongfeng'
	});
	res:appendCookie(c);

	-- session 示例
	req.session:set({
		name = 'myname',
		value = 'abcdefg',
		maxAge = 120
	});

	res:render('index', { id = 100 });
end);


NPL.export(router);