NPL.load('script/ide/commonlib.lua');
NPL.load('script/ide/Json.lua');


_G.JSON = {};

-- 将JSON格式的字符串转为lua table
-- 如果不是合法的JSON格式的字符串，则返回nil
_G.JSON.parse = function(str)
	local out = {};
	if(NPL.FromJson(str, out)) then
		return out;
	end
	return nil;
end;


-- 将一个Lua数据转为JSON格式的字符串
_G.JSON.tostring = function(data)
	return commonlib.Json.Encode(data);
end;

_G.JSON.string = _G.JSON.tostring;



NPL.export(_G.JSON);