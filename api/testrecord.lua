local express = NPL.load('express')
local router = express.Router:new()
local recordBll = NPL.load('../bll/testrecord')
local subscribeBll = NPL.load('../bll/subscribe')
local sitecfg = NPL.load('../confi/siteConfig')
NPL.load("(gl)script/ide/commonlib.lua")
NPL.load("(gl)script/ide/System/os/GetUrl.lua")
System = commonlib.gettable("System")

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
    local state = p.state
   
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
         -- check is add package
        local packageCount = subscribeBll.checkAddPackageByLessonUrl(username, lessonUrl)
        if(packageCount == nil or packageCount == 0) then
            res:send({
                err = 104,
                msg = 'plz take package.'
            })
            return
        end
        local rq = rq(p, {'username', 'lessonUrl'}, res) -- 必选参数
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

-- 更新学习时长 频率控制为 1 分钟
router:post('/study', function(req, res, next)
    local p = req.body
    local sn = p.sn
    local rs = {
        err = 101,
        msg = 'update duration fail.'
    }
    if( sn ) then
        local num  = recordBll.updateDuration(sn)
        if(num) then
            rs.err = 0
            rs.msg = 'update duration success.'
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
    local orderBy = p.order
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
    if(orderBy) then
        orderBy = tonumber(orderBy)
        if(orderBy == 1) then
            order = { beginTime = 'ASC' }
        elseif(orderBy == 101) then
            order = { beginTime = 'DESC' }
        elseif(orderBy == 2) then
            -- Accuracy Rate ASC
            order = { ['rightCount/(rightCount+emptyCount+wrongCount)'] = 'ASC' }
        elseif(orderBy == 102) then
            -- Accuracy Rate DESC
            order = { ['rightCount/(rightCount+emptyCount+wrongCount)'] = 'DESC' }
        elseif(orderBy == 3) then
            order = { totalScore = 'ASC' }
        elseif(orderBy == 103) then
            order = { totalScore = 'DESC' }
        end
    end
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

-- learn Detail by Sn
router:get('/learnDetailBySn', function(req, res, next)
    local rs = {}
    local p = req.query
    local sn = p.sn
    local rq = rq(p, {'sn'}, res)
    if(not rq) then return end
    local where = {
        ['t.sn'] = sn
    }
    local data = recordBll.detailBySn(where)
    if(data) then
        data.answerSheet = commonlib.Json.Decode(data.answerSheet)
        rs.err = 0
        rs.data = data
    else
        rs.err = 101
        rs.msg = 'get learn detail fail.'
    end
    res:send(rs)
end)

-- send email
router:post('/sendEmail', function(req, res, next)
    local p = req.body
    local email = p.email
    local content = p.content
    local rq = rq(p, {'email'}, res)
    if(not rq) then return end
    System.os.SendEmail({
	    url=sitecfg.replyEmail, 
	    username=sitecfg.replyUsername, password=sitecfg.replyPassword,   --这里的password 是授权密码
	    from=sitecfg.replyUsername, 
        to= email, 
	    subject = 'this is your summary.', -- title
	    body = content -- body
    }, function(err, msg) echo(msg)
	    res:send( {
            err = err,
            msg = msg
        })
    end)
end)

NPL.export(router)