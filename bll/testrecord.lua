local db = NPL.load('../dal/dbutil')

local testrecord = {}

local tbl = 'testrecord'

testrecord.save = function( testrecord, cn )
    return db.insert(tbl, testrecord, cn)
end

testrecord.update = function( testrecord, cn )
    return db.updateBySn(tbl, testrecord, cn)
end

NPL.export(testrecord)
