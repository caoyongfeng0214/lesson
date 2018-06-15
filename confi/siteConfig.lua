local siteConfi = {
	-- keepwork 环境地址
	keepworkHost = 'http://stage.keepwork.com',
	-- keepwork ES 接口地址
	-- esApi = 'http://10.28.18.4:19200/www_kw_pages/pages/_search', -- online
	esApi = 'http://10.28.18.7:9200/www_kw_pages/pages/_search',
	-- 发送邮件的 stmp 服务器
	replyEmail = 'smtp.exmail.qq.com/',
	-- 发送邮件的账户用户名
	replyUsername = 'noreply@mail.keepwork.com',
	-- 授权码（该授权码可能会过期）
	replyPassword = 'M3Hbhq6KAZzagFP4',
}

NPL.export(siteConfi);