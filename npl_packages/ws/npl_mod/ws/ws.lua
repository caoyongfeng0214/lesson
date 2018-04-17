NPL.load('common');
local connection = NPL.load('./connection');
local ws = {};


ws.Server = {};

ws.Server.__connection_public_added__ = false;

_G.__ws__ = ws;

function ws.Server:new(o)
    o = o or {};
	setmetatable(o, self);
	self.__index = self;
    self._on = {};
    if(o.server) then
        local _self = self;
        local _recvConnection = o.server.handler.recvConnection;
        o.server.handler.recvConnection = function(msg)
            local key = msg['Sec-WebSocket-Key'];
            if(key) then
                local req = o.server.request:new(msg);
                local res = o.server.response:new(req);
                o.server.session()(req, res, function() end);
                if(not ws.Server.__connection_public_added__) then
                    ws.Server.__connection_public_added__ = true;
                    NPL.AddPublicFile(debug.getinfo(1,'S').source:match('^[@%./\\]*(.+[/\\])[^/\\]+$') .. 'connection.lua', -20);
                    
                    NPL.RegisterEvent(0, '_n_gameserver_network', ';__ws__.Server.connectionEvent();');
                end
                key = key .. '258EAFA5-E914-47DA-95CA-C5AB0DC85B11';
                key = NPL.load('sha1')(key, 'base64');
                res:setStatus(101);
                res:setHeader('Connection', 'Upgrade');
                res:setHeader('Upgrade', 'websocket');
                res:setHeader('Sec-WebSocket-Accept', key);
                res:sendHeaders();
                NPL.SetProtocol(req.nid or req.tid, 1);

             --   local att = NPL.GetAttributeObject();
	            --att:SetField("KeepAlive", true);
             --   att:SetField("IdleTimeout", true);
                
                local cn = connection:new(msg);
                cn.request = req;
                if(_self._on.connection) then
                    _self._on.connection(cn, req);
                end
            else
                _recvConnection(msg);
            end
        end;
    end
	return o;
end;


function ws.Server:on(evtName, fn)
    self._on[evtName] = fn;
end


ws.Server.connectionEvent = function()
    connection.onRecvEventMsg(msg);
end;


return ws;