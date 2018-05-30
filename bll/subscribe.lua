local db = NPL.load('../dal/dbutil')
local memberBll = NPL.load('./member')

local subscribe = {}

local tbl = 'subscribe'

subscribe.insert = function(object, cn)
    return db.insert(tbl, object, cn)
end

subscribe.get = function( where, group, order, cn )
    local sql = 'SELECT sn, username, createTime, packageId, finished FROM subscribe'
    return db.detail(sql, where, group, order, cn)
end

subscribe.addPackage = function( subscribeVo )
    local issucc
    db.execInTrans(function(cn, returnTrans)
        local member = memberBll.findOrInsertByName( subscribeVo.username )
        -- TODO: 添加一个 subscribe 记录，扣除会员的知识币
        local num1 = nil
        local num2 = nil
        num1 = subscribe.insert(subscribeVo, cn)

    end, function(issuccess, result)
        issucc = issuccess
    end)
    return issucc
end
