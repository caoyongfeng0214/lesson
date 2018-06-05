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
        $('.presenter').hide();
    })
    //获取当前用户信息
    $.get("/api/member/auth",function(response){
        if( response.err == 0 ){
            var userinfo = response.data;

            //是否是第一次进入
            if( userinfo.firstInFlag == 1 ){
                console.log( '第一次进入' )
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
            if( userinfo.presenter ){
                $('.presenter').hide();
            }
        }
    })
    //提交推荐人
    $('.add-presenter').on('click',function(){
        var val = $('input[name="presenter-name"]').val();
        console.log( val );
        if( val != '' ){
            // $.post("/api/member/addPresenter",{
            //     presenter:val
            // },function(response){
            //     if( response.err == 0 ){
            //         console.log( '推荐成功' );
            //         //提交成功隐藏推荐模块
            //         $('.presenter').hide();
            //     }
            // })
        }else{

        }
        
    })
    var pno = 1,psize = 20;
    //获取当前用户学习记录
    $.get("/api/package/learnList", {
        psize: psize,
        pno: pno,
    }, function (response) {
        if(response.err == 0) {
            console.log( response );
        }
    })

    //弹窗设置
    // function openDialog(content){
    //     var content
    // }
    // openDialog()
    
});