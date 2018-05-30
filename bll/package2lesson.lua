local db = NPL.load('../dal/dbutil')

local package2lesson = {}

local tbl = 'package2lesson'

package2lesson.del = function( where, cn )
    return db.delete(tbl, where, cn)
end

package2lesson.addBatch = function( fields, objs, cn )
    return db.addBatch(tbl, fields, objs, cn)
end

NPL.export(package2lesson)