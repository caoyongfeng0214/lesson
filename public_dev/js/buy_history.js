var username = $('#username').val(); // TODO:更换为 keepwork 当前登录用户

$(function() {
    // 获取订单历史数据
    getOrderHistory();
});

var getOrderHistory = function( psize, pno ) {
    $.get("/api/order/list", {
        psize: psize,
        pno: pno,
        username: username
    }, function (response) {
        var r = response.data;
        var p = response.page;
        if(response.err == 0) {
            var orderListView = $('.history-list');
            for(var i = 0; i < r.length; i++) {
                var item = r[i];
                if(item.vipDay >= 0) {
                    item.expired = '';
                } else {
                    item.expired = 'expired';
                }
                if(item.goodsType == 0) {
                    // 6 months
                    item.purchasingType = '***/6';
                } else if(item.goodsType == 1) {
                    // 12 months
                    item.purchasingType = '***/12';
                }
                item.endTime = fmtDate(item.endTime, 'dd, MM, yyyy');
                item.orderTime = fmtDate(item.orderTime, 'dd, MM, yyyy');
                orderListView.append('<ul class="history-item ' + item.expired + '">' +
                    '    <li class="el-row--flex">' +
                    '        <span>Purchasing Type:</span>' +
                    '        <div>USD ' + item.purchasingType + ' months</div>' +
                    '    </li>	' +
                    '    <li class="el-row--flex">' +
                    '        <span>Valid Until:</span>' +
                    '        <div>' + item.endTime + '</div>' +
                    '    </li>' +
                    '    <li class="el-row--flex">' +
                    '        <span>Purchasing Date:</span>' +
                    '        <div>' + item.orderTime + '</div>' +
                    '    </li>' +
                    '</ul>')
            }
        }
    });
}