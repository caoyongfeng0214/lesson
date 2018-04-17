--require('commonlib');
--require('json');
NPL.load('script/ide/commonlib.lua');
NPL.load('script/ide/Json.lua');
--local mime = require('mime');
local mime = NPL.load('mime');
--local config = require('./config');
local config = NPL.load('./config.lua');


local status_strings = {
    ['101'] = "HTTP/1.1 101 Switching Protocols\r\n",
    ['200'] ="HTTP/1.1 200 OK\r\n",
    ['201'] ="HTTP/1.1 201 Created\r\n",
    ['202'] ="HTTP/1.1 202 Accepted\r\n",
    ['204'] = "HTTP/1.1 204 No Content\r\n",
    ['300'] = "HTTP/1.1 300 Multiple Choices\r\n",
    ['301'] = "HTTP/1.1 301 Moved Permanently\r\n",
    ['302'] = "HTTP/1.1 302 Moved Temporarily\r\n",
    ['304'] = "HTTP/1.1 304 Not Modified\r\n",
    ['400'] = "HTTP/1.1 400 Bad Request\r\n",
    ['404'] = "HTTP/1.1 401 Unauthorized\r\n",
    ['403'] = "HTTP/1.1 403 Forbidden\r\n",
    ['404'] = "HTTP/1.1 404 Not Found\r\n",
    ['500'] = "HTTP/1.1 500 Internal Server Error\r\n",
    ['501'] = "HTTP/1.1 501 Not Implemented\r\n",
    ['502'] = "HTTP/1.1 502 Bad Gateway\r\n",
    ['503'] = "HTTP/1.1 503 Service Unavailable\r\n",
};


local response = {};


function response:new(req)
	local o = {};
	setmetatable(o, self);
	self.__index = self;
	self.request = req;
	self.charset = 'utf-8';
	self.status = '200';
	self.contentType = mime.html;
	self.headers = {
		--['status'] = '200',
		['Content-Type'] = mime.html
	};
	return o;
end


function response:setStatus(status)
	-- self.headers['status'] = '' .. status;
	self.status = '' .. status;
end


function response:setContentType(mimeType)
	self.contentType = mimeType;
	-- self.headers['Content-Type'] = mimeType .. ';charset=' .. self.charset;
	self:setHeader('Content-Type', mimeType .. ';charset=' .. self.charset);
end


function response:setCharset(charset)
	self.charset = charset;
	-- self.headers['Content-Type'] = mimeType .. ';charset=' .. self.charset;
	self:setHeader('Content-Type', self.contentType .. ';charset=' .. self.charset);
end


function response:setContent(data)
	self.data = data;
	-- self.headers['Content-Length'] = #data;
	self:setHeader('Content-Length', #data);
end


function response:setHeader(key, val)
	self.headers[key] = val;
end


function response:onBefore()

end


function response:onAfter()

end


function response:appendCookie(cookie)
	if(not self.cookies) then
		self.cookies = {};
	end
	self.cookies[#(self.cookies) + 1] = cookie;
end



function response:sendHeaders()
    local out = {};
    out[#out+1] = status_strings[self.status];

    for name, value in pairs(self.headers) do
        out[#out+1] = format("%s: %s\r\n", name, value);
    end

    out[#out+1] = "\r\n";
    -- out[#out+1] = self.data;

    NPL.activate(format("%s:http", self.request.nid), table.concat(out));
end



function response:_send()
	local out = {};
    out[#out+1] = status_strings[self.status];

    for name, value in pairs(self.headers) do
        out[#out+1] = format("%s: %s\r\n", name, value);
    end

	if(self.cookies) then
		local i = 1;
		for i = 1, #(self.cookies) do
			local cookie = self.cookies[i];
			out[#out + 1] = cookie:toString();
		end
	end

    out[#out+1] = "\r\n";
    out[#out+1] = self.data;

    NPL.activate(format("%s:http", self.request.nid), table.concat(out));
	
	NPL.activate(string.format("(%s)" .. debug.getinfo(1,'S').source:match('^[@%./\\]*(.+[/\\])[^/\\]+$') .. 'handler.lua', 'main'), {
		___threadend = true,
		___threadname = self.request.___threadname
	});
end



function response:send(data)
	if(not data) then
		data = self.data;
	end
	local ty = type(data);
	if(ty == 'table') then
		data = commonlib.Json.Encode(data);
		self:setContentType(mime.json);
	elseif(ty ~= 'string') then
		data = tostring(data);
	end

	self:setContent(data);

	self:_send();
end;


function response:render(templateUrl, data)
	local templateEngine = require(config['view engine']);
--	local templateFile = ParaIO.open(config['views'] .. '/' .. templateUrl .. templateEngine.config().extension, 'r'); -- TODO: ��Ϊ�첽
--	local template = templateFile:GetText();
--	templateFile:close();
--
	-- local content = templateEngine:render(template, data);

	-- local content = templateEngine:renderFile(templateUrl, data);

	--print('response response response response ');
	--print(#content);

	if(self.__data__) then
        if(not data) then
            data = {};
        end
        data.__data__ = self.__data__;
    end
	local content = templateEngine:renderFile(templateUrl, data);
	self:setContent(content);
	self:_send();
end


function response:redirect(url)
	self:setStatus(302);
	self:setHeader('Location', url);
	self:send('');
end

-- return response;

NPL.export(response);