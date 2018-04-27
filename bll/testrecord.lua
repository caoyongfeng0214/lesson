local db = NPL.load('../dal/dbutil')

local testrecord = {}

local tbl = 'testrecord'

testrecord.save = function( testrecord, cn )
    return db.insert(tbl, testrecord, cn)
end

testrecord.update = function( testrecord, cn )
    return db.updateBySn(tbl, testrecord, cn)
end

testrecord.learnRecord = function( where, group, order, limit, cn )
    local sql = [[SELECT lessonUrl, lessonTitle, lessonCover, goals, lessonNo, MAX(totalScore) bestScore,
        (SELECT totalScore FROM testrecord WHERE lessonNo = t.lessonNo AND username = t.username ORDER BY finishTime DESC LIMIT 0,1) latestScore
        FROM testrecord t]]
    return db.findJoin(sql, where, group, order, limit, cn)
end

testrecord.detail = function( where, group, order, limit, cn )
    local sql = [[SELECT sn, beginTime, totalScore, rightCount, wrongCount, emptyCount, answerSheet, finishTime, lessonNo, lessonTitle FROM testrecord]]
    return db.findJoin(sql, where, group, order, limit, cn)
end

NPL.export(testrecord)
