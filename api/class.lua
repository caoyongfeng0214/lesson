NPL.load("(gl)script/ide/commonlib.lua")
NPL.load("(gl)script/ide/System/os/GetUrl.lua")
local express = NPL.load('express')
local classroom = NPL.load('../object/classroom')
local classBll = NPL.load('../bll/class')
local memberBll = NPL.load('../bll/member')
local subscribeBll = NPL.load('../bll/subscribe')
local recordBll = NPL.load('../bll/testrecord')
local router = express.Router:new()
local System = commonlib.gettable("System")
local sitecfg = NPL.load('../confi/siteConfig')

local ROOM_ID_MIN = 100
local ROOM_ID_MAX = 999

-- 开始上课
router:post('/begin', function(req, res, next)
    -- 检查该 keepwork 账户是否拥有开课权限
    local p = req.body
    local lessonNo = p.lessonNo
    local lessonUrl = p.lessonUrl
    local lessonTitle = p.lessonTitle
    local lessonCover = p.lessonCover
    local goals = p.goals
    local username = p.username
    local lessonPerformance = p.lessonPerformance
    local quizzNum = p.quizzNum
    local codeReadLine = p.codeReadLine
    local codeWriteLine = p.codeWriteLine
    local commands = p.commands
    local rq = rq(p, {'lessonNo', 'lessonUrl', 'username', 'lessonTitle', 'lessonCover', 'codeReadLine', 'codeWriteLine', 'commands'  }, res)
	if(not rq) then return end
    local member = memberBll.findOrInsertByName(username)
    if(member.identity == nil or member.identity ~= 2) then -- 教学者身份
        -- 没有开课权限
        res:send({
            err = 102,
            msg = 'not allow.'
        })
        return
    end
    -- check is add package
    local packageCount = subscribeBll.checkAddPackageByLessonUrl(username, lessonUrl)
    if(packageCount == nil or packageCount == 0) then
        res:send({
            err = 104,
            msg = 'plz take package.'
        })
        return
    end
    -- 检查该导师是否存在未 finish 的课程
    local _user = classroom.USERs[username]
    if( _user ) then
        local _room = classroom.classROOMs[_user.classId]
        if(_room and _room.teacher == username) then
            res:send({
                err = 103,
                msg = 'have opening class.',
                data = _room
            })
            return
        end
    end
    -- classId => 6 位自增长 + 3 为随机数
    local seq = classBll.nextSeq()
    local classId = '' .. seq.val .. math.random(ROOM_ID_MIN, ROOM_ID_MAX)  -- 3 位随机数
    local startTime = os.date( "%Y-%m-%d %H:%M:%S", os.time() )
    local room = classroom:new({
        classId = classId,
        teacher = username,
        lessonUrl = lessonUrl,
        lessonTitle = lessonTitle,
        lessonCover = lessonCover,
        lessonNo = lessonNo,
        goals = goals,
        startTime = startTime,
        lessonPerformance = lessonPerformance,
        quizzNum = tonumber(quizzNum),
        codeReadLine = codeReadLine,
        codeWriteLine = codeWriteLine,
        commands = commands
    })
    room:begin({
        classId = classId,
        teacher = username,
        lessonUrl = lessonUrl,
        lessonTitle = lessonTitle,
        lessonCover = lessonCover,
        lessonNo = lessonNo,
        goals = goals,
        startTime = startTime,
        lessonPerformance = lessonPerformance,
        quizzNum = tonumber(quizzNum),
        codeReadLine = codeReadLine,
        codeWriteLine = codeWriteLine,
        commands = commands
    })
    
    -- 为导师生成一个 testRecord, 并达成该课程的成就
    local num, lastId = recordBll.save({
        username = username,
        lessonUrl = lessonUrl,
        lessonTitle = lessonTitle,
        lessonCover = lessonCover,
        goals = goals,
        lessonNo = lessonNo,
        rightCount = quizzNum,
        wrongCount = 0,
        emptyCount = 0,
        codeReadLine = codeReadLine,
        codeWriteLine = codeWriteLine,
        commands = commands,
        state = 2
    })
    if(lastId) then
        memberBll.achieving(lastId)
    end
    local rs = {
        err = 0,
        data = room
    } 
    res:send(rs)
end)

-- 检查是否存在可恢复课堂
router:post('/resurme', function(req, res, next)
    local p = req.body
    local lessonUrl = p.lessonUrl
    local username = p.username
    local rq = rq(p, {'username', 'lessonUrl'}, res)
    if(not rq) then return end
    for i,v in pairs(classroom.classROOMs) do
        if(v.teacher == username and v.lessonUrl == lessonUrl) then
            res:send({
                err = 0,
                data = v
            })
            return
        end
    end
    res:send({err = 102, msg = 'not allow.'})
end)

-- 进入课堂
router:post('/enter', function(req, res, next)
    local rs = {}
    local p = req.body
    local username = p.username
    local classId = p.classId..''
    local studentNo = p.studentNo
    local portrait = p.portrait
    local rq = rq(p, {'username', 'classId', 'studentNo'}, res)
	if(not rq) then return end
    local member = memberBll.findOrInsertByName(username, portrait)
    local room = classroom.getClassRoom(classId)
    if( room and room.state == 0) then -- 进行中的课堂
        if(classroom.USERs['username'] ~= nil) then
            res:send({
                err = 0,
                data = {
                    u = room:getStudent(username),
                    lessonUrl = room.lessonUrl .. '?device=pad&classId=' .. room.classId .. '&username=' .. _u.username .. '&studentNo=' .. _u.studentNo
                } 
            })
            return
        end
        local _user = {}
        _user.username = username
        _user.studentNo = studentNo
        room:enter( _user )
        rs = {
            err = 0,
            data = {
                u = room:getStudent(username),
                lessonUrl = room.lessonUrl .. '?device=pad&classId=' .. room.classId .. '&username=' .. username .. '&studentNo=' .. studentNo
            }
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
            room:commitAnswer(user, answerSheet, totalScore, rightCount, wrongCount, emptyCount)
            rs = {
                err = 0,
                data = room
            }
        else
            rs = {
                err = 201,
                msg = 'class is finished.'
            }
        end
    else
        -- do nothing
        rs = {
            err = 102,
            msg = 'not allow.'
        }
    end
    res:send(rs)
end)

-- 学员更新自己的状态
router:post('/upsertstate', function(req, res, next) 
    local rs = {}
    local p = req.body
    local username = p.username
    local state = p.state
    local rq = rq(p, {'username', 'state'}, res)
    if(not rq) then return end
    local user = classroom.USERs[username]
    if( user ) then
        local room = classroom.classROOMs[user.classId]
        if(room and room.state == 0) then
            room:upsertstate(user, state)
            rs = {
                err = 0,
                data = user
            }
        else
            rs = {
                err = 201,
                msg = 'class is finished.'
            }
        end
    else
        rs = {
            err = 202,
            msg = 'user is defind.'
        }
    end
    res:send(rs)
end)

-- 获取学员答题情况
router:post('/performance', function(req, res, next)
    local rs = {}
    local p = req.body
    local username = p.username -- TODO: 更换为当前登录用户
    local rq = rq(p, {'username'}, res)
    if(not rq) then return end
    local user = classroom.USERs[username]
    if( user ) then
        local room = classroom.classROOMs[user.classId]
        local performance = nil
        if(room) then
            performance = room:getStudentPerformance( user )
        end
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
            rs.data = result
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

-- Have taught 记录
router:get('/taught', function(req, res, next)
    local rs = {}
    local p = req.query
    local username = p.username -- TODO: 更换为当前登录用户
    local rq = rq(p, {'username'}, res)
    if(not rq) then return end
    local where = {
        teacher = username,
        state = 1
    }
    local order = {startTime = 'DESC'}
    if(p.order == 'asc') then
        order.startTime = 'ASC'
    end
    local limit = {
        pageSize = p.psize,
        pageNo = p.pno
    }
    local list, page = classBll.taughtRecord(where, nil, order, limit)
    if(list) then
        for i,v in ipairs(list) do
            v.pkgs = commonlib.Json.Decode(v.pkgs)
        end
        rs.err = 0
        rs.data = list
        rs.page = page
    else
        rs.err = 101
        rs.msg = 'get taught record fail.'
    end
    res:send(rs)
end)

-- 课堂详情
router:get('/detail', function(req, res, next)
    local rs = {}
    local p = req.query
    local classId = p.classId
    local rq = rq(p, {'classId'}, res)
    if(not rq) then return end
    local where = {
        classId = classId,
        state = 1
    }
    local data = classBll.detail(where)
    if(data) then
        data.summary = commonlib.Json.Decode(data.summary)
        rs.err = 0
        rs.data = data
    else
        rs.err = 101
        rs.msg = 'get classinfo fail.'
    end
    res:send(rs)
end)

-- 获取 lesson list
router:get('/lesson', function(req, res, next)
    local rs = {}
    System.os.GetUrl({
        url = sitecfg.esApi,
        headers={["content-type"]="application/json"},
        postfields = '{"query": {"match_phrase_prefix": {"content": "```@Lesson styleID: 0 lesson: LessonNo:"}}}' -- jsonString
    }, function(err, msg, data)
        if(data ~= nil) then
            res:send(data)
        else
            rs = { type = 'error', err = 400, result ='forbid Fail'}
            res:send(rs) 
        end
    end)
end)


-- 获取 package list
router:get('/pkgs', function(req, res, next)
    local rs = {}
    System.os.GetUrl({
        url = sitecfg.esApi,
        headers={["content-type"]="application/json"},
        postfields = '{"query": {"match_phrase_prefix": {"content": "```@LessonPackage styleID: 0 lessonPackage:"}}}' -- jsonString
    }, function(err, msg, data)
        if(data ~= nil) then
            res:send(data)
        else
            rs = { type = 'error', err = 400, result ='forbid Fail'}
            res:send(rs) 
        end
    end)
end)

-- 获取整体课堂详情（用于调试）
router:get('/debug', function(req, res, next)
    print('t ->', __rts__:GetName())
    local rs = {
        err = 0,
        thred = __rts__:GetName(),
        data = classroom
    }
    res:send(rs)
end)

NPL.export(router)