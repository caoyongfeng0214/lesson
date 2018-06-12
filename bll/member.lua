local db = NPL.load('../dal/dbutil')
local cdkeyBll = NPL.load('../bll/cdkey')
local testrecordBll = NPL.load('../bll/testrecord')

local member = {}

local tbl = 'member'

member.get = function( where, group, order, cn )
    local sql = 'SELECT sn, username, portrait, coin, identity, presenter, firstInFlag, codeReadLine, codeWriteLine, commands, presenter, vipEndTime, UNIX_TIMESTAMP(vipEndTime) vipEndUnixTime, TIMESTAMPDIFF( DAY,NOW() , vipEndTime ) vipDay FROM member'
    return db.detail(sql, where, group, order, cn)
end

member.save = function( member, cn )
    return db.insert(tbl, member, cn)
end

member.update = function( member, cn )
    return db.updateBySn(tbl, member, cn)
end

member.addPresenter = function( selfMember, presenterMember, cn )
    local issucc
    db.execInTrans(function(cn, returnTrans)
        local num1 = nil
        local num2 = nil
        selfMember.presenter = presenterMember.username
        selfMember.coin = selfMember.coin + 20
        num1 = member.update(selfMember, cn)
        presenterMember.coin = presenterMember.coin + 20
        num2 = member.update(presenterMember, cn)
        if( num1 == nil or num2 == nil ) then
            returnTrans(false)
        else
            returnTrans(true)
        end
    end, function(issuccess, result)
        issucc = issuccess
    end)
    return issucc
end

member.activateAccount = function( selfMember, cdkey, cn )
    local issucc
    db.execInTrans(function(cn, returnTrans)
        local num1 = nil
        local num2 = nil
        -- 更新账户为教育机构账户，将 cdkey 标记为已使用
        selfMember.identity = 2
        num1 = member.update(selfMember, cn)
        cdkey.user = selfMember.username
        cdkey.state = 2
        cdkey.useTime = os.date( "%Y-%m-%d %H:%M:%S", os.time() )
        cdkey.key = nil
        num2 = cdkeyBll.update(cdkey, cn)
        if( num1 == nil or num2 == nil ) then
            returnTrans(false)
        else
            returnTrans(true)
        end
    end, function(issuccess, result)
        issucc = issuccess
    end)
    return issucc
end

-- 消耗（增加）知识币
member.consume = function(username, consumeCoin, cn)
    local sql = 'UPDATE member SET coin = coin - ?consumeCoin WHERE username = ?username'
    return db.execute(sql, {consumeCoin = consumeCoin, username = username}, cn)
end

member.firstIn = function(username, cn)
    local sql = 'UPDATE member SET firstInFlag = 2 WHERE username = ?username'
    return db.execute(sql, {username = username}, cn)
end

member.achieving = function(sn, cn)
    local lessonVo = testrecordBll.get({sn = sn})
    local testrecordVo = testrecordBll.get({
        username = lessonVo.username,
        lessonUrl = lessonVo.lessonUrl,
        emptyCount = 0,
        ['!sn'] = sn
    })

    if(testrecordVo == nil) then
        --  查询用户的订阅课程包(未付费也行)是否完成，完成发放知识币奖励, 标记为已完成 subscribe
        --  更新符合条件的 subscribe 的状态，给用户添加相应的知识币
        db.execInTrans(function(cn, returnTrans)
            local num1 = nil
            local num2 = nil
            local querySubscribeSql = [[SELECT s.*, p.`output`
            FROM subscribe s LEFT JOIN package p ON s.`packageId` = p.`id` LEFT JOIN package2lesson pl ON p.`id` = pl.packageId 
            WHERE ( SELECT COUNT(1) FROM package2lesson pl WHERE p.`id` = pl.`packageId` ) = ( SELECT COUNT(DISTINCT t.lessonUrl) FROM package2lesson pl LEFT JOIN testrecord t ON pl.lessonUrl = t.lessonUrl WHERE p.`id` = pl.`packageId` AND t.username = s.`username` AND t.emptyCount = 0 )
            AND finished = 1
            AND  pl.lessonUrl = ?lessonUrl AND s.`username` = ?username ]]
            local subscribeList = db.queryAll(querySubscribeSql, lessonVo)
            if(subscribeList and #subscribeList > 0) then
                -- 达成课程包的要求
                local sumCoin = 0
                local inCase = {}
                inCase[1] = 'sn'
                inCase[2] = {}
                for i,v in ipairs(subscribeList) do
                    sumCoin = sumCoin - tonumber(v.output)
                    table.insert( inCase[2], v.sn )
                end
                echo(sumCoin)
                num1 = db.updateStatusBatch('subscribe', { finished = 2 }, inCase)
                num2 = member.consume(lessonVo.username, sumCoin )
                if num1 == nil or num2 == nil then
                    returnTrans(false)
                else
                    returnTrans(true)
                end
            end
        end, function(issuccess, result)
        
        end)
        local sql = 'UPDATE member SET codeReadLine = codeReadLine + ?codeReadLine, codeWriteLine = codeWriteLine + ?codeWriteLine, commands = commands + ?commands WHERE username = ?username'
        return db.execute(sql, {
                codeReadLine = lessonVo.codeReadLine,
                codeWriteLine = lessonVo.codeWriteLine,
                commands = lessonVo.commands,
                username = lessonVo.username
            }, cn)
    end
   return 0 
end

member.findOrInsertByName = function( username, portrait )
    local sql = 'SELECT sn, (SELECT COUNT(1) FROM class WHERE teacher = member.username) teachedCount, username, portrait, coin, identity, presenter, firstInFlag, codeReadLine, codeWriteLine, commands, presenter, vipEndTime, UNIX_TIMESTAMP(vipEndTime) vipEndUnixTime, TIMESTAMPDIFF( DAY,NOW() , vipEndTime ) vipDay FROM member'
    local memberVo = db.detail(sql, { username = username } )
    if( memberVo == nil ) then
        -- insert
        local num, lastSn = db.insert(tbl, {
            username = username,
            portrait = portrait
        })
        memberVo = {
            username = username,
            portrait = portrait,
            sn = lastSn
        }
    end
    return memberVo
end

-- 获取统计信息
member.statis = function( where, group, order, cn )
    local sql = [[SELECT m.username, m.joinTime, m.codeReadLine, m.codeWriteLine, m.commands, m.presenter,
        (SELECT COUNT(1) FROM class WHERE teacher = m.username) teached,
        (SELECT COUNT(1) FROM testrecord WHERE username = m.username) learned,
        (SELECT IFNULL( SUM( duration ), 0) FROM testrecord WHERE username = m.username) learnDuration
        FROM member m ]]
    return db.detail(sql, where, group, order, cn)
end

NPL.export(member)