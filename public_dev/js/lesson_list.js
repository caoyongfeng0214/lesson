$(function(){
    var param = {
        index: "kw.lesson.test",
        type: "lesson"
    }
    $.ajax({  
        type : "POST",  
        url : "http://es.keepwork.com/api/v0/elasticsearch/search",  
        data : JSON.stringify(param),  
        contentType : "application/json",  
        dataType : "json",  
        complete:function(response) {  
            var r = JSON.parse(response.responseText)
            $('.lesson-total').text(r.hits.total);
            var data = r.hits.hits;
            if(data) {
                for(var i = 0; i < data.length; i++) {
                    var item  = data[i]._source
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
});