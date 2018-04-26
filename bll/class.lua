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

NPL.export(class)
