local sessionitem = NPL.load('./sessionitem.lua');
local cookie = NPL.load('./cookie.lua');
local handler = NPL.load('./handler.lua');

local session = {};

session.__dt = 0;
session.__n = 0;

function session:new(req, res)
	local o = {
		req = req,
		res = res
	};
	setmetatable(o, self);
	self.__index = self;
	return o;
end


function session:get(name)
	if(session.data) then
		local cookieKey = '___npl_express_sid_' .. name:encodeURI();
		local cookie = self.req.cookies[cookieKey];
		if(cookie) then
			local sessionKey = cookie.value;
			local session_item = session.data[sessionKey];
			if(session_item == nil) then
				local c = cookie:new({
					name = cookieKey,
					maxAge = -1
				});
				self.res:appendCookie(c);
			end
			return session_item;
		end
	end
	return nil;
end;


function session:set(obj)
	if(obj.name) then
		local cookieKey = '___npl_express_sid_' .. obj.name:encodeURI();
		local ck = self.req.cookies[cookieKey];
		local sessionKey = nil;
		local session_item = nil;
		
		if(ck) then
			sessionKey = ck.value;
			if(session.data) then
				session_item = session.data[sessionKey];
			end
		else
			local dt = os.time();
			if(dt ~= session.__dt) then
				session.__dt = dt;
				session.__n = 0;
			end
			session.__n = session.__n + 1;
			sessionKey = string.format('%s_%s_%s', __rts__:GetName(), dt, session.__n);
		end

		if(session_item) then
			if(session_item.__timer__) then
				clearTimeout(session_item.__timer__);
			end
		end

		obj.__name__ = sessionKey;
		obj.__cookie__ = cookieKey;
		session_item = sessionitem:new(obj);
		local cookie_item = cookie:new({
			name = cookieKey,
			value = sessionKey,
			maxAge = session_item.maxAge,
			path = session_item.path,
			domain = session_item.domain
		});
		self.res:appendCookie(cookie_item);
		--if(not session.data) then
		--	session.data = {};
		--end
		--session.data[sessionKey] = session_item;
		session._set({
			key = sessionKey,
			val = session_item
		});
		handler.shareData('_set', {
			key = sessionKey,
			val = session_item
		});
		local MAXT = 3600;
		local function timerFun(seconds)
			local sub = seconds - MAXT;
			local s = seconds;
			if(sub > 0) then
				s = MAXT;
			end
			session_item.__timer__ = setTimeout(function()
				if(sub > 0) then
					timerFun(sub);
				else
					session.data[sessionKey] = nil;
					handler.shareData('_set', {
						key = sessionKey
					});
				end
			end, s * 1000);
		end;
		timerFun(cookie_item.maxAge);

		--session_item.__timer__ = setTimeout(function()
		--	print('session TIMEOUT..........................');
		--	print(cookie_item.maxAge);
		--	session.data[sessionKey] = nil;
		--end, cookie_item.maxAge * 1000);
	end
	return session;
end;



function session:remove(name)
	local cookieKey = '___npl_express_sid_' .. name:encodeURI();
	local cookie = self.req.cookies[cookieKey];
	local sessionKey = nil;
	local session_item = nil;
		
	if(cookie) then
		sessionKey = cookie.value;
		local c = cookie:new({
			name = cookieKey,
			maxAge = -1
		});
		self.res:appendCookie(c);

		if(session.data) then
			session_item = session.data[sessionKey];
			if(session_item) then
				if(session_item.__timer__) then
					clearTimeout(session_item.__timer__);
				end
				session.data[sessionKey] = nil;
				handler.shareData('_set', {
					key = sessionKey
				});
			end
		end
	end

	
end


session.handler = function(cnf)
	sessionitem.cnf = cnf or {};
	return function(req, res, next)
		req.session = session:new(req, res);
		next(req, res, next);
	end;
end;



session._set = function(obj)
	if(obj.key) then
		if(not session.data) then
			session.data = {};
		end
		session.data[obj.key] = obj.val;
	end
end;



NPL.export(session);