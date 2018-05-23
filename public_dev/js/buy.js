
$(function() {
    var type = 1; // 默认购买 12 个月的 type = 1; 购买 6 个月的 type = 0
    $(".purchasing-type .type-item").on('click', function() {
        $(this).addClass("current").siblings().removeClass("current");
        type = $(this).attr('type');
    });

    $('#btnPay').on('click', function() {
        // 生成订单信息
        location = '/buy/order/' + type;
    });
})