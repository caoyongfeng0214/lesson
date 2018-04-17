local config = require('./config');

local templateHelper = {
	cachedData = {},
};


templateHelper.get = function(path)
	if(config.views) then
		path = config.views .. path;
	end

	if(config.extension) then
		path = path .. config.extension;
	end

	local content = templateHelper.cachedData[path];
	if(not content) then
		local file = io.open(path, 'r');
		if(file) then
			content = file:read('*a');
			file:close();
			templateHelper.cachedData[path] = content;
		end
	end

    return content
end;


return templateHelper;
