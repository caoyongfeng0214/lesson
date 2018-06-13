$(function(){
    $.ajax({  
        type : "GET",  
        url : LESSON_API + "/api/class/pkgs",   
        complete:function(response) {  
            var r = JSON.parse(response.responseText)
            $('.lesson-total').text(r.hits.total);
            var data = r.hits.hits;
            if(data) {
                for(var i = 0; i < data.length; i++) {
                    var item  = data[i]._source
                    parseMarkDown(item);
                     //年龄范围
                     if( item.agesMax == 0 && item.agesMin == 0 ){
                        item.ageMsg = R.suitable4all ;
                    }else{
                        item.ageMsg = item.agesMin + '-' + item.agesMax;
                    }
                    
                   //课程包列表
                   var str = '<div class="el-col el-col-12 el-col-xs-12 el-col-sm-12 el-col-md-8 el-col-lg-8 el-col-xl-8">'+
                   '<div class="item">'+
                   '    <a href="' + item.url + '" target="_blank" class="lesson-cover">'+
                   '        <div style="background-image: url(' + item.cover + ');"></div>'+
                   '    </a>'+
                   '    <a href="' + item.url + '" target="_blank" class="title">' + item.title + '</a>'+
                   '    <div class="time">' + R.include + ': <span>'+ item.lessonCount +'</span> ' + R.lessons + '</div>'+
                   '    <div class="ages">' + R.ages +': <span>'+ item.ageMsg +'</span></div>'+
                   '    <div class="skills">' + R.skills + ': <span>'+ item.skills +'</span></div>'+
                   ' </div> '
                    $('.el-row').append(str);
                }   
            }
        }  
    }); 
    mdToJson = function(md) {
        var result;
        try {
            result = jsyaml.safeLoad(md);
        } catch (e) {
            console.error(e);
        }
        return result || {};
    }
    var parseMarkDown = function(item) {
        var contentArr = item.content.split('```');
        var lessonData;
        for(var i = 0; i < contentArr.length; i++) {
            var contentVo = contentArr[i];
            if(contentVo.startWith('@LessonPackage')) {
                contentVo = contentVo.replace('@LessonPackage', '');
                lessonData = mdToJson(contentVo.trim());
                break;
            }
        }
        if(lessonData) {
            item.title = lessonData.lessonPackage.data.title;
            item.url = keepworkHost + item.url;
            item.cover = lessonData.lessonPackage.data.cover;
            item.skills = lessonData.lessonPackage.data.skills;
            item.agesMin = lessonData.lessonPackage.data.agesMin;
            item.agesMax = lessonData.lessonPackage.data.agesMax;
            item.cost = lessonData.lessonPackage.data.cost;
            item.lessonCount = lessonData.lessonPackage.data.lessonCount;
           
        }
    }
});