NPL.load("(gl)script/ide/commonlib.lua")
NPL.load("(gl)script/ide/Json.lua")

local classroom = {}

function classroom:new( o )
    o = o or {}
    setmetatable(o, self) -- 这里需要将 teacher 传入
    self.__index = self
    o.state = 0 -- 0. start 1. finish 
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

-- 学生进入教室
function classroom:enter( user )
    local stu = self.students[user.username]
    -- 教师在教室创建的时候就需要传入了。
    if( stu == nil and user.username ~= teacher ) then
        user.loginTime = os.time()
        user.classId = self.classId
        self.students[user.username] = user
        -- TODO: 初始化该学生的答题卡
        
    else
        -- 学员已经进来过该教室
    end
end

-- 学生更新自己的答题卡
--  args: student 答题人
--        answerSheet 答题卡（Json 字符串）          
function classroom:commitAnswer( user, answerSheet )
    local stu = self.students[user.username]
    if( stu ~= nil and user.username ~= teacher ) then
        stu.answerSheet = commonlib.Json.Decode( answerSheet )
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
function classroom:finish()
    if( self.state == 0 ) then
        self.state = 1
        -- TODO: save Summary
        self.students = nil
        self.teacher = nil
    else
        -- 不处理
    end
end

NPL.export(classroom)