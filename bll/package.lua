local db = NPL.load('../dal/dbutil')
local package2lessonBll = NPL.load('./package2lesson')

local package = {}

local tbl = 'package'

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
            if(v.lessonUrl) then
                local obj = {}
                obj[1] = packageVo.id
                obj[2] = v.lessonUrl
                table.insert (objs,obj)
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

NPL.export(package)
