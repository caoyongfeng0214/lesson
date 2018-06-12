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
    local sql = [[SELECT sn, classId, startTime, lessonUrl, lessonTitle, lessonNo, goals, lessonCover,
        CONCAT("[", (SELECT  SUBSTRING_INDEX(GROUP_CONCAT(JSON_OBJECT( "pkgTitle", p.title, "pkgUrl", p.packageUrl ) ),",{",3) FROM package2lesson pl LEFT JOIN package p ON pl.packageId = p.id WHERE pl.lessonUrl = class.`lessonUrl` ), "]" ) pkgs
        FROM class]]
    return db.findJoin(sql, where, group, order, limit, cn)
end

-- 教学详情
class.detail = function( where, group, order, cn )
    local sql = [[SELECT sn, classId, startTime, lessonUrl, teacher, lessonTitle, lessonNo, goals, startTime, finishTime,
        CONCAT("[", (SELECT GROUP_CONCAT(JSON_OBJECT( "totalScore", t.totalScore, "answerSheet", t.answerSheet, "emptyCount", t.emptyCount, 'recordSn', t.sn, 'rightCount', t.rightCount, 'studentNo', t.studentNo, 'username', t.username, 'wrongCount', t.wrongCount, 'quizNum', t.quizNum, 'cheatFlag', t.cheatFlag, 'portrait', m.portrait) ) FROM testrecord t LEFT JOIN member m ON t.username = m.username WHERE t.classId = class.`classId` ), "]" ) summary
        , state, lessonCover FROM class]]
    return db.detail(sql, where, group, order, cn)
end

NPL.export(class)
