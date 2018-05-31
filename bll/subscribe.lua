local db = NPL.load('../dal/dbutil')
local memberBll = NPL.load('./member')
local packageBll = NPL.load('./package')

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
    local msg = nil
    db.execInTrans(function(cn, returnTrans)
        local member = memberBll.findOrInsertByName( subscribeVo.username )
        -- 检查会员的知识币是否够用，并添加一个 subscribe 记录，扣除会员的知识币
        local package = packageBll.get({
            id = subscribeVo.packageId
        })
        echo('#p')
        echo(package)
        if( package == nil ) then
            msg = 'package not found.'
            returnTrans(false)
        elseif( tonumber(package.input) > member.coin ) then
            -- 会员的知识币不够
            msg = 'plz check your coin.'
            returnTrans(false)
        else
            local num1 = nil
            local num2 = nil
            num1 = subscribe.insert(subscribeVo, cn)
            num2 = memberBll.consume(member.username, package.input, cn)
            if( num1 == nil or num2 == nil ) then
                returnTrans(false)
            else
                returnTrans(true)
            end
        end
    end, function(issuccess, result)
        issucc = issuccess
    end)
    return issucc, msg
end

-- 通过课程 URL 检查是否添加对应的课程包
subscribe.checkAddPackageByLessonUrl = function(username, lessonUrl, cn)
    local sql = 'SELECT COUNT(1) FROM subscribe s LEFT JOIN package p ON s.`packageId` = p.`id` LEFT JOIN package2lesson pl ON p.`id` = pl.`packageId` WHERE s.`username` = ?username AND pl.`lessonUrl` = ?lessonUrl'
    return db.execScalar(sql, {username = username, lessonUrl = lessonUrl}, cn)
end


NPL.export(subscribe)