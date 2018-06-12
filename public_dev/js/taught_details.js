var recordSn = $('#recordSn').val();
var studentNo = $('#studentNo').val();
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
            $('.lesson-time').text( fmtDate(r.beginTime) );
            $('.student-name').text(r.username);
            $('.student-no').text(studentNo);
            r.accuracyRate = r.rightCount/(r.rightCount + r.emptyCount + r.wrongCount); // 正确率
            r.accuracyRate = r.accuracyRate ? Number(r.accuracyRate*100).toFixed(1) : 0;
            $('.accuracy-rate').text(r.accuracyRate + '%');
            if(r.answerSheet) {
                for(var i = 0; i < r.answerSheet.length; i++) {
                    var item = r.answerSheet[i];
                    $('.tbl-head').append('<td>'+
                        '    Quiz ' + (i + 1) +
                        '</td>');
                    $('.tbl-body').append('<td><span class="' + (item.trueFlag ? 'right' : 'wrong') + '">' + item.myAnswer + '</span></td>');
                }
            }
        }
    });
}