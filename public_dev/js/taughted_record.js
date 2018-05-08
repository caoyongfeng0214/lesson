var taughtedChart = document.getElementById("taughtedChart").getContext('2d');
var chartRate = new Chart(taughtedChart, {
    type: 'bar',
    data: {
        labels: [],
        datasets: [{
            label: 'Horizontal Axis: Quizzes, Vertical Axis: Accuracy Rate(%)',
            data: [],
            backgroundColor: [
                'rgba(255, 99, 132, 0.2)',
                'rgba(54, 162, 235, 0.2)',
                'rgba(255, 206, 86, 0.2)',
                'rgba(75, 192, 192, 0.2)',
                'rgba(255, 159, 64, 0.2)'
            ],
            borderColor: [
                'rgba(255,99,132,1)',
                'rgba(54, 162, 235, 1)',
                'rgba(255, 206, 86, 1)',
                'rgba(75, 192, 192, 1)',
                'rgba(255, 159, 64, 1)'
            ],
            borderWidth: 1
        }]
    },
    options: {
        title: {
            display: true
        },      
        scales: {
            yAxes: [{
                ticks: {
                    beginAtZero:true
                }
            }]
        }
    }
});

var studentChart = document.getElementById("studentChart").getContext('2d');
var chartStudent = new Chart(studentChart, {
    type: 'bar',
    data: {
        labels: ["<60%", "60%-80%", ">80%"],
        datasets: [{
            label: 'Horizontal Axis: Accuracy Rate, Vertical Axis: Number of Students (total: 0)',
            data: [0, 0, 0],
            backgroundColor: [
                'rgba(255, 99, 132, 0.2)',
                'rgba(54, 162, 235, 0.2)',
                'rgba(255, 206, 86, 0.2)'
            ],
            borderColor: [
                'rgba(255,99,132,1)',   
                'rgba(54, 162, 235, 1)',
                'rgba(255, 206, 86, 1)'
            ],
            borderWidth: 1
        }]
    },
    options: {
        title: {
            display: true,
        },      
        scales: {
            yAxes: [{
                ticks: {
                    beginAtZero:true
                }
            }]
        }
    }
});

var classId = $('#classId').val();
$(function(){
    getLessonTaughtedRecord();
    var nameSortFlag = false,
        noSortFlag = false,
        rateSortFlag = false,
        rightSortFlag = false,
        wrongSortFlag = false,
        emptySortFlag = false;
    var compare = function(prop, ascFlag) {
        return function(a,b){
            var value1 = a[prop];
            var value2 = b[prop];
            // 特殊处理正确率和学号
            if(prop == 'accuracyRate') {
                value1 = parseFloat(a[prop]);
                value2 = parseFloat(b[prop]);
            }
            var ret = 0;
            value1 > value2 ? ret = 1 : ret = -1;
            return ascFlag ? ret : -ret;
        }
    }
    var sortList = function(prop, ascFlag) {
        summary.sort(compare(prop, ascFlag));
        console.log(summary);
        tblRecord.html('');
        for(var i = 0; i < summary.length; i++) {
            appendRecord(summary[i]);
        }
    }
    /* Sort Begin */
    $('.sort-by-name').on('click', function() {
        if(nameSortFlag) {
            // 倒序
            $(this).find('.el-icon-caret-top').addClass('active').siblings().removeClass('active');
            nameSortFlag = false;
            sortList('username',false);
        } else {
            // 正序
            $(this).find('.el-icon-caret-bottom').addClass('active').siblings().removeClass('active');
            nameSortFlag = true
            sortList('username',true);
        }
    });
    $('.sort-by-no').on('click', function() {
        if(noSortFlag) {
            // 倒序
            $(this).find('.el-icon-caret-top').addClass('active').siblings().removeClass('active');
            noSortFlag = false;
            sortList('studentNo',false);
        } else {
            // 正序
            $(this).find('.el-icon-caret-bottom').addClass('active').siblings().removeClass('active');
            noSortFlag = true
            sortList('studentNo',true);
        }
    });
    $('.sort-by-rate').on('click', function() {
        if(rateSortFlag) {
            // 倒序
            $(this).find('.el-icon-caret-top').addClass('active').siblings().removeClass('active');
            rateSortFlag = false;
            sortList('accuracyRate',false);
        } else {
            // 正序
            $(this).find('.el-icon-caret-bottom').addClass('active').siblings().removeClass('active');
            rateSortFlag = true;
            sortList('accuracyRate',true);
        }
    });
    $('.sort-by-right').on('click', function() {
        if(rightSortFlag) {
            // 倒序
            $(this).find('.el-icon-caret-top').addClass('active').siblings().removeClass('active');
            rightSortFlag = false;
            sortList('rightCount',false);
        } else {
            // 正序
            $(this).find('.el-icon-caret-bottom').addClass('active').siblings().removeClass('active');
            rightSortFlag = true;
            sortList('rightCount',true);
        }
    });
    $('.sort-by-wrong').on('click', function() {
        if(wrongSortFlag) {
            // 倒序
            $(this).find('.el-icon-caret-top').addClass('active').siblings().removeClass('active');
            wrongSortFlag = false;
            sortList('wrongCount',false);
        } else {
            // 正序
            $(this).find('.el-icon-caret-bottom').addClass('active').siblings().removeClass('active');
            wrongSortFlag = true;
            sortList('wrongCount',true);
        }
    });
    $('.sort-by-empty').on('click', function() {
        if(emptySortFlag) {
            // 倒序
            $(this).find('.el-icon-caret-top').addClass('active').siblings().removeClass('active');
            emptySortFlag = false;
            sortList('emptyCount',false);
        } else {
            // 正序
            $(this).find('.el-icon-caret-bottom').addClass('active').siblings().removeClass('active');
            emptySortFlag = true;
            sortList('emptyCount',true);
        }
    });
    /* Sort End */
    // 发送 email
    $('#sendEmail').on('click', function() {
        var email=prompt("Please enter your email address:");  
        if(email) {  
            $.post('/api/record/sendEmail', {
                email: email,
                content: $('.record-container').html() + '<style>.displayFlex{display:flex;display:-webkit-flex;display:-moz-flex;display:-ms-flex;display:-o-flex}.notselect{user-select:none;-webkit-user-select:none;-moz-user-select:none;-ms-user-select:none;-o-user-select:none}.recordWrapper{max-width:1200px;height:auto;margin:0 auto;background-color:#fff}.my-record{padding:45px 10px 45px 8%}.my-record .user-info{display:flex;display:-webkit-flex;display:-moz-flex;display:-ms-flex;display:-o-flex;align-items:center;-webkit-align-items:center;-moz-align-items:center;-ms-align-items:center;-o-align-items:center}.my-record .portrait{border-radius:50%;-webkit-border-radius:50%;-moz-border-radius:50%;-ms-border-radius:50%;-o-border-radius:50%;width:60px;height:60px;object-fit:cover;-o-object-fit:cover}.my-record .portrait+strong{margin-left:15px;color:#333;font-size:20px}.my-record .info{margin:30px 0 90px;color:#333;font-size:16px}.my-record .info em{color:#49A5F8}.my-record .el-button{padding:17px 19px;font-size:16px;margin-left:-45px}.record-list .tab-nav{padding:40px 10px 0 15%;border-bottom:1px solid#E5E5E5}.record-list .tab-nav>a{display:inline-block;padding-bottom:15px;margin:0 5%;font-size:22px;color:#333}.record-list .tab-nav>a.current{color:#49A5F8;border-bottom:2px solid #49A5F8}.record-list .tab-nav>a:hover{color:#49A5F8}.record-list .tab-content{padding:30px 0}.record-list .tab-content .have-item{border:1px solid #E5E5E5;margin-bottom:20px}.record-list .tab-content .have-item .time{padding:8px 15px;color:#181818;font-size:18px;border-bottom:1px solid #E5E5E5}.record-list .tab-content .have-item .layout-box{display:flex;display:-webkit-flex;display:-moz-flex;display:-ms-flex;display:-o-flex;align-items:center;-webkit-align-items:center;-moz-align-items:center;-ms-align-items:center;-o-align-items:center;padding:15px 20px 15px 10px}.record-list .tab-content .have-item .layout-box .cover{width:250px;height:146px;margin-right:20px;background-repeat:no-repeat;background-position:center center;background-size:cover}.record-list .tab-content .have-item .layout-box .content{flex:1}.record-list .tab-content .have-item .layout-box .content .title{font-size:18px;color:#181818}.record-list .tab-content .have-item .layout-box .content .title:hover{color:#49A5F8}.record-list .tab-content .have-item .layout-box .content .goals{margin:12px 0;font-size:14px}.record-list .tab-content .have-item .layout-box .content .goals>span{color:#999}.record-list .tab-content .have-item .layout-box .content .goals>ul{padding-left:18px}.record-list .tab-content .have-item .layout-box .content .goals>ul li{margin-top:8px;color:#333}.record-list .tab-content .have-item .layout-box .content .foot{width:80%;display:flex;display:-webkit-flex;display:-moz-flex;display:-ms-flex;display:-o-flex;align-items:center;-webkit-align-items:center;-moz-align-items:center;-ms-align-items:center;-o-align-items:center;justify-content:space-between;-webkit-justify-content:space-between;-moz-justify-content:space-between;-ms-justify-content:space-between;-o-justify-content:space-between;color:#111}.record-list .tab-content .have-item .layout-box .content .foot span{margin-left:15px}.record-list .tab-content .have-item .layout-box .content .foot span em{color:#FF414A}.sort-btn{display:flex;display:-webkit-flex;display:-moz-flex;display:-ms-flex;display:-o-flex;padding:25px;font-size:16px;color:#333;cursor:pointer;user-select:none}.sort-btn .sort-icon{padding-right:5px}.sort-btn .sort-icon>i{display:block;line-height:8px;color:#CCC}.sort-btn .sort-icon>i.active{color:#49A5F8}.learned-record,.taughted-record{padding:45px 8%}.learned-record .item,.taughted-record .item{margin-bottom:40px;color:#111;font-size:16px;margin-right:3%}.learned-record .item>div,.taughted-record .item>div{margin-top:12px}.learned-record .item>span,.taughted-record .item>span{color:#111;font-weight:700}.learned-record .item em,.taughted-record .item em{color:#FF414A}.learnedDetails{width:100%;padding:80px 70px 60px;box-shadow:5px 4px 20px rgba(64,158,254,.44);position:relative}.learnedDetails::after,.learnedDetails::before{content:"";position:absolute;top:18px;z-index:2;width:20px;height:20px;background:#eb5a49;box-shadow:8px 4px 2px rgba(235,63,43,.44);border-radius:50%;-webkit-border-radius:50%;-moz-border-radius:50%;-ms-border-radius:50%;-o-border-radius:50%}.learnedDetails::after{left:25px}.learnedDetails::before{right:25px}.learnedDetails ul{list-style:none}.learnedDetails ul li{font-size:16px;color:#111;margin:20px 0}.learnedDetails em{color:#FF414A}.table-wrap{width:100%;margin-top:40px;border:1px solid #BFBFBF;border-radius:8px;-webkit-border-radius:8px;-moz-border-radius:8px;-ms-border-radius:8px;-o-border-radius:8px}.table-wrap td{height:50px;padding:8px 10px;text-align:center;font-size:14px}.table-wrap thead td{border-right:1px solid #BFBFBF;border-bottom:2px solid #bfbfbf;font-size:16px}.table-wrap thead td:last-child{border-right:none}.table-wrap .sort-btn{padding:0;justify-content:center;align-items:center}.table-wrap .sort-btn .sort-icon{padding-left:5px}.table-wrap tbody tr:nth-child(even){background:rgba(64,158,254,.1)}.table-wrap .user-img{width:40px;height:40px;margin:0 auto;border-radius:50%;-webkit-border-radius:50%;-moz-border-radius:50%;-ms-border-radius:50%;-o-border-radius:50%;background-size:contain;background-repeat:no-repeat;background-position:center center}.draw-user{height:30px;overflow:hidden}.draw-user::after,.draw-user::before{content:"";display:block;width:14px;height:14px;margin:0 auto;border:2px solid #49A5F8;border-radius:50%;-webkit-border-radius:50%;-moz-border-radius:50%;-ms-border-radius:50%;-o-border-radius:50%}.draw-user::after{width:24px;height:24px}.icon-more{transform:rotate(90deg);-webkit-transform:rotate(90deg);-moz-transform:rotate(90deg);-ms-transform:rotate(90deg);-o-transform:rotate(90deg);font-size:24px}.taughted-record{padding:40px 5%}.taughted-record .record-operate{text-align:right;margin-right:3%}.taughted-record .record-container{margin-top:20px;padding:30px;background:rgba(121,176,255,.05)}.taughted-record .item ol{padding-left:18px}.taughted-record .item ol li{margin-top:8px;color:#333}.taughted-record .item .chartLayout{display:flex;display:-webkit-flex;display:-moz-flex;display:-ms-flex;display:-o-flex}.taughted-record .item .chartLayout>div{width:50%}.taughted-record .student-info{display:flex;display:-webkit-flex;display:-moz-flex;display:-ms-flex;display:-o-flex}.taughted-record .student-taughted-details .express>span{margin-right:10px;font-size:14px;color:#676767}.taughted-record .student-taughted-details .express .r::before,.taughted-record .student-taughted-details .express .w::before{content:"";width:12px;height:12px;display:inline-block;margin:0 15px;vertical-align:middle;border-radius:50%;-webkit-border-radius:50%;-moz-border-radius:50%;-ms-border-radius:50%;-o-border-radius:50%}.taughted-record .student-taughted-details .express .r::before{background-color:#27CE2F}.taughted-record .student-taughted-details .express .w::before{background-color:#F53838}.taughted-record .student-taughted-details .table-wrap{margin-top:15px}.taughted-record .student-taughted-details .table-wrap .right{color:#27CE2F}.taughted-record .student-taughted-details .table-wrap .wrong{color:#F53838}@media (max-width:992px){.taughted-record{padding:20px}.taughted-record .record-container{padding:25px}}@media (max-width:768px){.record-list .tab-content{padding:20px 0}.record-list .tab-content .have-item .layout-box .content .foot{width:100%}.sort-btn{padding:15px}.learned-record .item,.taughted-record .item{margin-bottom:25px}.learned-record .item>div,.taughted-record .item>div{margin-top:8px}.table-wrap{margin-top:25px}.table-wrap .sort-btn,.table-wrap thead td{font-size:14px}.table-wrap td{padding:8px}}</style>'
            }, function(response) {
                console.log(response);
            })
        } 
    });
});

var tblRecord = $('.record-tbl');
var summary = [];
var getLessonTaughtedRecord = function() {
    $.get("/api/class/detail", {
        classId: classId
    }, function (response) {
        var r = response.data;
        if (response.err == 0) {
            $('.lesson-no').text(r.lessonNo);
            $('.lesson-title').text(r.lessonTitle);
            $('.lesson-time').text( fmtDate(r.startTime) );
            $('.lesson-goals').text(r.goals);
            if(r.summary instanceof Array) {
                summary = r.summary;
                var quizzLable = []; // quizz 图表的 Lable
                var quizzRight = []; // quizz 正确的人数
                var quizzRate = []; // quizz 正确率
                var studentDiv = [0, 0, 0]; // 学生分布
                if(r.summary[0] && r.summary[0].answerSheet) {
                    
                    for(var i = 0; i < r.summary[0].answerSheet.length; i++) {
                        var label = 'Quiz' + (i + 1);
                        quizzLable.push(label);
                        quizzRight.push(0);
                        quizzRate.push(0);
                    }
                }
                for(var i = 0; i < r.summary.length; i++) {
                    var item = r.summary[i];
                    item.rightCount = parseInt(item.rightCount);
                    item.wrongCount = parseInt(item.wrongCount);
                    item.emptyCount = parseInt(item.emptyCount);
                    item.accuracyRate = item.rightCount/(item.rightCount + item.emptyCount + item.wrongCount); // 正确率
                    item.accuracyRate = item.accuracyRate ? Number(item.accuracyRate*100).toFixed(1) : 0;
                    appendRecord(item);
                    // 解析 item.answerSheet
                    if(item.accuracyRate < 60) {
                        studentDiv[0] += 1;// <60
                    } else if(item.accuracyRate >=60 && item.accuracyRate <= 80) {
                        studentDiv[1] += 1;// 60-80 
                    } else if(item.accuracyRate > 80) {
                        studentDiv[2] += 1;// >80
                    }
                    var sheet = item.answerSheet;
                    for(var m = 0; m < sheet.length; m++) {
                        var quizz = sheet[m];
                        if(quizz.trueFlag) {
                            quizzRight[i] += 1;
                        }
                    }
                }
                if(r.summary[0] && r.summary[0].answerSheet) {
                    for(var i = 0; i < r.summary[0].answerSheet.length; i++) {
                        quizzRate[i] = quizzRight[i] / quizzRight.length;
                        quizzRate[i] =  quizzRate[i] ? Number( quizzRate[i]*100).toFixed(1) : 0;
                    }
                }
                chartRate.data.labels = quizzLable;
                chartRate.data.datasets[0].data = quizzRate;
                chartStudent.data.datasets[0].data = studentDiv;
                chartStudent.data.datasets[0].label = 'Horizontal Axis: Accuracy Rate, Vertical Axis: Number of Students (total: ' + r.summary.length + ')'
                chartRate.update();
                chartStudent.update();
            }
        }
    });
}

var appendRecord = function(item) {
    tblRecord.append('<tr>'+
    '    <td>'+
    '        <div class="user-img" style="background-image:url(https://avatars3.githubusercontent.com/u/18064049?s=460&v=4)"></div>'+
    '    </td>'+
    '    <td>' + item.username + '</td>'+
    '    <td>' + item.studentNo + '</td>'+
    '    <td>' + item.accuracyRate + '%</td>'+
    '    <td>' + item.rightCount + '</td>'+
    '    <td>' + item.wrongCount + '</td>'+
    '    <td>' + item.emptyCount + '</td>'+
    '    <td>'+
    '        <a target="_blank" href="/taughtedRecord/details/' + item.recordSn + '/' + item.studentNo + '" class="el-button el-button--primary el-button--mini">View Details</a>'+
    '    </td>'+
    '</tr>');
}

document.domain = 'localhost';
// 计算页面的实际高度，iframe自适应会用到
function calcPageHeight(doc) {
    var cHeight = Math.max(doc.body.clientHeight, doc.documentElement.clientHeight);
    var sHeight = Math.max(doc.body.scrollHeight, doc.documentElement.scrollHeight);
    var height  = Math.max(cHeight, sHeight);
    return height;
}
window.onload = function() {
    var height = calcPageHeight(document);
    var container = parent.document.getElementById('summaryContainer');
    container.style.height = height + 'px';
    container.contentWindow.document.getElementsByClassName("header")[0].style.display = 'none'; 
    container.contentWindow.document.getElementsByClassName("main")[0].style.padding = "0";
}