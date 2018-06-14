$(function(){
    // 怎么样获取coins的提示
    $('.how,.tooltip-how').on('mouseover',function(){
        $('.tooltip-how').show();
    })
    $('.how,.tooltip-how').on('mouseout',function(){
        $('.tooltip-how').hide();
    })
    //隐藏推荐人的模块
    $('.presenter-dismiss').on('click',function(){
        $('.presenter').fadeOut(500);
    })
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

            //用户图片
            if( !userinfo.portrait.startWith("http") ){
                userinfo.portrait = keepworkHost + userinfo.portrait;
            }
            $('.portrait').attr( 'src', userinfo.portrait );

            //拥有金币数
            $('.coins-num').html( userinfo.coin);

            //代码阅读行数
            $('.read-lines-num').html( userinfo.codeReadLine );

            //代码书写行数
            $('.written-lines-num').html( userinfo.codeWriteLine );

            //学习命令行
            $('.Commands-lines-num').html( userinfo.commands );

            //是否存在推荐人 存在不显示推荐人模块
            if( !userinfo.presenter ){
                $( '.presenter' ).removeClass('display-none').addClass('display-block');
                
            }
        }
    })
    //提交推荐人
    $('.add-presenter').on('click',function(){
        var val = $('input[name="presenter-name"]').val();
        if( val != '' ){
            $.post("/api/member/addPresenter",{
                presenter:val
            },function(response){
                if( response.err == 0 ){
                    openDialog({
                        width : 'auto',
                        messageClass : 'open-message',
                        message : R.msg_add_presenter
                    })
                    $('.coins-num').html( response.data.coin);
                    
                    //提交成功隐藏推荐模块
                    $('.presenter').fadeOut(500);
                }else if( response.err == 104 ){
                    openDialog({
                        width : 'auto',
                        messageClass : 'open-message',
                        message : R.msg_not_valid_account
                    })
                }else if( response.err == 105 ){
                    openDialog({
                        width : 'auto',
                        messageClass : 'open-message',
                        message : R.msg_not_allow_two_presenter
                    })
                }
            })
        }else{
            openDialog({
                width : 'auto',
                messageClass : 'open-message',
                message : R.msg_not_valid_account
            })
        }
        
    })
    var pno = 1,psize = 50;
    //获取当前用户学习记录
    $.get(LESSON_API + "/api/package/learnList", {
        psize: psize,
        pno: pno,
    }, function (response) {
        if(response.err == 0) {
            if( !Array.isArray(response.data) ){
                $( '.no-data' ).removeClass('display-none').addClass('display-block');
            }else{       
                $( '.package-list' ).removeClass('display-none').addClass('display-block');
                //课程包数量
                $('.lesson-total').html( response.page.totalCount );
                //课程包列表
                for(var i = 0;i < response.data.length; i++){
                    var item = response.data[i];
                    //年龄范围
                    if( item.agesMax == 0 && item.agesMin == 0 ){
                        item.ageMsg = R.suitable4all ;
                    }else{
                        item.ageMsg = item.agesMin + '-' + item.agesMax;
                    }
                    //继续学习链接
                   
                    //未订阅链接为空
                   if( item.subscribeState == 2){
                        item.url = ''
                   }else if( item.subscribeState == 1 ){
                        item.url = item.nextLearnLesson ? keepworkHost + item.nextLearnLesson : keepworkHost + item.firstLessonUrl;
                   }
                   //课程包链接
                   if( !item.packageUrl.startWith("http") ){
                        item.packageUrl = keepworkHost + item.packageUrl;
                    }
                    //课程包列表
                    var str = '<div class="el-col el-col-12 el-col-xs-12 el-col-sm-12 el-col-md-8 el-col-lg-8 el-col-xl-8">'+
                    '    <a href="' + item.packageUrl + '" target="_blank" class="lesson-cover">'+
                    '        <div style="background-image: url(' + item.cover + ');"></div>'+
                    '    </a>'+
                    '    <a href="' + item.packageUrl + '" target="_blank" class="title">' + item.title + '</a>'+
                    '    <div class="time">' + R.include + ': <span>'+ item.lessonCount +'</span> ' + R.lessons + '</div>'+
                    '    <div class="ages">' + R.ages +': <span>'+ item.ageMsg +'</span></div>'+
                    '    <div class="skills">' + R.skills + ': <span>'+ item.skills +'</span></div>'+
                    '    <div class="progress">'

                    //进度  
                    var proNum = Number(((item.doneCount/item.lessonCount)*100).toFixed(1));
                    if( proNum > 100 ){
                        item.lessonProgress = 100;
                    }else{
                        item.lessonProgress = proNum;
                    }

                    if( item.doneCount >= item.lessonCount ){
                        //当学完显示学完
                        str += '<div class="finished"><span>'+ R.finished +'<span><i class="el-icon-success"></i></div>'
                    }else{
                        if( item.doneCount == 0 ){
                            //未开始学习
                            str += '<div class="start"><a href="'+ keepworkHost + item.firstLessonUrl +'" class="el-button el-button--primary el-button--mini"><span>' + R.start_to_learn + '<span></a></div>'
                        }else{
                            //进度条
                            str += '<div class="lessons-progress">'+
                            // '<el-progress :stroke-width="18" :text-inside="true" :percentage="lessonProgress"></el-progress>'+
                            '<div class="el-progress el-progress--line el-progress--text-inside">'+
                                '<div class="el-progress-bar">'+
                                    '<div class="el-progress-bar__outer" style="height: 10px;">'+
                                        '<div class="el-progress-bar__inner" style="width: '+ item.lessonProgress +'%;">'+
                                            // '<div class="el-progress-bar__innerText">'+ item.lessonProgress +'%</div>'+
                                        '</div>'+
                                    '</div>'+
                                '</div>'+
                            '<div class="progress-tip">' + R.have_learned + ' '+ item.doneCount +' '+ R.lessons +'</div>'+
                            '</div>'+
                            '<div class="continu-btn">';
                            if(item.url == ''){
                                //未购买不跳转弹窗显示请先购买
                                str += '<button class="btn_continue continue el-button el-button--primary el-button--mini"><span>Continue</span></button>'                                    
                            }else{
                                //继续学习
                                str += '<a href="'+ item.url +'" class="continue el-button el-button--primary el-button--mini"><span>' + R.continue + '</span></a>'                                      
                            }
                            str += '</div></div>'
                        }
                        
                    }

                    str += '</div></div>';

                    $('.lesson-list .el-row').append(str)
                    
                }
                //请先购买弹窗
                $('.btn_continue').on('click',function(){
                    openDialog({
                        width : 'auto',
                        messageClass : 'open-message',
                        message: R.msg_plz_add_pkg
                    })
                })
                
            }
        }
    })

    
    
});