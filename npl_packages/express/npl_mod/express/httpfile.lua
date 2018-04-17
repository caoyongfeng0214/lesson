local cnf = NPL.load('./config.lua');

local httpfile = {};

httpfile.__dt = 0;
httpfile.__n = 0;


function httpfile:new(o)
	o = o or {};
	setmetatable(o, self);
	self.__index = self;
	o.extention = o.filename:match('^.+(%.[a-zA-Z0-1]+)$');
	o.basename = o.filename;
	if(o.extention) then
		o.basename = o.basename:sub(1, #(o.basename) - #(o.extention));
	end
	return o;
end


function httpfile:saveAs(target_dir, filename)
	if(not target_dir) then
		target_dir = cnf.upload_dir;
	end
	local lstchar = target_dir:sub(-1);
	if(lstchar ~= '/' and lstchar ~= '\\') then
		target_dir = target_dir .. '/';
	end
	ParaIO.CreateDirectory(target_dir);

	if(not filename) then
		local dt = os.time();
		if(dt ~= httpfile.__dt) then
			httpfile.__dt = dt;
			httpfile.__n = 0;
		end
		httpfile.__n = httpfile.__n + 1;
		filename = string.format('%s_%s', dt, httpfile.__n);
		if(self.extention) then
			filename = filename .. self.extention;
		end
	end

	local path = target_dir .. filename;

	local file = ParaIO.open(path, 'w');
	if(file:IsValid()) then
		file:write(self.content, #(self.content));
		file:close();
		return {filename = filename, size = self.size, contentType = self.contentType, srcname = self.filename};
	else
		return {err = 'can not create file on disk. file name invalid or disk is full.'};
	end
end


NPL.export(httpfile);