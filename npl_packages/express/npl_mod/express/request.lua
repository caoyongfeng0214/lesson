NPL.load("(gl)script/ide/Json.lua");
local httpfile = NPL.load('./httpfile.lua');
local cookie = NPL.load('./cookie.lua');


-- Host localhost:3000
-- rcode 0
-- Connection keep-alive
-- Accept text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
-- Cache-Control max-age=0
-- Accept-Encoding gzip, deflate, sdch, br
-- method GET
-- body
-- url /
-- User-Agent Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36
-- Upgrade-Insecure-Requests 1
-- Accept-Language zh-CN,zh;q=0.8
local request = {};

function request:new(o)
	o = o or {};
	setmetatable(o, self);
	self.__index = self;
	o.nid = o.tid or o.nid;
	o.client = {};
	o.client.ip = NPL.GetIP(o.nid);
	if(o.method) then
		o.method = string.upper(o.method);
	end
	local url = o.url;
	local aryUrl = url:split('?');
	o.pathname = aryUrl[1];
	o.query = {};
	o.search = aryUrl[2];
	if(o.search) then
		local arySearch = o.search:split('&');
		local i = 1;
		for i = 1, #arySearch do
			local kv = arySearch[i];
			local aryKV = kv:split('=');
			o.query[aryKV[1]] = aryKV[2]:decodeURI();
		end
	end
	-- Android微信小程序发起请求时 cookie 字段为小写开头 by ysr
	if(o.cookie) then
		o.Cookie = o.cookie;
	end
	if(o.Cookie) then
		o.cookies = cookie.parse(o.Cookie);
	else
		o.cookies = {};
	end
	local body = o.body;
	o.body = {};
	if(body) then
		if(type(body) == 'string') then
			if(body:len() > 0) then
				local contentType = o['Content-Type'];
				-- application/x-www-form-urlencoded
				if(contentType and (contentType:startsWith('multipart/form-data'))) then
--					body = body:replace('\r\n', '\n');
					local idx0, idx1 = string.find(body, 'Content', 1);
					local boundaryKey_end = idx0 - 2;
					if(string.sub(body, idx0 - 2, idx0 - 1) == '\r\n') then
						boundaryKey_end = idx0 - 3;
					end
					local boundaryKey = string.sub(body, 1, boundaryKey_end);
					local start = idx1 + 1;
					local _, keyStart = string.find(body, 'name="', start);
					while keyStart do
						local keyEnd, _ = string.find(body, '"', keyStart + 1);
						local key = string.sub(body, keyStart + 1, keyEnd - 1);
						local nextwords = string.sub(body, keyEnd + 3, keyEnd + 12);
						if(nextwords == 'filename="') then
							local filenameStart = keyEnd + 13;
							local filenameEnd, _ = string.find(body, '"', filenameStart);
							local filename = string.sub(body, filenameStart, filenameEnd - 1);
							local fileContentTypeStart = filenameEnd + 16;
							if(string.sub(body, filenameEnd + 2, filenameEnd + 2) == '\n') then
								fileContentTypeStart = fileContentTypeStart + 1;
							end
							local fileContentTypeEnd, _ = string.find(body, '\n', fileContentTypeStart);
							local fileContentStart, _  = string.find(body, '\n', fileContentTypeEnd + 1) + 1;
							if(string.sub(body, fileContentTypeEnd - 1, fileContentTypeEnd - 1) == '\r') then
								fileContentTypeEnd = fileContentTypeEnd - 2;
							else
								fileContentTypeEnd = fileContentTypeEnd - 1;
							end
							local fileContentType = string.sub(body, fileContentTypeStart, fileContentTypeEnd);
							local fileContentEnd, fileContentEnd2 = string.find(body, boundaryKey, fileContentStart + 1);
							if(string.sub(body, fileContentEnd - 2, fileContentEnd - 1) == '\r\n') then
								fileContentEnd = fileContentEnd - 3;
							else
								fileContentEnd = fileContentEnd - 2;
							end
							local fileContent = string.sub(body, fileContentStart, fileContentEnd);
							if(not o.files) then
								o.files = {};
							end
							o.files[#(o.files) + 1] = httpfile:new({
								keyname = key,
								filename = filename,
								contentType = fileContentType,
								content = fileContent,
--								size = fileContentEnd - 1 - fileContentStart
								size = #fileContent
							});
							start = fileContentEnd2 + 1;
						else
							local valStart = keyEnd + 3;
							local valEnd, _ = string.find(body, boundaryKey, valStart + 1);
							local val = string.sub(body, valStart, valEnd - 2);
							if(val:startsWith('\r\n') and val:endsWith('\r')) then -- 解决当参数中有传文件时，其它文本参数前后取值范围不正确的bug
                                val = string.sub(val, 3, -2);
                            end
                            -- print('=====start====', val:startsWith('\r'), val:startsWith('\n'), val:startsWith('\r\n'), val:endsWith('\r'), val:endsWith('\n'), val:endsWith('\r\n'));
							-- o.body[key] = val:replace('\n', '\r\n');
                            o.body[key] = val;
							start = valEnd + 1;
						end
						_, keyStart = string.find(body, 'name="', start);
					end
				elseif(contentType and (contentType:startsWith('application/json'))) then
					local _body = commonlib.Json.Decode(body);
					for k, v in pairs(_body) do
						o.body[k] = v;
					end
				else
					-- print(body);
					local items = body:split('&');
					local i = 1;
					for i = 1, #items do
						local item = items[i];
						local ary = item:split('=');
						local key = ary[1];
						local val = ary[2];
						if(val) then
							val = val:decodeURI();
						else
							val = '';
						end
						o.body[key] = val;
					end
				end
			end
		end
	end
	return o;
end


function request:onBefore()

end


function request:onAfter()

end


NPL.export(request);