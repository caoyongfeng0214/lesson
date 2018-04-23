local config = {
	ip = '0.0.0.0',
	port = '3000',
	views = 'views',
	['view engine'] = 'lustache',
	default = 'index.htm',
	cookieAge = 86400,
	threadCnt = 50,
	upload_dir = '/public/uploads/'
};

NPL.export(config);