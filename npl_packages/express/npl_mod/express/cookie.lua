local config = NPL.load('./config.lua');

local cookie = {};


--[[
	name
	value
	maxAge
	path
	domain
	secure
]]
function cookie:new(o)
	o = o or {};
	if(not o.path) then
		o.path = '/';
	end
	if(o.maxAge == nil) then
		o.maxAge = config.cookieAge;
	end
	setmetatable(o, self);
	self.__index = self;
	return o;
end


cookie.parse = function(str)
	local items = str:split('; ');
	local i = 1;
	local cookies = {};
	for i = 1, #items do
		local item = items[i];
		local ary = item:split('=');
		cookies[ary[1]] = cookie:new({
			name = ary[1],
			value = ary[2]
		});
	end
	return cookies;
end;


function cookie:toString()
	local str = string.format('Set-Cookie: %s=%s;Max-Age=%d;path=%s', self.name, self.value, self.maxAge, self.path);
	if(self.domain) then
		str = str .. ';domain=' .. self.domain;
	end
	if(self.secure) then
		str = str .. ';secure=true';
	end
	str = str .. '\r\n';
	return str;
end


NPL.export(cookie);