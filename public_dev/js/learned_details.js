var recordSn = $('#recordSn').val();

$(function(){
    getRecordDetail();
});

var getRecordDetail = function() {
    $.get("/api/record/learnDetailBySn", {
        sn: recordSn
    }, function(response) {
        var r = response.data;
        if(response.err == 0) {
            $('.lesson-no').text(r.lessonNo);
            $('.lesson-title').text(r.lessonTitle);
            $('.lesson-duration').text(r.duration);
            $('.lesson-performance').text(r.lessonPerformance);
            $('.learned-days').text( genEnNum(r.learnedDays) );
            $('.lesson-time').text( fmtDate(r.beginTime) );
        }
    });
}

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
var fmtDate = function( dateStr ) {
    var weekArr = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    var monthArr = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    var d = new Date(dateStr);
    var week = weekArr[ d.getDay() ];
    var day = genEnNum( d.getDate() );
    var month = monthArr[ d.getMonth() ];
    var year = d.getFullYear();
    return week + ' ' + day + ', ' + month + ', ' + year;
}