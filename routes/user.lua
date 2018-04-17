local express = NPL.load('express');
local router = express.Router:new();


router:get('/', function(req, res, next)
	
	local user = {
		id = 1,
		name = 'cyf',
		gender = '男'
	};

	-- table 会被转为 JSON
	res:send(user);
end);


NPL.export(router);