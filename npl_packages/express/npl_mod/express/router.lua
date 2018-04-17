--local response = require('./response');
local response = NPL.load('./response.lua');

local router = {};

router.middlewares = {};

router.routes = {};


function router:new(o)
	o = o or {};
	o.childs = {};
	o.middlewares = {};
	o.name = '__express_router';
	setmetatable(o, self);
	self.__index = self;
	self:setPath(o.path);
	return o;
end


router.makePathAry = function(path)
	local pathary = {};
	local endseparator = false;
	local plen = #(path);
	if(path:sub(plen, plen) == '/') then
		path = path:sub(1, -2);
		endseparator = true;
	end
	for v in path:gmatch('[/]([^/]+)') do
		if(v:sub(1, 1) == ':') then
			v = {param = v:sub(2)};
		end
		pathary[#(pathary) + 1] = v;
	end
	return pathary;
end;


router.addRouter = function(rs, mids, arg)
	local len = #arg;
	if(len > 0) then
		local ary1ty = type(arg[1]);
		if(ary1ty == 'string') then
			local path = arg[1];
			local handler = arg[2];
			local method = arg[3];
			table.insert(rs, {path = path, pathary = router.makePathAry(path), handler = handler, method = method});
		elseif(ary1ty == 'table' or ary1ty == 'function') then
			table.insert(rs, arg[1]);
		end
	end
end;


router.add = function(arg)
	router.addRouter(router.routes, router.middlewares, arg);
end


router._match = function(pathary, routes, mids, req, res, parentNext)
	local idx = 0;
	function next()
		idx = idx + 1;
		local r = routes[idx];
		if(r) then
			local rtype = type(r);
			if(rtype == 'function') then
				r(req, res, next);
			else
				if(not r.method or r.method == req.method) then
					local len0 = #(r.pathary);
					local len1 = #(pathary);
					if(len0 <= len1) then
						local params = {};
						local matchn = 0;
						for i = 1, len0 do
							local v0 = r.pathary[i];
							local v1 = pathary[i];
							if(type(v0) == 'string') then
								if(v0 == v1) then
									matchn = matchn + 1;
								else
									break;
								end
							else
								params[v0.param] = v1;
								matchn = matchn + 1;
							end
						end
						if(matchn == len0) then
							req._params = req._params or {};
							req._params[#(req._params) + 1] = params;
							req.params = req.params or {};
							if(req._params) then
								for i = 1, #(req._params) do
									local _ps = req._params[i];
									for k, v in pairs(_ps) do
										req.params[k] = v;
									end
								end
							end
							local ty = type(r.handler);
							if(ty == 'table') then
								local ary = {};
								for i = len0 + 1, len1 do
									table.insert(ary, pathary[i]);
								end
								router._match(ary, r.handler.childs, r.handler.middlewares, req, res, next);
							elseif(ty == 'function' and matchn == len1) then
								r.handler(req, res, next);
							else
								next();
							end
						else
							next();
						end
					else
						next();
					end
				else
					next();
				end
			end
		elseif(parentNext) then
			if(req._params) then
				table.remove(req._params, #(req._params));
				for i = 1, #(req._params) do
					local _ps = req._params[i];
					for k, v in pairs(_ps) do
						req.params[k] = v;
					end
				end
			end
			parentNext();
		end
	end;
	next();

--	req.params = {id = 10};
--	if(#pathary == 2) then
--		--router.routes[2].handler.childs[1].handler(req, res);
--		res:send('<html><head><title>Two</title></head><body>Hello World<div><a href="/">去第一页</a></div></body></html>');
--	else
--		--router.routes[1].handler.childs[1].handler(req, res);
--		res:send('<html><head><title>One</title></head><body>这是一个测试页<div><a href="/news/10">去第二页</a></div></body></html>');
--	end
end


router.match = function(req)
	local path = req.pathname;
	local pathary = router.makePathAry(path);

	local res = response:new(req);
	
	router._match(pathary, router.routes, router.middlewares, req, res);
end;


function router:setPath(path)
	if(path) then
		self.path = path;
		self.pathary, endseparator = router.makePathAry(self.path);
		if(endseparator) then
			self.path = self.path:sub(1, #(self.path) - 2);
		end
	else
		self.pathary = {};
	end
end


function router:get(path, fn)
	router.addRouter(self.childs, self.middlewares, {path, fn, 'GET'});
end;


function router:post(path, fn)
	router.addRouter(self.childs, self.middlewares, {path, fn, 'POST'});
end


function router:delete(path, fn)
	router.addRouter(self.childs, self.middlewares, {path, fn, 'DELETE'});
end


function router:put(path, fn)
	router.addRouter(self.childs, self.middlewares, {path, fn, 'PUT'});
end


function router:use(...)
	router.addRouter(self.childs, self.middlewares, {...});
end


function router:handle(pathary, req, res, next)
		if(type(pathary) == 'string') then
			pathary = router.makePathAry(pathary);
		end
		local len0 = #(self.pathary);
		local len1 = #(pathary);
		--if(len0 <= len1) then
			local params = {};
			local matchn = 0;
			for i = 1, len0 do
				local v0 = self.pathary[i];
				local v1 = pathary[i];
				if(type(v0) == 'string') then
					if(v0 == v1) then
						matchn = matchn + 1;
					else
						break;
					end
				else
					params[v0.param] = v1;
					matchn = matchn + 1;
				end
			end
			
			--if(matchn == len0) then
				req.params = req.params or {};
				for k, v in pairs(params) do
					req.params[k] = v;
				end

				local ary = {};
				for i = len0 + 1, len1 do
					table.insert(ary, pathary[i]);
				end
				self:matchChilds(ary, req, res, next);
			--else
				next();
			--end
		--else
		--	next();
		--end
end


function router:matchChilds(pathary, req, res, parentNext)
	router._match(pathary, self.childs, req, res, parentNext);
end


--return router;
NPL.export(router);