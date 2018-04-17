local express = NPL.load('express');
local cookie = express.Cookie;
local router = express.Router:new();


router:get('/', function(req, res, next)
	
	-- 删除 cookie 示例
	local c = cookie:new({
		name = 'myname',
		maxAge = -1
	});
	res:appendCookie(c);

	-- 读 session 示例
	local s = req.session:get('myname');
	local v = nil;
	if(s) then
		v = s.value;
	end

	-- URL 传递的参数
	local param_id = req.params.id;

	res:render('news', {id = req.params.id, session = v});
end);


NPL.export(router);