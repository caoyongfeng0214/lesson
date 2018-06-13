$(function(){
    var username = '';
    var PAGE_SIZE = 50;
    //获取当前用户信息
    $.get(LESSON_API + "/api/member/auth",function(response){
        if( response.err == 0 ){
            var userinfo = response.data;

            //是否是第一次进入
            if( userinfo.firstInFlag == 1 ){
                openDialog({
                    width : 'auto',
                    messageClass : 'open-message',
                    message: R.msg_first_in
                }, function(){
                    $.post(LESSON_API + "/api/member/firstIn");
                })
            }

            //用户名
            $('.name').html( userinfo.username );
            username = userinfo.username;

            //用户图片
            if( !userinfo.portrait.startWith("http") ){
                userinfo.portrait = keepworkHost + userinfo.portrait;
            }
            $('.portrait').attr( 'src', userinfo.portrait );

            //已教课程数量
            $('.attended-num').html( userinfo.teachedCount);

            // 授课总时长
            var teachedTime = userinfo.teachedCount * 45;

            //总教学时长小时
            $('.Total-time-hr').html( Math.floor(teachedTime/60) );

            //总教学时长分钟
            $('.Total-time-min').html( Math.floor(teachedTime%60) );

            //获取已教课程列表
            getTaughtRecordList(PAGE_SIZE, 1);            

        }
    })

    var taughtSortFlag = false;

    // 教学按照上课时间排序
    $('.have-taught').on('click', '.sort-btn', function () {
        if(taughtSortFlag) {
            // 倒序
            getTaughtRecordList(PAGE_SIZE, 1)
            $(this).find('.el-icon-caret-top').addClass('active').siblings().removeClass('active');
            taughtSortFlag = false;
        } else {
            // 正序
            getTaughtRecordList(PAGE_SIZE, 1, 'asc')
            $(this).find('.el-icon-caret-bottom').addClass('active').siblings().removeClass('active');
            taughtSortFlag = true
        }
    });

    //激活码
    $('.add-activation').on('click',function(){
        var val = $('input[name="activation-code"]').val();
        if( val != '' ){
            $.post(LESSON_API + "/api/member/activate",{
                key:val
            },function(response){
                if( response.err == 0 ){
                    window.location.href = '/teacherColumn/detail';
                }else if( response.err == 123 ){
                    //当前账户已激活不需要重复激活
                    openDialog({
                        width : 'auto',
                        messageClass : 'open-message',
                        message : R.msg_activated_account
                    })
                }else if( response.err == 124 ){
                    //不存在该激活码
                    openDialog({
                        width : 'auto',
                        messageClass : 'open-message',
                        message : R.msg_incorrect_cdkey
                    })
                }else if( response.err == 125 ){
                    // 激活码已被使用
                    openDialog({
                        width : 'auto',
                        messageClass : 'open-message',
                        message : R.msg_already_used_cdkey
                    })
                }
            })
        }else{
            openDialog({
                width : 'auto',
                messageClass : 'open-message',
                message : R.msg_plz_input_cdkey
            })
        }
        
    })

    // 获取教学记录
    var getTaughtRecordList = function ( psize, pno, order, reload ) {
        reload = (typeof reload !== 'undefined') ?  reload : true; // reload 缺省时为 true 
        $.get(LESSON_API + "/api/class/taught", {
            username: username,
            psize: psize,
            pno: pno,
            order: order
        }, function (response) {
            if(response.err == 0) {
                if( !Array.isArray(response.data) ){
                    $( '.no-data' ).removeClass('display-none').addClass('display-block');
                }else{
                    var haveTaughtList = $('.have-taught-list');                    
                    $('.have-taught').removeClass('display-none').addClass('display-block');
                    
                    if(reload) { // 重新加载数据，否则为追加数据
                        haveTaughtList.html('');
                    }
                    for(var i = 0; i < response.data.length; i++) {
                        var item = response.data[i];
                        item.lessonCover = item.lessonCover.startsWith('http')?item.lessonCover:keepworkHost + item.lessonCover;
                        
                        var itemStr = '<div class="have-item">' +
                        '<div class="time">'+ new Date(item.startTime).format("hh:mm dd/MM/yyyy") +'</div>' +
                        '<div class="layout-box el-row el-row--flex">' +
                        '    <div class="item-cover "><a href="' + (keepworkHost + item.lessonUrl)+ '" target="_blank" class="title"><div class="cover" style="background-image: url('+ item.lessonCover +')"></div></a></div>' +
                        '    <div class="content">';
                        if( item.pkgs ){
                            itemStr += '<div class="package-title"><span>' + R.pkg + ': </span>';
                            for( var j = 0; j < item.pkgs.length;j++ ){
                                itemStr += '<a href="' + (keepworkHost + item.pkgs[j].pkgUrl)+ '" target="_blank" class="title"> '+ item.pkgs[j].pkgTitle +'</a>'
                            }
                            itemStr += '</div>';
                        }
                        itemStr += '<div class="lesson-title"><a href="' + (keepworkHost + item.lessonUrl)+ '" target="_blank" class="title">'+ R.lesson +' '+ item.lessonNo +'：<span>'+ item.lessonTitle +'</span></a></div>' +
                        '        <div class="duration">' + R.duration + '：<span>45' + R.minutes + '</span></div>' +
                        '        <div class="goals">' +
                        '            <div>' + R.goals + ':</div>' +
                        '            <ul>' +
                        '                <li>'+ item.goals +'</li>' +
                        '            </ul>' +
                        '        </div>' +
                        '        <div class="foot">' +
                        '            <a href="/taughtedRecord/' + item.classId + '" class="el-button el-button--primary el-button--mini">' + R.view_summary + '</a>' +
                        '        </div>' +
                        '    </div>' +
                        '</div>' +
                        '</div>'
                        
                        haveTaughtList.append(itemStr);

                        
                    }
                }
                
            }
        })
    }

})