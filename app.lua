--[[
	Author: CYF
	Date: 2018年4月17日
	EMail: me@caoyongfeng.com
	Desc: Lesson Project
]]
local express = NPL.load('express');
local cors = NPL.load('cors');
local app = express:new();

app:set('views', 'views');
app:set('view engine', 'lustache');

app:use(cors(function(req, res)
	local url = req.url;
	return url:startsWith('/api/');
end, {
	is_current_origin = true
}));

app:use(express.static('public'));
app:use(express.session());

-- ***********************************************************************
-- ****** API ******
-- ***********************************************************************

-- ------ 用户 -----------------------------------------------------------
local class = NPL.load('./api/class');
app:use('/api/class', class);

local member = NPL.load('./api/member');
app:use('/api/member', member);

local router_news = NPL.load('./routes/news');
app:use('/news/:id', router_news);

local router_user = NPL.load('./routes/user');
app:use('/user', router_user);

local router_upload = NPL.load('./routes/upload');
app:use('/upload', router_upload);

local router_index = NPL.load('./routes/index');
app:use('/', router_index);

-- ***********************************************************************
-- ****** 无法匹配URL的页面 ******
-- ***********************************************************************
app:use(function(req, res, next)
	res:setStatus(404);
	res:send({err = 404});
end);



NPL.export(app);