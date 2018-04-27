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
local class = NPL.load('./api/class');
app:use('/api/class', class);

local member = NPL.load('./api/member');
app:use('/api/member', member);

local testrecord = NPL.load('./api/testrecord');
app:use('/api/record', testrecord)

local orders = NPL.load('./api/orders')
app:use('/api/order', orders)

local router_my_record = NPL.load('./routes/myRecord');
app:use('/myRecord', router_my_record);

local router_record_list = NPL.load('./routes/recordList');
app:use('/recordList', router_record_list);

local router_record_learned = NPL.load('./routes/learnedRecord');
app:use('/learnedRecord', router_record_learned);

-- ***********************************************************************
-- ****** 无法匹配URL的页面 ******
-- ***********************************************************************
app:use(function(req, res, next)
	res:setStatus(404);
	res:send({err = 404});
end);



NPL.export(app);