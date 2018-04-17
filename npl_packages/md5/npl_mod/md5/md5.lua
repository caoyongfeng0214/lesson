NPL.load("(gl)script/ide/math/MD5.lua");
local md5 = commonlib.LibStub("MD5");

return function(str)
	return md5:MD5(str);
end;