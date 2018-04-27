local express = NPL.load('express')
local router = express.Router:new()
local recordBll = NPL.load('../bll/testrecord')

-- 保存或更新
router:post('/saveOrUpdate', function(req, res, next)
    local p = req.body
    local sn = p.sn
    local username = p.username
    local lessonUrl = p.lessonUrl
    local lessonTitle = p.lessonTitle
    local lessonCover = p.lessonCover
    local goals = p.goals
    local lessonNo = p.lessonNo
    local lessonPerformance = p.lessonPerformance
    local answerSheet = p.answerSheet
    local totalScore = p.totalScore
    local rightCount = p.rightCount
    local wrongCount = p.wrongCount
    local emptyCount = p.emptyCount
    local rs = {}
    if( sn ) then
        -- update
        p.finishTime = os.date( "%Y-%m-%d %H:%M:%S", os.time() )
        local num = recordBll.update(p)
        if(num) then
            rs = {
                err = 0,
                data = {
                    recordSn = sn
                }
            }
        else
            rs = {
                err = 101,
                msg = 'update record fail.'
            }
        end
    else
        -- save 
        local rq = rq(p, {'username', 'lessonUrl'}, res)
        if(not rq) then return end
        local num, lastId = recordBll.save(p)
        if(lastId) then
            rs = {
                err = 0,
                data = {
                    url = lessonUrl,
                    recordSn = lastId
                }
            }
        else
            rs = {
                err = 101,
                msg = 'save record fail.'
            }
        end
    end
    res:send(rs)
end)

-- Have learned 记录
router:get('/learn', function(req, res, next)
    local rs = {}
    local p = req.query
    local username = p.username -- TODO: 更换为当前登录用户
    local rq = rq(p, {'username'}, res)
    if(not rq) then return end
    local where = { username = username }
    local group = {'lessonNo'}
    local order = { lessonNo = 'DESC' }
    if(p.order == 'asc') then
        order.lessonNo = 'ASC'
    end
    local limit = {
        pageSize = p.psize,
        pageNo = p.pno
    }
    local list, page = recordBll.learnRecord(where, group, order, limit)
    if(list) then
        rs.err = 0
        rs.data = list
        rs.page = page
    else
        rs.err = 101
        rs.msg = 'get learn record fail.'
    end
    res:send(rs)
end)

-- learn Detail
router:get('/detail', function(req, res, next)
    local rs = {}
    local p = req.query
    local lessonNo = p.lessonNo
    local username = p.username
    local rq = rq(p, {'lessonNo', 'username'}, res)
    if(not rq) then return end
    local where = {
        lessonNo = lessonNo,
        username = username
    }
    local order = { beginTime = 'DESC' }
    local limit = {
        pageSize = p.psize,
        pageNo = p.pno
    }
    local list, page = recordBll.detail(where, nil, order, limit )
    if(list) then
        for i,v in ipairs(list) do
            v.answerSheet = commonlib.Json.Decode(v.answerSheet)
        end
        rs.err = 0
        rs.data = list
        rs.page = page
    else
        rs.err = 101
        rs.msg = 'get learn detail fail.'
    end
    res:send(rs)
end)

NPL.export(router)