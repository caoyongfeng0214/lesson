NPL.load("(gl)script/ide/commonlib.lua")
NPL.load("(gl)script/ide/System/os/GetUrl.lua")
local express = NPL.load('express')
local router = express.Router:new()
local packageBll = NPL.load('../bll/package')
local commonBll = NPL.load('../bll/common')

-- 创建或更新课程包
router:post('/createOrUpdate', function(req, res, next)
    local p = req.body
    local rs = {err = 0, msg = 'create or update package success.'}
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

-- 学习记录列表
router:get('/learnList', function(req, res, next)
    local rs = {}
    local p = req.query

    local getList = function(user)
        local where = {
            ['sb.username'] = user.username
        }
        local limit = {
            pageSize = p.psize,
            pageNo = p.pno
        }
        -- 没学完的课程包显示在前面，学完的课程包显示在后面；
        local order = {
            ['(CASE WHEN doneCount >= lessonCount THEN 1 ELSE 0 END)'] = 'ASC'
        }
        local list, page = packageBll.list(where, group, order, limit)
        if(list) then
            rs.err = 0
            rs.data = list
            rs.page = page
        else
            rs.err = 101
            rs.msg = 'get learn packages fail.'
        end
        res:send(rs)
    end
    local token = req.cookies.token
    commonBll.auth(token, getList, function()
        res:send({
            err = 102,
            msg = 'plz login.'
        })
    end)
end)

NPL.export(router)