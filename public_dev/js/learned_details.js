var recordSn = $('#recordSn').val();
var LESSON_API = $('#baseURL').val() || '';
$(function(){
    getRecordDetail();
});

var getRecordDetail = function() {
    $.get(LESSON_API + "/api/record/learnDetailBySn", {
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

// document.domain = 'localhost';
// // 计算页面的实际高度，iframe自适应会用到
// function calcPageHeight(doc) {
//     var cHeight = Math.max(doc.body.clientHeight, doc.documentElement.clientHeight);
//     var sHeight = Math.max(doc.body.scrollHeight, doc.documentElement.scrollHeight);
//     var height  = Math.max(cHeight, sHeight);
//     return height;
// }
// window.onload = function() {
//     var height = calcPageHeight(document);
//     var container = parent.document.getElementById('summaryContainer');
//     if(container) {
//         container.style.height = height + 'px';
//         container.contentWindow.document.getElementsByClassName("header")[0].style.display = 'none'; 
//         container.contentWindow.document.getElementsByClassName("main")[0].style.padding = "0";
//     }
// }