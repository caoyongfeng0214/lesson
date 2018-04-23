local db = NPL.load('../dal/dbutil')

local member = {}

local tbl = 'member'

member.get = function( where, group, order, cn )
    local sql = 'SELECT sn, username, vipEndTime,TIMESTAMPDIFF( DAY,NOW() , vipEndTime ) vipDay FROM member'
    return db.detail(sql, where, group, order, cn)
end

member.save = function( member, cn )
    return db.insert(tbl, member)
end

NPL.export(member)