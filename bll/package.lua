local db = NPL.load('../dal/dbutil')
local package2lessonBll = NPL.load('./package2lesson')

local package = {}

local tbl = 'package'

package.get = function( where, group, order, cn )
    local sql = 'SELECT id, title, cover, skills, agesMin, agesMax, input, output, prerequisite, packageUrl FROM package'
    return db.detail(sql, where, group, order, cn)
end

package.upsert = function( package, cn )
    return db.upsert(tbl, package, cn)
end

package.createOrUpdate = function( packageVo, lessonsVo )
    local issucc
    db.execInTrans(function(cn, returnTrans)
        -- upsert package, 先删除所有 package2lesson 然后添加新的对应关系
        local num1 = nil
        local num2 = nil
        local num3 = nil
        num1 = package.upsert(packageVo, cn) -- upsert package
        num2 = package2lessonBll.del( {packageId = packageVo.id}, cn )
        local objs = {}
        for i,v in ipairs(lessonsVo) do
            if(v.url) then
                local obj = {}
                obj[1] = packageVo.id
                obj[2] = v.url
                table.insert (objs,obj);
            end
        end
        num3 = package2lessonBll.addBatch( {'packageId', 'lessonUrl'}, objs, cn )
        if( num1 == nil or num2 == nil or num3 == nil ) then
            returnTrans(false)
        else
            returnTrans(true)
        end
    end, function(issuccess, result)
        issucc = issuccess
    end)
    return issucc
end

package.list = function ( where, group, order, limit, cn )
    local sql = [[SELECT p.*, ( SELECT COUNT(1) FROM package2lesson pl WHERE p.`id` = pl.`packageId` ) AS lessonCount,
        ( SELECT IF(t.emptyCount=0, (SELECT pls.lessonUrl FROM package2lesson pls LEFT JOIN testrecord tr ON pls.lessonUrl = tr.lessonUrl WHERE pls.packageId =  p.`id` AND pls.lessonUrl <> t.lessonUrl AND (tr.emptyCount <> 0 OR tr.emptyCount IS NULL) ORDER BY (CASE WHEN pls.`index`< (SELECT `index` FROM package2lesson WHERE packageId = p.id AND lessonUrl = t.lessonUrl) THEN pls.`index` + 1000 ELSE pls.`index` END) LIMIT 1),t.lessonUrl) 
        FROM testrecord t WHERE lessonUrl IN (SELECT lessonUrl FROM package2lesson pls WHERE pls.packageId =  p.`id`) ORDER BY t.beginTime DESC LIMIT 1 ) nextLearnLesson
        FROM package p LEFT JOIN subscribe sb ON p.`id` = sb.`packageId`]]
    return db.findJoin(sql, where, group, order, limit, cn)
end

NPL.export(package)
