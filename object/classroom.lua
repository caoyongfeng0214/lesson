NPL.load("(gl)script/ide/commonlib.lua")
NPL.load("(gl)script/ide/Json.lua")
local express = NPL.load('express')
local classBll = NPL.load('../bll/class')
local recordBll = NPL.load('../bll/testrecord')

local classroom = {}

function classroom:new( o )
    o = o or {}
    setmetatable(o, self) -- 这里需要将 teacher 传入
    self.__index = self
    o.state = 0 -- 0. start  1.finish
    o.students = {} -- 学生列表
    return o
end

-- 教室 classId 不可以重复
classroom.classROOMs = {}

-- 所有成员列表，包含导师信息
classroom.USERs = {}

classroom.getClassRoom = function( classId )
    return classroom.classROOMs[classId]
end

function classroom:getStudent( username )
    return self.students[username]
end

-- 开始课堂
function classroom:begin( classVo )
    if(self.state == 0) then
        local num, lastId = classBll.save({
            classId = classVo.classId,
            teacher = classVo.teacher,
            lessonUrl = classVo.lessonUrl,
            lessonTitle = classVo.lessonTitle,
            lessonCover = classVo.lessonCover,
            lessonNo = classVo.lessonNo,
            goals = classVo.goals,
            startTime = classVo.startTime
            })
        self.classSn = lastId
        classroom._begin(self)
        express.handler.shareData('_begin', self)
    end
end

-- 学生进入教室
function classroom:enter( user )
    local stu = self.students[user.username]
    -- 教师在教室创建的时候就需要传入了。
    if( stu == nil and user.username ~= self.teacher and self.state == 0) then
        -- TODO: 产生一个答题卡为空的 TestRecord， 并记录 TestRecordId 到学生数据中
        local record = {
            username = user.username,
            lessonUrl = self.lessonUrl,
            lessonTitle = self.lessonTitle,
            lessonCover = self.lessonCover,
            goals = self.goals,
            lessonNo = self.lessonNo,
            classId = self.classId,
            classSn = self.classSn,
            lessonPerformance = self.lessonPerformance
        }
        local num, lastId = recordBll.save(record)
        if(lastId) then 
            user.recordSn = lastId
            local obj = {room = self, user = user, action = 'enter'}
            classroom._set(obj)
            express.handler.shareData('_set', obj);
        end
    else
        -- 学员已经进来过该教室
    end
end

-- 学生更新自己的答题卡
--  args: student 答题人
--        answerSheet 答题卡（Json 字符串）          
function classroom:commitAnswer( user, answerSheet, totalScore, rightCount, wrongCount, emptyCount )
    local stu = self.students[user.username]
    if( stu ~= nil and user.username ~= teacher and self.state == 0) then
        local obj = {
            room = self, 
            user = stu, 
            answerSheet = answerSheet,
            totalScore = totalScore,
            rightCount = rightCount,
            wrongCount = wrongCount,
            emptyCount = emptyCount,
            action = 'commitAnswer'
        }
        -- 更新自己的 TestRecord
        if(stu.recordSn) then
            local record = {
                sn = stu.recordSn,
                answerSheet = answerSheet,
                finishTime = os.date( "%Y-%m-%d %H:%M:%S", os.time() ),
                totalScore = totalScore,
                rightCount = rightCount,
                wrongCount = wrongCount,
                emptyCount = emptyCount
            }
            recordBll.update(record)
        end
        classroom._set(obj)
        express.handler.shareData('_set', obj);
    else
        -- 非法操作
    end
end

-- 获取学生的上课实时状态（答题情况）
function classroom:getStudentPerformance( user )
    if( user and user.username == self.teacher ) then
        return self.students
    else
        return nil
    end
end

-- finish
function classroom:finish( user )
    local _class = {}
    if( self.state == 0 and user.username == self.teacher ) then
        -- save Summary into class
        local summary = {}
        local summaryJsonStr = '[]'
        for k,v in pairs(self.students) do
            table.insert(summary, v)
        end
        if(#summary > 0) then
            summaryJsonStr = commonlib.Json.Encode(summary)
        end
        _class = {
            sn = self.classSn,
            state = 1, -- 已结束
            finishTime = os.date( "%Y-%m-%d %H:%M:%S", os.time() ),
            summary = summaryJsonStr
        }
        local num = classBll.update(_class)
        if(num) then
            local obj = {room = self, user = user, action = 'finish'}
            classroom._set(obj)
            express.handler.shareData('_set', obj);
        else
            return nil
        end
    else
        -- 不处理
    end
    return _class
end

classroom._set = function( obj ) 
    local _room = classroom.getClassRoom(obj.room.classId)
    local _user = obj.user
    if( _room and _user) then
        -- action mapping
        if(obj.action == 'enter') then
            _room.students[_user.username] = _user
            classroom.USERs[_user.username] = {
                username = _user.username,
                classId = obj.room.classId
            }
        elseif(obj.action == 'commitAnswer') then
            local stu = _room.students[_user.username]
            stu.answerSheet = commonlib.Json.Decode( obj.answerSheet )
            stu.totalScore = obj.totalScore
            stu.rightCount = obj.rightCount
            stu.wrongCount = obj.wrongCount
            stu.emptyCount = obj.emptyCount
        elseif(obj.action == 'finish') then
            classroom.classROOMs[obj.room.classId] = nil
        end
    end
end

classroom._begin = function( obj )
    if(obj and obj.classId and obj.teacher) then
        classroom.classROOMs[obj.classId] = classroom:new(obj)
        classroom.USERs[obj.teacher] = {
            username = obj.teacher,
            classId = obj.classId
        }
    end
end

NPL.export(classroom)