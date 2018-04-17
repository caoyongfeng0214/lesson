local config = NPL.load('./config.lua');

local sessionitem = {};


--[[
	name
	value
	maxAge
	domain
]]
function sessionitem:new(o)
	o = o or {};
	o.path = '/';
	if(o.maxAge == nil) then
		o.maxAge = sessionitem.cnf.maxAge or config.cookieAge;
	end
	if(o.domain == nil) then
		o.domain = sessionitem.cnf.domain or config.domain;
	end
	setmetatable(o, self);
	self.__index = self;
	return o;
end



NPL.export(sessionitem);