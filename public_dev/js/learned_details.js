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
