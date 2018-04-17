--[[
Author: CYF
Date: 2017年3月31日
Desc: 字符串操作的常用方法

引用：
	在项目启动时执行 NPL.load('string') 即可。
]]



--[[
返回一个新字符串，其中当前实例中出现的所有指定字符串都替换为另一个指定的字符串。
更好的：http://lua-users.org/wiki/StringReplace
params:
	oldValue: （string）需要被替换的字符串，可以是一个正则表达式。
	newValue: （string or function）新的字符串或特定格式的字符串，也可以是一个function
示例：
	local str = 'Hello ParaEngine';
	local str2 = str:replace('e', 'NPL'); => 'HNPLllo ParaEnginNPL'
	local str2 = string.replace(str, 'e', 'NPL'); => 'HNPLllo ParaEnginNPL'
神奇用法：
	local str = 'Hello ParaEngine';
	local str2 = str:replace('(a)', '%1-'); => 'Hello Pa-ra-Engine'
	如果原字符串中本来就有“（）”呢，比如，需要将“Hello Par(a)Engine”中的“(a)”替换为“a-”。则需为“()”加上转义符：
	local str = 'Hello Par(a)Engine';
	local str2 = str:replace('%(a%)', 'a-'); => 'Hello Para-Engine'
	如果用来替换的字符串中含有“%”呢？因为“%”也是一个特殊字符，因此也需要转义：
	local str = 'Hello Par(a)Engine';
	local str2 = str:replace('%(a%)', '%%1'); => 'Hello Par%1Engine'
	如果用来替换的字符串中含有“()”，则不需要转义：
	local str = 'Hello ParaEngine';
	local str2 = str:replace('r(a)', 'r(%1)'); => 'Hello Par(a)Engine'
还有更神奇的：
	local str = 'Hello ParaEngine';
	local str2 = str:replace('(P)(a)', '%2%1'); => 'Hello aPraEngine'
第二个参数是function的示例：
	local str = 'Hello ParaEngine';
	local str2 = str:replace('(%w+)', function(w)
		return w:len();
	end); => '5 10'
	local str3 = str:replace('Hello', function(s)
		return s:upper();
	end); => 'HELLO ParaEngine'
]]
function string:replace(oldValue, newValue)
	return self:gsub(oldValue, newValue);
end


--[[
拆分字符串
示例：
	local str = 'aaa,bbb,ccc';
	local ary = str:split(','); => {'aaa', 'bbb', 'ccc'}
	local ary = string.split(str, ','); => {'aaa', 'bbb', 'ccc'}
]]
function string:split(separator, outResults)
	if not outResults then
		outResults = {};
	end
	local start = 1;
	local theSplitStart, theSplitEnd = string.find(self, separator, start);
	while theSplitStart do
		table.insert(outResults, string.sub(self, start, theSplitStart-1));
		start = theSplitEnd + 1;
		theSplitStart, theSplitEnd = string.find(self, separator, start);
	end
	table.insert(outResults, string.sub(self, start));
	return outResults;
end


--[[
将字符串数组合并为一个字符串，并以指定的字符间隔。
示例：
	local list = {'aaa', 'bbb', 'ccc'};
	local str = string.join(',', list); => 'aaa,bbb,ccc'
]]
string.join = function(separator, list)
	local len = #list;
	if len == 0 then
		return '';
	end
	local str = list[1];
	for i = 2, len do
		str = str .. separator .. list[i];
	end
	return str;
end;


--[[
去除字符串开始和结尾处的空格
示例：
	local str = '  abcdefg   ';
	local str2 = str:trim(); => 'abcdefg';
	local str2 = string.trim(str); => 'abcdefg'
]]
function string:trim()
	return self:gsub('^%s*(.-)%s*$', '%1');
end


--[[
去除字符串开始处的空格
示例：
	local str = '  abcdefg   ';
	local str2 = str:trimStart(); => 'abcdefg   ';
	local str2 = string.trimStart(str); => 'abcdefg   '
]]
function string:trimStart()
	return self:gsub('^%s+', '');
end


--[[
去除字符串结尾处的空格
示例：
	local str = '  abcdefg   ';
	local str2 = str:trimEnd(); => '  abcdefg';
	local str2 = string.trimEnd(str); => '  abcdefg'
]]
function string:trimEnd()
	return self:gsub('%s+$', '');
end


--[[
判断字符串的开头是否与指定字符串匹配
params:
	str: （string）要比较的字符串
	[ ignoreCase ]: （boolean）是否忽略大小写。可选参数。默认为false。
示例：
	local str = 'abcdefg';
	local str2 = 'aBc';
	local bl = str:startsWith(str2); => false
	local bl = string.startsWith(str, str2); => false
	local bl = str:startsWith(str2, true); => true
	local bl = string.startsWith(str, str2, true); => true
]]
function string:startsWith(str, ignoreCase)
	local sub = string.sub(self, 1, string.len(str));
	if(ignoreCase) then
		sub = sub:upper();
		str = str:upper();
	end
	return sub == str;
end


--[[
判断字符串的结尾是否与指定字符串匹配
params:
	str: （string）要比较的字符串
	[ ignoreCase ]: （boolean）是否忽略大小写。可选参数。默认为false。
示例：
	local str = 'abcdefg';
	local str2 = 'eFg';
	local bl = str:endsWith(str2); => false
	local bl = string.endsWith(str, str2); => false
	local bl = str:endsWith(str2, true); => true
	local bl = string.endsWith(str, str2, true); => true
]]
function string:endsWith(str, ignoreCase)
	local sub = string.sub(self,-string.len(str));
	if(ignoreCase) then
		sub = sub:upper();
		str = str:upper();
	end
	return sub == str;
end


--[[
把字符串作为 URI 进行编码。某些字符将被十六进制的转义序列进行替换。
示例：
	local str = 'http://www.nooong.com';
	local str2 = str:encodeURI(); => http%3A%2F%2Fwww.nooong.com
	local str2 = string.encodeURI(str); => http%3A%2F%2Fwww.nooong.com
]]
function string:encodeURI()
	local str = string.gsub(self, '\n', '\r\n');
	str = string.gsub(str, '([^%w %-%_%.%~])', function(c)
		return string.format('%%%02X', string.byte(c));
	end);
    str = string.gsub(str, ' ', '+');
	return str;
end


--[[
可对 encodeURI() 函数编码过的 URI 进行解码。
示例：
	local str = 'http://www.nooong.com';
    local str2 = str:encodeURI(); => http%3A%2F%2Fwww.nooong.com
	local str3 = str2:decodeURI(); => http://www.nooong.com
	local str4 = string.decodeURI(str2); => http://www.nooong.com
]]
function string:decodeURI()
	local str = string.gsub(self, '+', ' ');
	str = string.gsub(str, '%%(%x%x)', function(h)
		return string.char(tonumber(h,16));
	end);
	str = string.gsub(str, '\r\n', '\n');
	return str;
end


NPL.export(string);