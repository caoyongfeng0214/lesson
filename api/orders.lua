local express = NPL.load('express')
local router = express.Router:new()
local orderBll = NPL.load('../bll/orders')


NPL.export(router)