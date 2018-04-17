
local route = {};

function route:new(o)
	o = o or {};
	setmetatable(o, self);
	self.__index = self;
	return o;
end

--return route;
NPL.export(route);