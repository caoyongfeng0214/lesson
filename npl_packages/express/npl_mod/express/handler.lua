local request = NPL.load('./request.lua');
local router = NPL.load('./router.lua');
local config = NPL.load('./config.lua');
--local theads = NPL.load('(main)./theads.lua');

--NPL.load("(worker1)script/ide/System/Concurrent/rpc.lua");
--local rpc = commonlib.gettable("System.Concurrent.Async.rpc");

local handler = {};


handler.initChildThreads = function()
	if(not handler.threads) then
		handler.threads = {};
		local i = 1;
		for i = 1, config.threadCnt do
			local name = 'worker_' .. i;
			local thread = NPL.CreateRuntimeState(name, 0);
			handler.threads[name] = {
				name = name,
				queue = 0,
				thread = thread
			};
			thread:Start();
		end
	end
end;

handler.selectThread = function()
	handler.initChildThreads();
	local min = nil;
	local selected_thread = nil;
	--local k, v;
	--for k, v in pairs(handler.threads) do
	--	if(v.queue <= 0) then
	--		selected_thread = v;
	--		break;
	--	else
	--		if(min == nil or v.queue < min) then
	--			min = v.queue;
	--			selected_thread = v;
	--		end
	--	end
	--end
	local _i = 1;
	for _i = 1, config.threadCnt do
		local _k = 'worker_' .. _i;
		local _item = handler.threads[_k];
		if(_item.queue <= 0) then
			selected_thread = _item;
			break;
		else
			if(min == nil or _item.queue < min) then
				min = _item.queue;
				selected_thread = _item;
			end
		end
	end
	selected_thread.queue = selected_thread.queue + 1;
	return selected_thread;
end


handler.shareData = function(action, data)
	local _from_path = debug.getinfo(2,'S').source;
	local _cur_thread = __rts__:GetName();
	--local _thread = handler.selectThread();
	NPL.activate(string.format("(%s)" .. debug.getinfo(1,'S').source:match('^[@%./\\]*(.+[/\\])[^/\\]+$') .. 'handler.lua', 'main'), {
		___isshare = true,
		___action = action,
		___data = data,
		___source = _from_path,
		___fromthread = _cur_thread
	});
end


handler.recvConnection = function(msg)
    local thread = handler.selectThread();
	msg.___threadname = thread.name;
	msg.___isreq = true;
	NPL.activate(string.format("(%s)" .. debug.getinfo(1,'S').source:match('^[@%./\\]*(.+[/\\])[^/\\]+$') .. 'handler.lua', thread.name), msg);
end


local function activate()
	if(msg.___threadend) then
		local thread = handler.threads[msg.___threadname];
		if(thread) then
			thread.queue = thread.queue - 1;
			if(thread.queue < 0) then
				thread.queue = 0;
			end
		end
	elseif(msg.___threadname) then
		if(msg.___isreq) then
			local req = request:new(msg);
			router.match(req);
		elseif(msg.___isshare) then
			if(msg.___set and msg.___source and msg.___action) then
				local _f = NPL.load(msg.___source)[msg.___action];
				if(_f and type(_f) == 'function') then
					_f(msg.___data);
				end
                if(__rts__:GetName() == 'main') then
                    local thread = handler.threads[msg.___threadname];
		            if(thread) then
			            thread.queue = thread.queue - 1;
			            if(thread.queue < 0) then
				            thread.queue = 0;
			            end
		            end
                end
			elseif(msg.___share and msg.___threadcnt) then
				msg.___set = true;
				local _i = 1;
                local _path = "(%s)" .. debug.getinfo(1,'S').source:match('^[@%./\\]*(.+[/\\])[^/\\]+$') .. 'handler.lua';
				for _i=1, msg.___threadcnt do
					local _threadname = 'worker_' .. _i;
					if(_threadname ~= msg.___fromthread) then
						NPL.activate(string.format(_path, _threadname), msg);
					end
				end
                NPL.activate(string.format(_path, 'main'), msg);
				--NPL.activate(string.format("(%s)" .. debug.getinfo(1,'S').source:match('^[@%./\\]*(.+[/\\])[^/\\]+$') .. 'handler.lua', 'main'), {
				--	___threadend = true,
				--	___threadname = msg.___threadname
				--});
			end
		end
	elseif(msg.___isshare) then
		local _thread = handler.selectThread();
		msg.___share = true;
		msg.___threadcnt = config.threadCnt;
		msg.___threadname = _thread.name;
		NPL.activate(string.format("(%s)" .. debug.getinfo(1,'S').source:match('^[@%./\\]*(.+[/\\])[^/\\]+$') .. 'handler.lua', _thread.name), msg);
	else
		handler.recvConnection(msg);
	end
end


NPL.this(activate);

return handler;