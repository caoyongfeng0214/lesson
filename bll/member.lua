local db = NPL.load('../dal/dbutil')

local member = {}

local tbl = 'member'

member.get = function( where, group, order, cn )
    local sql = 'SELECT sn, username, vipEndTime, UNIX_TIMESTAMP(vipEndTime) vipEndUnixTime, TIMESTAMPDIFF( DAY,NOW() , vipEndTime ) vipDay FROM member'
    return db.detail(sql, where, group, order, cn)
end

member.save = function( member, cn )
    return db.insert(tbl, member)
end

member.update = function( member, cn )
    return db.updateBySn(tbl, member, cn)
end

member.findOrInsertByName = function( uesename )
    local sql = 'SELECT sn, username, vipEndTime, UNIX_TIMESTAMP(vipEndTime) vipEndUnixTime, TIMESTAMPDIFF( DAY,NOW() , vipEndTime ) vipDay FROM member'
    local memberVo = db.detail(sql, { username = username } )
    if( memberVo == nil ) then
        -- insert
        local num, lastSn = db.insert(tbl, {
            username = username
        })
        memberVo = {
            username = username,
            sn = lastSn
        }
    end
    return memberVo
end

-- 获取统计信息
member.statis = function( where, group, order, cn )
    local sql = [[SELECT m.username, m.joinTime,
        (SELECT COUNT(1) FROM class WHERE teacher = m.username) teached,
        (SELECT COUNT(1) FROM testrecord WHERE username = m.username) learned,
        (SELECT IFNULL( SUM( duration ), 0) FROM testrecord WHERE username = m.username) learnDuration
        FROM member m ]]
    return db.detail(sql, where, group, order, cn)
end

NPL.export(member)