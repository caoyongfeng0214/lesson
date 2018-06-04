--[[
	Author: CYF
	Date: 2018年4月17日
	EMail: me@caoyongfeng.com
	Desc: Lesson Project
]]
local express = NPL.load('express');
local cors = NPL.load('cors');
local app = express:new();
local lang_cn = NPL.load('./confi/language/string_cn');
local lang_en = NPL.load('./confi/language/string_en');

app:set('views', 'views');
app:set('view engine', 'lustache');

app:use(cors(function(req, res)
	local url = req.url;
	return url:startsWith('/api/');
end, {
	is_current_origin = true
}));


app:use(function(req, res, next)
	-- 因为keepwork调用接口需要用到cookie，这样需要返回更具体的允许主机
	local host = req['Origin'] or '';
	-- if string.find(host, 'keepwork.com') then
		res:setHeader('Access-Control-Allow-Origin', host);
		res:setHeader('Access-Control-Allow-Credentials', 'true');		
	-- end
	next(req, res, next);
end);

app:use(express.static('public'));
app:use(express.session());

app:use(function(req, res, next)
	local url = req.url;
	if not (url:startsWith('/api/') or url:startsWith('/imgs/') or url:startsWith('/css/') or url:startsWith('/js/') or url:startsWith('/jslib/') or url:startsWith('/csslib/') or url:startsWith('/icons/')or url:startsWith('/uploads/') ) then
		-- 初始化
		res.__data__ = {};
		-- 获取 Accect Language，优先 Cookie 设置， 然后 Accect Language， 最后默认 en
		local resource = lang_en; -- 缺省值
		local langStr = 'EN'; -- 缺省值
		local lang  = req.cookies.language;
		local accectLang = req["Accept-Language"];
		if(lang) then
			if(lang.value == 'en') then
				resource = lang_en;
				langStr = 'EN';
			elseif(lang.value == 'cn') then
				resource = lang_cn;
				langStr = 'CN';
			end
		elseif( accectLang ) then
			if( accectLang:startsWith('zh-CN') ) then
				resource = lang_cn;
				langStr = 'CN';
			elseif( accectLang:startsWith('en-US') ) then
				resource = lang_en;
				langStr = 'EN';
			end
		end
		res.__data__.string = resource;
		res.__data__.language = langStr;
	end
	next(req, res, next);
end);

-- ***********************************************************************
-- ****** API ******
-- ***********************************************************************
local class = NPL.load('./api/class');
app:use('/api/class', class);

local member = NPL.load('./api/member');
app:use('/api/member', member);

local testrecord = NPL.load('./api/testrecord');
app:use('/api/record', testrecord);

local orders = NPL.load('./api/orders');
app:use('/api/order', orders);

local package = NPL.load('./api/package');
app:use('/api/package', package);

local subscribe = NPL.load('./api/subscribe');
app:use('/api/subscribe', subscribe);

local cdkey = NPL.load('./api/cdkey');
app:use('/api/cdkey', cdkey);

local router_index = NPL.load('./routes/index');
app:use('/', router_index);
app:use('/index', router_index);

-- 我的记录
local router_my_record = NPL.load('./routes/myRecord');
app:use('/myRecord', router_my_record);

-- 授课记录 & 自学记录
local router_record_list = NPL.load('./routes/recordList');
app:use('/recordList', router_record_list);

-- 自学记录 - 详情页
local router_record_learned = NPL.load('./routes/learnedRecord');
app:use('/learnedRecord', router_record_learned);

-- 授课记录 - 详情页
local router_record_taughted = NPL.load('./routes/taughtedRecord');
app:use('/taughtedRecord', router_record_taughted);

local router_buy = NPL.load('./routes/buy');
app:use('/buy', router_buy);

local router_lesson = NPL.load('./routes/lesson');
app:use('/lesson', router_lesson);

-- ***********************************************************************
-- ****** 无法匹配URL的页面 ******
-- ***********************************************************************
app:use(function(req, res, next)
	res:setStatus(404);
	res:send({err = 404});
end);



NPL.export(app);