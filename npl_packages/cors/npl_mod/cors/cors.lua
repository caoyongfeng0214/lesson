NPL.load('common');
local cors = {};


local configureOrigin = function(req, res, cnf)
	if(not cnf.origin or cnf.origin == '*') then
		res:setHeader('Access-Control-Allow-Origin', '*');
	else
		local ty = type(cnf.origin);
		if(ty == 'string') then
			res:setHeader('Access-Control-Allow-Origin', cnf.origin);
			-- res:setHeader('Vary', 'Origin');
		elseif(ty == 'table') then
			res:setHeader('Access-Control-Allow-Origin', string.join(',', cnf.origin));
			-- res:setHeader('Access-Control-Allow-Origin', 'false');
			-- res:setHeader('Vary', 'Origin');
		end
	end
end;


local configureCredentials = function(req, res, cnf)
	if(cnf.credentials) then
		res:setHeader('Access-Control-Allow-Credentials', 'true');
	end
end


local configureMethods = function(req, res, cnf)
	local methods = cnf.methods;
	if(not methods) then
		methods = 'GET,HEAD,PUT,PATCH,POST,DELETE';
	else
		local ty = type(methods);
		if(ty == 'table') then
			methods = string.join(',', methods);
		end
	end
	res:setHeader('Access-Control-Allow-Methods', methods);
end


cors.handler = function(fn, cnf)
	local ty = type(fn);
	if(ty == 'function') then
		
	elseif(ty == 'table') then
		cnf = fn;
		fn = nil;
	end
	if(not cnf) then
		cnf = {};
	end
	return function(req, res, next)
		local allow = true;
		if(fn) then
			allow = fn(req, res);
		end
		if(allow) then
			configureOrigin(req, res, cnf);
			configureCredentials(req, res, cnf);
			configureMethods(req, res, cnf);
			if(req.method == 'OPTIONS') then
				res:setStatus(204);
				res:send();
			else
				next(req, res, next);
			end
		else
			next(req, res, next);
		end
	end;
end


return cors.handler;