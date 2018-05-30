NPL.load("(gl)script/ide/commonlib.lua")
NPL.load("(gl)script/ide/System/os/GetUrl.lua")
local express = NPL.load('express')
local router = express.Router:new()
local packageBll = NPL.load('../bll/package')

router:post('/upsert', function(req, res, next)
    local p = req.query
    local rs = {err = 0, msg = 'upsert package succes.'}
    local package = p
    local num = packageBll.upsert(package)
    if(num == nil)then
        rs = {
            err = 101,
            msg = 'upsert package failed.'
        }
    end
    res:send(rs)
end)

router:post('/createOrUpdate', function(req, res, next)
    local p = req.body
    local rs = {err = 0, msg = 'create or update package succes.'}
    local id = p.id
    local title = p.title
    local cover = p.cover
    local skills = p.skills
    local agesMin = p.agesMin
    local agesMax = p.agesMax
    local cost = p.cost
    local reward = p.reward
    local lessons = p.lessons -- Json 格式
    local packageUrl = p.packageUrl
    local rq = rq(p, {'id', 'title', 'cover', 'skills', 'agesMin', 'agesMax', 'cost', 'reward', 'lessons', 'packageUrl'}, res)
    if(not rq) then return end
    local packageVo = {
        id = id,
        title = title,
        cover = cover,
        skills = skills,
        agesMin = agesMin,
        agesMax = agesMax,
        input = cost,
        output = reward,
        packageUrl = packageUrl
    }
    local lessonsVo = commonlib.Json.Decode(lessons)
    local issucc = packageBll.createOrUpdate(packageVo, lessonsVo)
    if(not issucc) then
        rs = {
            err = 101,
            msg = 'create or update package package failed.'
        }
    end
    res:send(rs)
end)

NPL.export(router)