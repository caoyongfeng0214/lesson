$(function() {
    $(".purchasing-type .type-item").on('click', function() {
        $(this).addClass("current").siblings().removeClass("current");
    })
})