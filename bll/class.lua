local db = NPL.load('../dal/dbutil')

local class = {}

local tbl = 'class'

class.nextSeq = function()
    -- classSeq = 序列名
    local sql = 'SELECT nextval("classSeq") val'
    return db.queryFirst(sql)
end

class.save = function( class, cn )
    return db.insert(tbl, class, cn)
end

class.update = function( class, cn )
    return db.updateBySn(tbl, class, cn)
end

-- 教学记录
class.taughtRecord = function( where, group, order, limit, cn )
    local sql = 'SELECT sn, classId, startTime, lessonUrl, lessonTitle, lessonNo, goals, lessonCover FROM class'
    return db.findJoin(sql, where, group, order, limit, cn)
end

-- 教学详情
class.detail = function( where, group, order, cn )
    local sql = 'SELECT sn, classId, startTime, lessonUrl, teacher, lessonTitle, lessonNo, goals, startTime, finishTime, summary, state, lessonCover FROM class'
    return db.detail(sql, where, group, order, cn)
end

NPL.export(class)
