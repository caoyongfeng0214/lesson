Date.prototype.format = function(fmt) {
    var o = {
        "M+": this.getMonth() + 1, //Month
        "d+": this.getDate(), //Day
        "h+": this.getHours(), //Hour
        "m+": this.getMinutes(), //Minute
        "s+": this.getSeconds(), //Second
        "q+": Math.floor((this.getMonth() + 3) / 3), //Season
        "S": this.getMilliseconds() //millesecond
    };
    if (/(y+)/.test(fmt)) fmt = fmt.replace(RegExp.$1, (this.getFullYear() + "").substr(4 - RegExp.$1.length));
    for (var k in o)
        if (new RegExp("(" + k + ")").test(fmt)) fmt = fmt.replace(RegExp.$1, (RegExp.$1.length == 1) ? (o[k]) : (("00" + o[k]).substr(("" + o[k]).length)));
    return fmt;
}

String.prototype.startWith = function(s) {
    if (s == null || s == "" || this.length == 0 || s.length > this.length)
        return false
    if (this.substr(0, s.length) == s)
        return true
    else
        return false
    return true
}

String.prototype.replaceAll = function(f, e) {
    var reg=new RegExp(f,"g");
    return this.replace(reg,e); 
}

var keepworkHost = 'http://localhost:8080';
/**
 * number format english eg: 1 -> 1st 2 -> 2nd
 * @param number 
 */
var genEnNum = function( number ) {
    if( isNaN(number) ) {
        return '0'
    }
    var g = number % 10;
    var b = number % 100;
    if(number == 0) {
        return '0';
    } else if(b == 11 || b == 12 || b == 13) {
        return number + 'th';
    } else if(g == 1) {
        return number + 'st';
    } else if(g == 2) {
        return number + 'nd';
    } else if(g == 3) {
        return number + 'rd';
    } else {
        return number + 'th';
    }
}

/**
 * format date -> Friday 27th, April, 2018
 * @param dateStr 
 */
var fmtDate = function( dateStr , fmtStr ) {
    var weekArr = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    var monthArr = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    var d = new Date(dateStr);
    var week = weekArr[ d.getDay() ];
    var day = genEnNum( d.getDate() );
    var month = monthArr[ d.getMonth() ];
    var year = d.getFullYear();
    if(fmtStr && fmtStr == 'dd, MM, yyyy') {
        return day + ', ' + month + ', ' + year;
    }
    return week + ' ' + day + ', ' + month + ', ' + year;
}

/* 
    open dialog
    @params  label string
             message string 
             input boolean
             cancelBtn boolean
             callback return input.val
             messageClass
             height
             width
*/
var openDialog = function( params,callback ){
    // 弹窗标题
    params.label = params.label ? params.label :'';
    //弹窗信息
    params.message = params.message ? params.message :'';
    // 添加弹窗信息class
    params.messageClass = params.messageClass ? params.messageClass : ''
 
    //弹窗内容
    var str = '<div tabindex="-1" role="dialog" aria-modal="true" aria-label="'+ params.label +'" class="open-dialog el-message-box__wrapper" style="z-index: 2081;">'
            +'<div class="el-message-box el-message-box--center" style="height:'+ params.height +';width:'+ params.width +'">'
            +'<div class="el-message-box__header">'
            +'<button type="button" aria-label="Close" class="close-icon el-message-box__headerbtn">'
            +'<i class="el-message-box__close el-icon-close"></i>'
            + '</button>'
            +'</div>'
            +'<div class="el-message-box__content">'
            + '<div class="el-message-box__message '+ params.messageClass +'">'
            +  '<p>'+ params.message +'</p>'
            + '</div>';
    //需要输入框
    if( params.input ){
        str += '<div class="el-message-box__input">'
        + '<div class="el-input">'
        + '<input type="text" name="openInput" autocomplete="off" placeholder="" class="el-input__inner">'
        + '</div>'
        + '<div class="el-message-box__errormsg" style="visibility: hidden;"></div>'
        + '</div>';
    }

    str += '</div>'
        +'<div class="el-message-box__btns">'

    //需要取消按钮
    if( params.cancelBtn ){
        str += '<button type="button" class="cancel-btn el-button el-button--default el-button--small">'
        + '<span>Cancel</span>'
        +'</button>';;
    }
            
    str += '<button type="button" class="ok-btn el-button el-button--default el-button--small el-button--primary ">'
    +   '<span>OK</span>'
    +'</button>'
    +'</div>'
    +' </div>'
    +'</div>'
    +'<div class="v-modal" tabindex="0" style="z-index: 2080;"></div>'

    $('.main').append(str);

    //相关操作
    //关闭弹窗
    
    $( '.open-dialog .close-icon,.open-dialog .cancel-btn' ).on('click',function(){
        $('.open-dialog,.v-modal').fadeOut(500);
    })

    //确定
    $( '.open-dialog .ok-btn' ).on('click',function(){
        if( $('.open-dialog input[name="openInput"]').val() ){
            callback($('.open-dialog input[name="openInput"]').val());
        }else{
            // 没有输入框时的回调
            callback();
            $('.open-dialog,.v-modal').fadeOut(500);
        }
    })
}