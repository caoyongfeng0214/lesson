$(function(){
    $.ajax({  
        type : "GET",  
        url : "/api/class/lesson",   
        complete:function(response) {  
            var r = JSON.parse(response.responseText)
            console.log(r);
            $('.lesson-total').text(r.hits.total);
            var data = r.hits.hits;
            if(data) {
                for(var i = 0; i < data.length; i++) {
                    var item  = data[i]._source
                    parseMarkDown(item);
                    $('.el-row').append('<div class="el-col el-col-12 el-col-xs-12 el-col-sm-8 el-col-md-8 el-col-lg-6 el-col-xl-6">'+
                        '    <a href="' + item.lessonUrl + '" target="_blank" class="lesson-cover">'+
                        '        <div style="background-image: url(' + item.lessonCover + ');"></div>'+
                        '    </a>'+
                        '    <a href="' + item.lessonUrl + '" target="_blank" class="title">Lesson ' + item.lessonNo + ' ' + item.lessonTitle + '</a>'+
                        '    <div class="time">Duration: <span>45mins</span></div>'+
                        '    <div class="ages">Ages: <span>Suitable for all</span></div>'+
                        '</div>')
                }   
            }
        }  
    }); 
    var parseMarkDown = function(item) {
        var contentArr = item.content.split('```');
        var lessonData;
        for(var i = 0; i < contentArr.length; i++) {
            var contentVo = contentArr[i];
            if(contentVo.startWith('@Lesson')) {
                lessonData = contentVo;
                break;
            }
        }
        if(lessonData) {
            item.lessonTitle = lessonData.split('Title : ')[1].split('- ')[0];
            item.lessonUrl = keepworkHost + item.url;
            item.lessonCover = lessonData.split('CoverImageOfTheLesson : ')[1].split('- ')[0];
            item.lessonNo = lessonData.split('LessonNo : ')[1].split('- ')[0];
        }
    }
});