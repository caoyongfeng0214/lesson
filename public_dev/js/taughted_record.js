var taughtedChart = c3.generate({
    bindto: '#taughtedChart',
    data: {
        types: {
            Rate: 'bar'
        },
        columns: [],
        colors: {
            Rate: '#49A5F8'
        }
    },
    axis: {
        x: {
            label: {
                text: 'Quizzes',
                position: 'outer-right'
            },
            type: 'category'
        },
        y: {
            label: {
                text: 'Accuracy Rate(%)',
                position: 'outer-top'
            }
        }
    },
    grid: {
        y: {
            show: true
        }
    }
});

var studentChart = c3.generate({
    bindto: '#studentChart',
    data: {
        types: {
            Number: 'bar'
        },
        columns: [],
        colors: {
            Number: '#49A5F8'
        }
    },
    axis: {
        x: {
            label: {
                text: 'Accuracy Rate(%)',
                position: 'outer-right'
            },
            type: 'category',
            categories: ["<60%", "60%-80%", ">80%"]
        },
        y: {
            label: {
                text: 'Number of Students (total: 0)',
                position: 'outer-top'
            },
            tick: {
                format: function(d) {
                    return d%1 == 0? d : '';
                }
            }
        }
    },
    grid: {
        y: {
            show: true
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
        $("#emailInput").val("");
        $(".el-message-box__wrapper , .v-modal").show();      
    });

    $(".sendMessage").on('click', function () {
        var style = '<style>.displayFlex{display:flex;display:-webkit-flex;display:-moz-flex;display:-ms-flex;display:-o-flex}.notselect{user-select:none;-webkit-user-select:none;-moz-user-select:none;-ms-user-select:none;-o-user-select:none}.recordWrapper{max-width:1200px;height:auto;margin:0 auto;background-color:#fff}.my-record{padding:45px 10px 45px 8%}.my-record .user-info{display:flex;display:-webkit-flex;display:-moz-flex;display:-ms-flex;display:-o-flex;align-items:center;-webkit-align-items:center;-moz-align-items:center;-ms-align-items:center;-o-align-items:center}.my-record .portrait{border-radius:50%;-webkit-border-radius:50%;-moz-border-radius:50%;-ms-border-radius:50%;-o-border-radius:50%;width:60px;height:60px;object-fit:cover;-o-object-fit:cover}.my-record .portrait+strong{margin-left:15px;color:#333;font-size:20px}.my-record .info{margin:30px 0 90px;color:#333;font-size:16px}.my-record .info em{color:#49A5F8}.my-record .el-button{padding:17px 19px;font-size:16px;margin-left:-45px}.record-list .tab-nav{padding:40px 10px 0 15%;border-bottom:1px solid#E5E5E5}.record-list .tab-nav>a{display:inline-block;padding-bottom:15px;margin:0 5%;font-size:22px;color:#333}.record-list .tab-nav>a.current{color:#49A5F8;border-bottom:2px solid #49A5F8}.record-list .tab-nav>a:hover{color:#49A5F8}.record-list .tab-content{padding:30px 0}.record-list .tab-content .have-item{border:1px solid #E5E5E5;margin-bottom:20px}.record-list .tab-content .have-item .time{padding:8px 15px;color:#181818;font-size:18px;border-bottom:1px solid #E5E5E5}.record-list .tab-content .have-item .layout-box{display:flex;display:-webkit-flex;display:-moz-flex;display:-ms-flex;display:-o-flex;align-items:center;-webkit-align-items:center;-moz-align-items:center;-ms-align-items:center;-o-align-items:center;padding:15px 20px 15px 10px}.record-list .tab-content .have-item .layout-box .cover{width:250px;height:146px;margin-right:20px;background-repeat:no-repeat;background-position:center center;background-size:cover}.record-list .tab-content .have-item .layout-box .content{flex:1}.record-list .tab-content .have-item .layout-box .content .title{font-size:18px;color:#181818}.record-list .tab-content .have-item .layout-box .content .title:hover{color:#49A5F8}.record-list .tab-content .have-item .layout-box .content .goals{margin:12px 0;font-size:14px}.record-list .tab-content .have-item .layout-box .content .goals>span{color:#999}.record-list .tab-content .have-item .layout-box .content .goals>ul{padding-left:18px}.record-list .tab-content .have-item .layout-box .content .goals>ul li{margin-top:8px;color:#333}.record-list .tab-content .have-item .layout-box .content .foot{width:80%;display:flex;display:-webkit-flex;display:-moz-flex;display:-ms-flex;display:-o-flex;align-items:center;-webkit-align-items:center;-moz-align-items:center;-ms-align-items:center;-o-align-items:center;justify-content:space-between;-webkit-justify-content:space-between;-moz-justify-content:space-between;-ms-justify-content:space-between;-o-justify-content:space-between;color:#111}.record-list .tab-content .have-item .layout-box .content .foot span{margin-left:15px}.record-list .tab-content .have-item .layout-box .content .foot span em{color:#FF414A}.sort-btn{display:flex;display:-webkit-flex;display:-moz-flex;display:-ms-flex;display:-o-flex;padding:25px;font-size:16px;color:#333;cursor:pointer;user-select:none}.sort-btn .sort-icon{padding-right:5px}.sort-btn .sort-icon>i{display:block;line-height:8px;color:#CCC}.sort-btn .sort-icon>i.active{color:#49A5F8}.learned-record,.taughted-record{padding:45px 8%}.learned-record .item,.taughted-record .item{margin-bottom:40px;color:#111;font-size:16px;margin-right:3%}.learned-record .item>div,.taughted-record .item>div{margin-top:12px}.learned-record .item>span,.taughted-record .item>span{color:#111;font-weight:700}.learned-record .item em,.taughted-record .item em{color:#FF414A}.learnedDetails{width:100%;padding:80px 70px 60px;box-shadow:5px 4px 20px rgba(64,158,254,.44);position:relative}.learnedDetails::after,.learnedDetails::before{content:"";position:absolute;top:18px;z-index:2;width:20px;height:20px;background:#eb5a49;box-shadow:8px 4px 2px rgba(235,63,43,.44);border-radius:50%;-webkit-border-radius:50%;-moz-border-radius:50%;-ms-border-radius:50%;-o-border-radius:50%}.learnedDetails::after{left:25px}.learnedDetails::before{right:25px}.learnedDetails ul{list-style:none}.learnedDetails ul li{font-size:16px;color:#111;margin:20px 0}.learnedDetails em{color:#FF414A}.table-wrap{width:100%;margin-top:40px;border:1px solid #BFBFBF;border-radius:8px;-webkit-border-radius:8px;-moz-border-radius:8px;-ms-border-radius:8px;-o-border-radius:8px}.table-wrap td{height:50px;padding:8px 10px;text-align:center;font-size:14px}.table-wrap thead td{border-right:1px solid #BFBFBF;border-bottom:2px solid #bfbfbf;font-size:16px}.table-wrap thead td:last-child{border-right:none}.table-wrap .sort-btn{padding:0;justify-content:center;align-items:center}.table-wrap .sort-btn .sort-icon{padding-left:5px}.table-wrap tbody tr:nth-child(even){background:rgba(64,158,254,.1)}.table-wrap .user-img{width:40px;height:40px;margin:0 auto;border-radius:50%;-webkit-border-radius:50%;-moz-border-radius:50%;-ms-border-radius:50%;-o-border-radius:50%;background-size:contain;background-repeat:no-repeat;background-position:center center}.draw-user{height:30px;overflow:hidden}.draw-user::after,.draw-user::before{content:"";display:block;width:14px;height:14px;margin:0 auto;border:2px solid #49A5F8;border-radius:50%;-webkit-border-radius:50%;-moz-border-radius:50%;-ms-border-radius:50%;-o-border-radius:50%}.draw-user::after{width:24px;height:24px}.icon-more{transform:rotate(90deg);-webkit-transform:rotate(90deg);-moz-transform:rotate(90deg);-ms-transform:rotate(90deg);-o-transform:rotate(90deg);font-size:24px}.taughted-record{padding:40px 5%}.taughted-record .record-operate{text-align:right;margin-right:3%}.taughted-record .record-container{margin-top:20px;padding:30px;background:rgba(121,176,255,.05)}.taughted-record .item ol{padding-left:18px}.taughted-record .item ol li{margin-top:8px;color:#333}.taughted-record .item .chartLayout{display:flex;display:-webkit-flex;display:-moz-flex;display:-ms-flex;display:-o-flex}.taughted-record .item .chartLayout>div{width:50%}.taughted-record .student-info{display:flex;display:-webkit-flex;display:-moz-flex;display:-ms-flex;display:-o-flex}.taughted-record .student-taughted-details .express>span{margin-right:10px;font-size:14px;color:#676767}.taughted-record .student-taughted-details .express .r::before,.taughted-record .student-taughted-details .express .w::before{content:"";width:12px;height:12px;display:inline-block;margin:0 15px;vertical-align:middle;border-radius:50%;-webkit-border-radius:50%;-moz-border-radius:50%;-ms-border-radius:50%;-o-border-radius:50%}.taughted-record .student-taughted-details .express .r::before{background-color:#27CE2F}.taughted-record .student-taughted-details .express .w::before{background-color:#F53838}.taughted-record .student-taughted-details .table-wrap{margin-top:15px}.taughted-record .student-taughted-details .table-wrap .right{color:#27CE2F}.taughted-record .student-taughted-details .table-wrap .wrong{color:#F53838}@media (max-width:992px){.taughted-record{padding:20px}.taughted-record .record-container{padding:25px}}@media (max-width:768px){.record-list .tab-content{padding:20px 0}.record-list .tab-content .have-item .layout-box .content .foot{width:100%}.sort-btn{padding:15px}.learned-record .item,.taughted-record .item{margin-bottom:25px}.learned-record .item>div,.taughted-record .item>div{margin-top:8px}.table-wrap{margin-top:25px}.table-wrap .sort-btn,.table-wrap thead td{font-size:14px}.table-wrap td{padding:8px}}' +
        '.c3 svg{font:10px sans-serif;-webkit-tap-highlight-color:transparent}.c3 line,.c3 path{fill:none;stroke:#000}.c3 text{-webkit-user-select:none;-moz-user-select:none;user-select:none}.c3-bars path,.c3-event-rect,.c3-legend-item-tile,.c3-xgrid-focus,.c3-ygrid{shape-rendering:crispEdges}.c3-chart-arc path{stroke:#fff}.c3-chart-arc rect{stroke:#fff;stroke-width:1}.c3-chart-arc text{fill:#fff;font-size:13px}.c3-grid line{stroke:#aaa}.c3-grid text{fill:#aaa}.c3-xgrid,.c3-ygrid{stroke-dasharray:3 3}.c3-text.c3-empty{fill:grey;font-size:2em}.c3-line{stroke-width:1px}.c3-circle._expanded_{stroke-width:1px;stroke:#fff}.c3-selected-circle{fill:#fff;stroke-width:2px}.c3-bar{stroke-width:0}.c3-bar._expanded_{fill-opacity:1;fill-opacity:.75}.c3-target.c3-focused{opacity:1}.c3-target.c3-focused path.c3-line,.c3-target.c3-focused path.c3-step{stroke-width:2px}.c3-target.c3-defocused{opacity:.3!important}.c3-region{fill:#4682b4;fill-opacity:.1}.c3-brush .extent{fill-opacity:.1}.c3-legend-item{font-size:12px}.c3-legend-item-hidden{opacity:.15}.c3-legend-background{opacity:.75;fill:#fff;stroke:#d3d3d3;stroke-width:1}.c3-title{font:14px sans-serif}.c3-tooltip-container{z-index:10}.c3-tooltip{border-collapse:collapse;border-spacing:0;background-color:#fff;empty-cells:show;-webkit-box-shadow:7px 7px 12px -9px #777;-moz-box-shadow:7px 7px 12px -9px #777;box-shadow:7px 7px 12px -9px #777;opacity:.9}.c3-tooltip tr{border:1px solid #ccc}.c3-tooltip th{background-color:#aaa;font-size:14px;padding:2px 5px;text-align:left;color:#fff}.c3-tooltip td{font-size:13px;padding:3px 6px;background-color:#fff;border-left:1px dotted #999}.c3-tooltip td>span{display:inline-block;width:10px;height:10px;margin-right:6px}.c3-tooltip td.value{text-align:right}.c3-area{stroke-width:0;opacity:.2}.c3-chart-arcs-title{dominant-baseline:middle;font-size:1.3em}.c3-chart-arcs .c3-chart-arcs-background{fill:#e0e0e0;stroke:#fff}.c3-chart-arcs .c3-chart-arcs-gauge-unit{fill:#000;font-size:16px}.c3-chart-arcs .c3-chart-arcs-gauge-max{fill:#777}.c3-chart-arcs .c3-chart-arcs-gauge-min{fill:#777}.c3-chart-arc .c3-gauge-value{fill:#000}.c3-chart-arc.c3-target g path{opacity:1}.c3-chart-arc.c3-target.c3-focused g path{opacity:1}'+
        '.noprint{display: none;}svg{height:600px;width:100%}</style>';

        $.post('/api/record/sendEmail', {
            email: $("#emailInput").val(),
            content: '<div class="recordWrapper taughted-record">' + $('.record-container').html() + '</div>' + style
        }, function(response) {
            $(".el-message-box__wrapper , .v-modal").fadeOut(500);
            console.log(response);
        })
    });

    $(".closeMessage").on('click', function() {
        $(".el-message-box__wrapper , .v-modal").fadeOut(500);    
    })

    $('#btnPrint').on('click', function() {
        if(lessonUrl) {
            $('.recordWrapper').append('<iframe id="keepworkContainer" frameborder="0" width="100%" src="' + keepworkHost + lessonUrl + '?device=print"></iframe>');
        }
        $('.print-show').show();

        $(".el-loading-mask").show();
        // prop a dialog
        var iframeTimer = setInterval(function(){
            console.log(new Date().getTime());
            if($('#keepworkContainer').attr('ready') == 'ready') {
                $(".el-loading-mask").hide();
                window.print();
                // dimiss a dialog
                $("iframe").remove("#keepworkContainer");
                clearInterval(iframeTimer);
            }
        }, 500);
    });
    // 全选、取消全选
    $('#cbxCheckAll').on('click', function() {
        var isChecked =$('#cbxCheckAll').prop('checked')
        $("input[class='cbx-item']").prop("checked", isChecked ); 
    });
    // 子项的选中
    $('.table-wrap').on('click', '.cbx-item', function() {
        var length = 0;
        $.each($('input[class="cbx-item"]:checked'),function(){
            length++;
        });
        isChecked = (length === snArr.length);
        $("#cbxCheckAll").prop("checked", isChecked ); 
    });
    // 改变全部
    $('#btnChangeAll').on('click', function() {
        console.log(snArr);
        cheatRecords(snArr);
    });

    // 改变选中
    $('#btnChange').on('click', function() {
        var selectedSn = [];
        $.each($('input[class="cbx-item"]:checked'),function(){
            selectedSn.push( parseInt( $(this).attr('data-sn') ) ) ;
        });
        console.log(selectedSn);
        cheatRecords(selectedSn);
    });   
});

var tblRecord = $('.record-tbl');
var summary = [];
var lessonUrl;
var snArr = [];
var getLessonTaughtedRecord = function(reload) {
    reload = (typeof reload !== 'undefined') ?  reload : true; // reload 缺省时为 true 
    $.get(LESSON_API + "/api/class/detail", {
        classId: classId
    }, function (response) {
        var r = response.data;
        if (response.err == 0) {
            if(reload) { // 重新加载数据，否则为追加数据
                tblRecord.html('');
            }
            lessonUrl = r.lessonUrl;
            $('.lesson-no').text(r.lessonNo);
            $('.lesson-title').text(r.lessonTitle);
            $('.lesson-time').text( fmtDate(r.startTime) );
            $('.lesson-goals').text(r.goals);
            $(".lecture-date").html("<strong> "+  fmtDate(r.startTime) + "</strong>");
            $(".teacher-nickname").text("Teacher: " + r.teacher + ".");
            $(".student-num").text(r.summary.length);
            if(r.summary instanceof Array) {
                summary = r.summary;
                var quizzLable = []; // quizz 图表的 Lable
                var quizzRight = []; // quizz 正确的人数
                var quizzRate = ['Rate']; // quizz 正确率
                var studentDiv = ['Number',0, 0, 0]; // 学生分布
                if(r.summary[0]) {
                    
                    for(var i = 0; i < r.summary[0].quizNum; i++) {
                        var label = 'Quiz' + (i + 1);
                        quizzLable.push(label);
                        quizzRight.push(0);
                        quizzRate.push(0);
                    }
                }
                for(var i = 0; i < r.summary.length; i++) {
                    var item = r.summary[i];
                    snArr.push(item.recordSn);
                    item.rightCount = parseInt(item.rightCount) || 0;
                    item.wrongCount = parseInt(item.wrongCount) || 0;
                    item.emptyCount = parseInt(item.emptyCount);
                    if(isNaN(item.emptyCount)) {
                        item.emptyCount = item.quizNum;
                    }
                    item.accuracyRate = item.rightCount/(item.rightCount + item.emptyCount + item.wrongCount); // 正确率
                    item.accuracyRate = item.accuracyRate ? Number(item.accuracyRate*100).toFixed(1) : 0;
                    if(item.cheatFlag === 1) {
                        item.wrongCount = 0;
                        item.emptyCount = 0;
                        item.rightCount = item.quizNum;
                        item.accuracyRate = 100;
                    }
                    appendRecord(item);
                    // 解析 item.answerSheet
                    if(item.accuracyRate < 60) {
                        studentDiv[1] += 1;// <60
                    } else if(item.accuracyRate >=60 && item.accuracyRate <= 80) {
                        studentDiv[2] += 1;// 60-80 
                    } else if(item.accuracyRate > 80) {
                        studentDiv[3] += 1;// >80
                    }
                    var sheet = item.answerSheet;

                    for(var m = 0; m < item.quizNum; m++) {
                        console.log(sheet)
                        if(sheet) {
                            var quizz = sheet[m];
                            if(quizz.trueFlag || item.cheatFlag === 1) {
                                quizzRight[m] += 1;
                            }
                        } else {
                            if(item.cheatFlag === 1) {
                                quizzRight[m] += 1;
                            }
                        }
                    }
                }
                if(r.summary[0]) {
                    for(var i = 0; i < r.summary[0].quizNum; i++) {
                        console.log(quizzRight)
                        quizzRate[i + 1] = quizzRight[i] / summary.length;
                        quizzRate[i + 1] =  quizzRate[i + 1] ? Number( quizzRate[i + 1]*100).toFixed(1) : 0;
                    }
                }
                taughtedChart.load({
                    columns: [quizzRate],
                    categories: quizzLable
                });
                studentChart.axis.labels({y: 'Number of Students (total: ' + r.summary.length + ')'});
                studentChart.load({
                    columns: [studentDiv]
                });
            }
        }
    });
}

var appendRecord = function(item) {
    tblRecord.append('<tr>'+
    '    <td class="noprint"><input type="checkbox" class="cbx-item" data-sn="'+ item.recordSn +'" ></td>'+
    '    <td class="noprint">'+
    '        <div class="user-img"><img src="' + item.portrait + '" /></div>'+
    '    </td>'+
    '    <td>' + item.username + '</td>'+
    '    <td>' + item.studentNo + '</td>'+
    '    <td>' + item.accuracyRate + '%</td>'+
    '    <td>' + item.rightCount + '</td>'+
    '    <td>' + item.wrongCount + '</td>'+
    '    <td>' + item.emptyCount + '</td>'+
    '    <td class="noprint">'+
    '        <a class="noprint" target="_blank" href="/taughtedRecord/details/' + item.recordSn + '/' + item.studentNo + '" class="el-button el-button--primary el-button--mini">View Details</a>'+
    '    </td>'+
    '</tr>');
}

var cheatRecords = function(arr) {
    var sn = arr.join(',');
    $.post("/api/record/cheat", {
        sn: sn
    }, function(response) {
        getLessonTaughtedRecord();
    })
}

// document.domain = 'localhost';
document.domain = '10.27.26.21'
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
//         container.style.height = height + 100 + 'px';
//         container.contentWindow.document.getElementsByClassName("header")[0].style.display = 'none'; 
//         container.contentWindow.document.getElementsByClassName("main")[0].style.padding = "0";
//         container.contentWindow.document.getElementsByClassName("recordWrapper")[0].style.width = '1080px';
//         container.contentWindow.document.getElementsByClassName("recordWrapper")[0].style.padding = "40px 2%";
//     }
// }
