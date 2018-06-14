// TODO: 切换为在 keepwork 上获取
var username = $('#username').val();
var PAGE_SIZE = 50;
$(function () {
    $.get(LESSON_API + "/api/member/statis", {
        username: username
    }, function (response) {
        var r = response.data
        if (r) {
            if(r.teached > 0 && r.learned > 0) {
                $('.tab-nav').show();
                // Get Have taught data
                getTaughtRecordList(PAGE_SIZE, 1)
            } else if(r.teached > 0 && r.learned == 0) {
                // Get Have taught data
                getTaughtRecordList(PAGE_SIZE, 1)
            } else if(r.teached == 0 && r.learned > 0) {
                // Get Have learn data
                getLearnRecordList(PAGE_SIZE, 1)
            } else {
                // No data

            }
        }
    });
    var taughtSortFlag = false,
        learnSortFlag = false;

    // 教学按照上课时间排序
    $('.have-taught').on('click', '.sort-btn', function () {
        if(taughtSortFlag) {
            // 倒序
            getTaughtRecordList(PAGE_SIZE, 1)
            $(this).find('.el-icon-caret-top').addClass('active').siblings().removeClass('active');
            taughtSortFlag = false;
        } else {
            // 正序
            getTaughtRecordList(PAGE_SIZE, 1, 'asc')
            $(this).find('.el-icon-caret-bottom').addClass('active').siblings().removeClass('active');
            taughtSortFlag = true
        }
    });

    // 学习按照 lesson No 排序
    $('.have-learn').on('click', '.sort-btn', function () {
        if(learnSortFlag) {
            // 倒序
            getLearnRecordList(PAGE_SIZE, 1)
            $(this).find('.el-icon-caret-top').addClass('active').siblings().removeClass('active');
            learnSortFlag = false;
        } else {
            // 正序
            getLearnRecordList(PAGE_SIZE, 1, 'asc')
            $(this).find('.el-icon-caret-bottom').addClass('active').siblings().removeClass('active');
            learnSortFlag = true
        }
    });

    // tab 教学记录
    $('#tab-have-taught').on('click', function () {
        $(this).addClass('current').siblings().removeClass('current');
        getTaughtRecordList(PAGE_SIZE, 1)
    });

    // tab 学习记录
    $('#tab-have-learn').on('click', function () {
        $(this).addClass('current').siblings().removeClass('current');
        getLearnRecordList(PAGE_SIZE, 1)
    })
});

// 获取教学记录
var getTaughtRecordList = function ( psize, pno, order, reload ) {
    reload = (typeof reload !== 'undefined') ?  reload : true; // reload 缺省时为 true 
    $(".have-taught").show();
    $(".have-learn").hide();
    $.get(LESSON_API + "/api/class/taught", {
        username: username,
        psize: psize,
        pno: pno,
        order: order
    }, function (response) {
        if(response.err == 0) {
            var haveTaughtList = $('.have-taught-list');
            if(reload) { // 重新加载数据，否则为追加数据
                haveTaughtList.html('');
            }
            for(var i = 0; i < response.data.length; i++) {
                var item = response.data[i];
                item.lessonCover = item.lessonCover.startsWith('http')?item.lessonCover:keepworkHost + item.lessonCover;
                haveTaughtList.append('<div class="have-item">' +
                '<div class="time">'+ new Date(item.startTime).format("hh:mm dd/MM/yyyy") +'</div>' +
                '<div class="layout-box">' +
                '    <a href="' + (keepworkHost + item.lessonUrl)+ '" target="_blank" class="title"><div class="cover" style="background-image: url('+ item.lessonCover +')"></div></a>' +
                '    <div class="content">' +
                '        <a href="' + (keepworkHost + item.lessonUrl)+ '" target="_blank" class="title">Lesson '+ item.lessonNo +'：'+ item.lessonTitle +'</a>' +
                '        <div class="goals">' +
                '            <span>Lesson Goals:</span>' +
                '            <ul>' +
                '                <li>'+ item.goals +'</li>' +
                '            </ul>' +
                '        </div>' +
                '        <div class="foot">' +
                '            <a href="/taughtedRecord/' + item.classId + '" class="el-button el-button--primary el-button--medium is-plain">View Summary</a>' +
                '        </div>' +
                '    </div>' +
                '</div>' +
                '</div>')
            }
        }
    })
}

// 获取学习记录
var getLearnRecordList = function ( psize, pno, order, reload ) {
    reload = (typeof reload !== 'undefined') ?  reload : true; // reload 缺省时为 true 
    $(".have-taught").hide();
    $(".have-learn").show();
    $.get(LESSON_API + "/api/record/learn", {
        username: username,
        psize: psize,
        pno: pno,
        order: order
    }, function (response) {
        if(response.err == 0) {
            var haveLearnList = $('.have-learn-list');
            if(reload) { // 重新加载数据，否则为追加数据
                haveLearnList.html('');
            }
            for(var i = 0; i < response.data.length; i++) {
                var item = response.data[i];
                item.lessonCover = item.lessonCover.startsWith('http')?item.lessonCover:keepworkHost + item.lessonCover;
                haveLearnList.append('<div class="have-item">' +
                '<div class="layout-box">' +
                '    <a href="' + (keepworkHost + item.lessonUrl)+ '" target="_blank" class="title"><div class="cover" style="background-image: url(' + item.lessonCover + ')"></div></a>' +
                '    <div class="content">' +
                '        <a href="' + (keepworkHost + item.lessonUrl)+ '" target="_blank" class="title">Lesson ' + item.lessonNo + '：' + item.lessonTitle + '</a>' +
                '        <div class="goals">' +
                '            <span>Lesson Goals:</span>' +
                '            <ul>' +
                '                <li>'+ item.goals +'</li>' +
                '            </ul> ' +   
                '        </div>' +
                '        <div class="foot">' +
                '            <a href="/learnedRecord/' + username + '/' + item.lessonNo + '" class="el-button el-button--primary el-button--medium is-plain">View Summary</a>' +
                '            <div class="scores-info">' +
                '                <span>Latest Scores: <em>' + (item.latestScore ? item.latestScore : 0) + '</em></span>' +
                '                <span>Best Scores: <em>' + (item.bestScore ? item.bestScore : 0) + '</em></span>' +
                '            </div>' +
                '        </div>' +
                '    </div>' +
                '</div>')
            }
        }
    })
}
