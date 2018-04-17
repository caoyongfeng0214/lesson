local dbConfi = NPL.load('../confi/dbConfi');

local mysql = NPL.load('mysql'):new({
    user = dbConfi.user,
	pwd = dbConfi.pwd,
	db = dbConfi.db,
    host = dbConfi.host,
	port = dbConfi.port
});




NPL.export(mysql);