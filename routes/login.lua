NPL.load("(gl)script/ide/commonlib.lua")
local express = NPL.load('express')
local router = express.Router:new();

router:get('/', function(req, res, next)
	res:render('keepwork_login',req.query);
end);

NPL.export(router);