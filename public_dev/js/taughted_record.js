var taughtedChart = document.getElementById("taughtedChart").getContext('2d');
var chartRate = new Chart(taughtedChart, {
    type: 'bar',
    data: {
        labels: [],
        datasets: [{
            label: 'Accuracy Rate',
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

var studentChart = document.getElementById("studentChart").getContext('2d');
var chartStudent = new Chart(studentChart, {
    type: 'bar',
    data: {
        labels: ["<60%", "60%-80%", ">80%"],
        datasets: [{
            label: 'Number of Students (total: 0)',
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
});

// TODO: 前端排序

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
            var tblRecord = $('.record-tbl');
            if(r.summary instanceof Array) {
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
                        '        <a href="/taughtedRecord/details/' + item.recordSn + '/' + item.studentNo + '" class="el-button el-button--primary el-button--mini">View Details</a>'+
                        '    </td>'+
                        '</tr>');
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
                chartStudent.data.datasets[0].label = 'Number of Students (total: ' + r.summary.length + ')'
                chartRate.update();
                chartStudent.update();
            }
        }
    });
}