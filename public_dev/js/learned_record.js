// TODO: 切换为在 keepwork 上获取
var username = $('#username').val();
var lessonNo = $('#lessonNo').val();
var PAGE_SIZE = 50;
var no = 1;
var orderBy = 0; // 排序标识位
$(function(){
    getLessonLearnedRecord(PAGE_SIZE, no);

    $(".icon-more", ".learned-record").on('click', function() {
        getLessonLearnedRecord(PAGE_SIZE, ++no, orderBy, false);
    });
    var timeSortFlag = false,
        rateSortFlag = false,
        scoreSortFlag = false;
    $('.sort-by-time').on('click', function() {
        no = 1;
        if(timeSortFlag) {
            // 倒序
            $(this).find('.el-icon-caret-top').addClass('active').siblings().removeClass('active');
            timeSortFlag = false;
            orderBy = 101;
            getLessonLearnedRecord(PAGE_SIZE, no, orderBy);
        } else {
            // 正序
            $(this).find('.el-icon-caret-bottom').addClass('active').siblings().removeClass('active');
            timeSortFlag = true;
            orderBy = 1;
            getLessonLearnedRecord(PAGE_SIZE, no, orderBy);
        }
    });
    $('.sort-by-rate').on('click', function() {
        no = 1;
        if(rateSortFlag) {
            // 倒序
            $(this).find('.el-icon-caret-top').addClass('active').siblings().removeClass('active');
            rateSortFlag = false;
            orderBy = 102;
            getLessonLearnedRecord(PAGE_SIZE, no, orderBy);
        } else {
            // 正序
            $(this).find('.el-icon-caret-bottom').addClass('active').siblings().removeClass('active');
            rateSortFlag = true;
            orderBy = 2;
            getLessonLearnedRecord(PAGE_SIZE, no, orderBy);
        }
    });
    $('.sort-by-score').on('click', function() {
        no = 1;
        if(scoreSortFlag) {
            // 倒序
            $(this).find('.el-icon-caret-top').addClass('active').siblings().removeClass('active');
            scoreSortFlag = false;
            orderBy = 103;
            getLessonLearnedRecord(PAGE_SIZE, no, orderBy);
        } else {
            // 正序
            $(this).find('.el-icon-caret-bottom').addClass('active').siblings().removeClass('active');
            scoreSortFlag = true;
            orderBy = 3;
            getLessonLearnedRecord(PAGE_SIZE, no, orderBy);
        }
    });
});

var flag = false;
var accuracyRateArray = [];
var startTimeArray = [];
var getLessonLearnedRecord = function( psize, pno, order, reload ) {
    if(flag) {
        return false;
    }

    reload = (typeof reload !== 'undefined') ? reload : true;
    $.get("/api/record/detail", {
        username: username,
        lessonNo: lessonNo,
        psize: psize,
        pno: pno,
        order: order
    }, function (response) {
        var r = response.data;
        var p = response.page;
        
        if(pno >= p.totalPage) {
            $(".icon-more", ".learned-record").hide();
        }

        if (JSON.stringify(response.data) == "{}") {
            flag = true;
        }

        if (JSON.stringify(response.data) != "{}" && response.err == 0) {
            var tblRecord = $('.tbl-learned-record');
            if(reload) { // 重新加载数据，否则为追加数据
                tblRecord.html('');
                accuracyRateArray = [];
                startTimeArray = [];
            }
            $('.learned-times').text(p.totalCount);
            $('.lesson-no').text(r[0].lessonNo);
            $('.lesson-title').text(r[0].lessonTitle);
            for(var i = 0; i < r.length; i++) {
                var item = r[i];
                item.accuracyRate = item.rightCount/(item.rightCount + item.emptyCount + item.wrongCount);//正确率
                item.accuracyRate = item.accuracyRate ? Number(item.accuracyRate*100).toFixed(1) : 0;
                var fmtStartTime = new Date(item.beginTime).format("hh:mm yyyy/MM/dd")
                accuracyRateArray.push(item.accuracyRate);
                startTimeArray.push(fmtStartTime);
                tblRecord.append('<tr>'+
                    '    <td>' + ((p.pageNo - 1)*p.pageSize + i + 1) + '</td>'+    
                    '    <td>' + fmtStartTime + '</td>'+
                    '    <td>' + item.accuracyRate + '%</td>'+
                    '    <td>' + (item.totalScore ? item.totalScore : 0)+ '</td>'+
                    '    <td> <a href="/learnedRecord/' + item.sn + '" class="el-button el-button--primary el-button--mini">'+
                    '            View Details</a></td>'+
                    '</tr>')
            }
            myChart.data.datasets[0].data = accuracyRateArray;
            myChart.data.labels = startTimeArray;
            myChart.update();
        }
    });
}