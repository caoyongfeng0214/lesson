local db = NPL.load('../dal/dbutil')

local cdkey = {}

local tbl = 'cdkey'

cdkey.addBatch = function( fields, objs, cn )
    return db.addBatch(tbl, fields, objs, cn)
end

cdkey.list = function( where, group, order, limit, cn )
    local sql = 'SELECT sn, `key`, createTime, useTime, state FROM cdkey'
    return db.findJoin(sql, where, group, order, limit, cn)
end

cdkey.get = function( where, group, order, cn )
    local sql = 'SELECT sn, `key`, createTime, useTime, state, user, userIp FROM cdkey'
    return db.detail(sql, where, group, order, cn)
end

cdkey.update = function( cdkeyVo, cn )
    return db.updateBySn(tbl, cdkeyVo, cn)
end

NPL.export(cdkey)