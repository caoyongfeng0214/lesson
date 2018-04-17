-- lustache: Lua mustache template parsing.
-- Copyright 2013 Olivine Labs, LLC <projects@olivinelabs.com>
-- MIT Licensed.

local config = require('./config');
local string_gmatch = string.gmatch

function string.split(str, sep)
  local out = {}
  for m in string_gmatch(str, "[^"..sep.."]+") do out[#out+1] = m end
  return out
end

local lustache = {
  name     = "lustache",
  version  = "1.3.1-0",
  -- extension = '.mustache',
  config = function(cnf)
	if(cnf) then
		for k, v in pairs(cnf) do
			if(k == 'views') then
				local lstChar = string.sub(v, -1);
				if(lstChar ~= '/' and lstChar ~= '\\') then
					v = v .. '/';
				end
			end
			config[k] = v;
		end
	else
		return config;
	end
  end,
  renderer = require("./renderer"):new()
}

return setmetatable(lustache, {
  __index = function(self, idx)
    if self.renderer[idx] then return self.renderer[idx] end
  end,
  __newindex = function(self, idx, val)
    if idx == "partials" then self.renderer.partials = val end
    if idx == "tags" then self.renderer.tags = val end
  end
})
