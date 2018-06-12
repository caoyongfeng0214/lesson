local express = NPL.load('express')
local router = express.Router:new()
local commonBll = NPL.load('../bll/common')

-- 后台管理 - 首页
router:get('/', function(req, res, next)
    res:render('_mg_index');
end);

-- 后台管理 - 登陆状态查询
router:get('/checkLogin', function(req, res, next)
    local rs = {logged= true}
    res:send(rs)
end);

NPL.export(router);