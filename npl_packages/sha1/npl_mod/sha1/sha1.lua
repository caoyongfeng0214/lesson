NPL.load("(gl)script/ide/System/Encoding/sha1.lua");
local Encoding = commonlib.gettable("System.Encoding");

-- params:
--		str: string, 要加密的字符串
--		[ format] : string, 加密后返回数据的格式。可选的值为 'hex'、'base64'。默认值为nil，将不做任何格式转换，直接返回加密后的二进制数据
return function(str, format)
	if(format ~= 'hex' and format ~= 'base64') then
		format = nil;
	end
	return Encoding.sha1(str, format);
end;