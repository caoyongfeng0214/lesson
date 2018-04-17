--[[
	Author: CYF
	Date: 2017年1月30日
	EMail: me@caoyongfeng.com
	Desc: 一个Web应用框架

	TODO:
		cookie (done)
		session (done)
		params => query body (done)
		static files (done)
		views (done)
		error
		redirect
		status 304
		template extend
		less sass
]]

NPL.load('common');
local mime = NPL.load('mime');
local router = NPL.load('./router.lua');
local config = NPL.load('./config.lua');
local cookie = NPL.load('./cookie.lua');
local session = NPL.load('./session.lua');
local handler = NPL.load('./handler.lua');
local request = NPL.load('./request.lua');
local response = NPL.load('./response.lua');


local express = {};

function express:new(o)
	o = o or {};
	setmetatable(o, self);
	self.__index = self;
	return o;
end

express.Router = router;
express.Cookie = cookie;
express.session = session.handler;
express.config = config;
express.handler = handler;
express.request = request;
express.response = response;


function express:address()
	return { ip = config.ip, port = config.port };
end


function express:set(key, val)
	config[key] = val;
	if((key == 'views' and config['view engine'])
		or (key == 'view engine' and config['views'])) then
		local engine = NPL.load(config['view engine']);
		if(engine.config) then
			engine.config({
				views = config['views'];
			});
		end
	end
end


function express:get(key)
	return config[key];
end


function express:use(...)
	router.add({...});
end


function express.static(staticDirectory, conf)
	config['public'] = staticDirectory;
	if(conf) then
		for k, v in pairs(conf) do
			config[k] = v;
		end
	end
	return function(req, res, next)
		local path = staticDirectory .. req.pathname;
		local len = #path;
		if(path:sub(len, len) == '/') then
			path = path .. config['default'];
		end
		if(req.method == 'GET' and ParaIO.DoesFileExist(path)) then
			local extention = path:match('^.+%.([a-zA-Z0-9]+)$');
			if(extention) then -- 目前用有无文件扩展名来判断是否是文件夹，这种方法是不保险的，应该改进
				local mimeType = mime.get(extention);
				res:setContentType(mimeType);
				local f = ParaIO.open(path, 'r');

				-- TODO: 判断是文件还是文件夹
				-- local ifs = require "lfs";

				if(mime.isPlainTextType(mimeType)) then
					local text = f:GetText();
					f:close();
					res:send(text);
				else
					local s = f:ReadString(f:GetFileSize());
					f:close();
					res:send(s);
				end
			else
				next(req, res, next);
			end
		else
			next(req, res, next);
		end
	end;
end


function express:listen(port)
	if(__rts__:GetName() == 'main') then
		if(port) then
			self:set('port', '' .. port);
		end

		handler.initChildThreads();

		local _from_path = debug.getinfo(2,'S').source;
		for k, v in pairs(handler.threads) do
			NPL.activate(string.format("(%s)" .. _from_path, v.name), {
				___initChildThread = true
			});
		end
		
		--NPL.AddPublicFile(debug.getinfo(1,'S').source:match('^@%.[/\\](.+[/\\])[^/\\]+$') .. 'handler.lua', -10);
		NPL.AddPublicFile(debug.getinfo(1,'S').source:match('^[@%./\\]*(.+[/\\])[^/\\]+$') .. 'handler.lua', -10);
		NPL.StartNetServer(self:get('ip'), self:get('port'));
	end
    return self;
end




NPL.export(express);