$(function(){
    $.ajax({  
        type : "GET",  
        url : "./api/class/pkgs",   
        complete:function(response) {  
            var r = JSON.parse(response.responseText)
            $('.lesson-total').text(r.hits.total);
            var data = r.hits.hits;
            if(data) {
                for(var i = 0; i < data.length; i++) {
                    var item  = data[i]._source
                    parseMarkDown(item);
                    console.log( item )
                     //年龄范围
                     if( item.agesMax == 0 && item.agesMin == 0 ){
                        item.ageMsg = 'Suitable for all' ;
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
                   '    <div class="time">Include: <span>'+ item.lessonCount +'</span> lessons</div>'+
                   '    <div class="ages">Ages: <span>'+ item.ageMsg +'</span></div>'+
                   '    <div class="skills">Skills: <span>'+ item.skills +'</span></div>'+
                   ' </div> '
                    $('.el-row').append(str);
                }   
            }
        }  
    }); 
    var parseMarkDown = function(item) {
        var contentArr = item.content.split('```');
        var lessonData;
        for(var i = 0; i < contentArr.length; i++) {
            var contentVo = contentArr[i];
            if(contentVo.startWith('@LessonPackage')) {
                lessonData = contentVo;
                break;
            }
        }
        if(lessonData) {
            item.title = lessonData.split('title: ')[1].split('\n')[0].replaceAll("'","");
            item.url = keepworkHost + item.url;
            item.cover = lessonData.split('cover: ')[1].split('\n')[0];
            item.skills = lessonData.split('skills: ')[1].split('\n')[0].replaceAll("'","");
            item.agesMin = lessonData.split('agesMin: ')[1].split('\n')[0].replaceAll("'","");
            item.agesMax = lessonData.split('agesMax: ')[1].split('\n')[0].replaceAll("'","");
            item.cost = lessonData.split('cost: ')[1].split('\n')[0].replaceAll("'","");
            item.lessonCount = lessonData.split('lessonCount: ')[1].split('\n')[0].replaceAll("'","");
           
        }
    }
});