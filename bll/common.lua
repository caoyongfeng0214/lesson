local db = NPL.load('../dal/dbutil')
local sitecfg = NPL.load('../confi/siteConfig')


local common = {}

-- 使用 keepwork Token 获取到 keepwork 登录信息
common.auth = function ( token, successCallback, errCallback )
    -- body
    if(token) then
        System.os.GetUrl({
			url = sitecfg.keepworkHost .. '/api/wiki/models/user/getProfile',
			headers = { Authorization = 'Bearer '..token.value }
		}, function(err, msg, data)
			if( data and data.data and data.data.username ) then
                if( successCallback and type(successCallback) == 'function') then
                    successCallback(data.data)
                end
			else
				if( errCallback and type(errCallback) == 'function' ) then
                    errCallback()
                end
			end
		end);
    else
        if( errCallback and type(errCallback) == 'function' ) then
            errCallback()
        end
    end
end

NPL.export(common)