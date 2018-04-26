local express = NPL.load('express')
local classroom = NPL.load('../object/classroom')
local classBll = NPL.load('../bll/class')
local router = express.Router:new()

local ROOM_ID_MIN = 100
local ROOM_ID_MAX = 999

-- 开始上课
router:post('/begin', function(req, res, next)
    print('t ->', __rts__:GetName())
    -- TODO: 检查该 keepwork 账户是否拥有开课权限, 检查该导师是否存在未 finish 的课程
    -- classId => 6 位自增长 + 3 为随机数
    local seq = classBll.nextSeq()
    local classId = '' .. seq.val .. math.random(ROOM_ID_MIN, ROOM_ID_MAX)  -- 3 位随机数
    local p = req.body
    local lessonNo = p.lessonNo
    local lessonUrl = p.lessonUrl
    local lessonTitle = p.lessonTitle
    local lessonCover = p.lessonCover
    local goals = p.goals
    local username = p.username

    local rq = rq(p, {'lessonNo', 'lessonUrl', 'username', 'lessonTitle', 'lessonCover' }, res)
	if(not rq) then return end
    local room = classroom:new({
        classId = classId,
        teacher = username,
        lessonUrl = lessonUrl,
        lessonTitle = lessonTitle,
        lessonCover = lessonCover,
        lessonNo = lessonNo,
        goals = goals
    })
    room:begin({
        classId = classId,
        teacher = username,
        lessonUrl = lessonUrl,
        lessonTitle = lessonTitle,
        lessonCover = lessonCover,
        lessonNo = lessonNo,
        goals = goals
    })
    
    local rs = {
        err = 0,
        data = room
    } 
    res:send(rs)
end)

-- 进入课堂
router:post('/enter', function(req, res, next)
    print('t ->', __rts__:GetName())
    local rs = {}
    local p = req.body
    local username = p.username -- TODO: 更换为当前登录用户, 添加用户头像
    local classId = p.classId..''
    local studentNo = p.studentNo
    local rq = rq(p, {'username', 'classId', 'studentNo'}, res)
	if(not rq) then return end
    local room = classroom.getClassRoom(classId)
    if( room and room.state == 0) then -- 进行中的课堂
        if(classroom.USERs['username'] ~= nil) then
            res:send({
                err = 0,
                data = room:getStudent(username)
            })
            return
        end
        local user = {
            username = username,
            classId = room.classId
        }
        classroom.USERs[username] = user
        local _user = {}
        _user.username = username
        _user.studentNo = studentNo
        room:enter( _user )
        rs = {
            err = 0,
            data = room:getStudent( username )
        }
    else
        -- 不存在该教室
        rs = {
            err = 200,
            msg = 'classroom not found.'
        }
    end
    res:send(rs)
end)

-- 提交答题卡
router:post('/replay', function(req, res, next)
    print('t ->', __rts__:GetName())
    local rs = {}
    local p = req.body
    local username = p.username -- TODO: 更换为当前登录用户
    local answerSheet = p.answerSheet
    local totalScore = p.totalScore
    local rightCount = p.rightCount
    local wrongCount = p.wrongCount
    local emptyCount = p.emptyCount
    local rq = rq(p, {'username', 'answerSheet'}, res)
    if(not rq) then return end
    local user = classroom.USERs[username]
    if( user ) then
        -- 教室里的学员
        local room = classroom.classROOMs[user.classId]
        if(room and room.state == 0) then
            -- TODO: DB 操作
            room:commitAnswer(user, answerSheet, totalScore, rightCount, wrongCount, emptyCount)
            rs = {
                err = 0,
                data = room
            }
        else
            rs = {
                err = 201,
                msg = 'class is finish.'
            }
        end
    else
        -- do nothing
        
    end
    res:send(rs)
end)

-- 获取学员答题情况
router:post('/performance', function(req, res, next)
    print('t ->', __rts__:GetName())
    local rs = {}
    local p = req.body
    local username = p.username -- TODO: 更换为当前登录用户
    local rq = rq(p, {'username'}, res)
    if(not rq) then return end
    local user = classroom.USERs[username]
    if( user ) then
        local room = classroom.classROOMs[user.classId]
        local performance = room:getStudentPerformance( user )
        if(performance == nil) then
            rs = {
                err = 400,
                msg = 'not allow user.'
            }
        else
            rs = {
                err = 0,
                data = performance
            }
        end
    else
        -- 非法操作
        rs = {
            err = 400,
            msg = 'not allow user.'
        }
    end
    res:send(rs)
end)

-- 结束课堂
router:post('/finish', function(req, res, next)
    print('t ->', __rts__:GetName())
    local rs = {}
    local p = req.body
    local username = p.username -- TODO: 更换为当前登录用户
    local rq = rq(p, {'username'}, res)
    if(not rq) then return end
    local user = classroom.USERs[username]
    if( user ) then
        local room = classroom.classROOMs[user.classId]
        local result = room:finish( user )
        if(result) then
            rs.err = 0
        else
            rs.err = 101
            rs.msg = 'finish class fail.'
        end
    else
        rs = {
            err = 101,
            msg = 'finish class fail.'
        }
    end
    res:send(rs)
end)

-- 获取整体课堂详情（用于调试）
router:get('/debug', function(req, res, next)
    print('t ->', __rts__:GetName())
    res:send(classroom)
end)

NPL.export(router);