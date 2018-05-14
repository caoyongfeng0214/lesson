Date.prototype.format = function(fmt) {
    var o = {
        "M+": this.getMonth() + 1, //Month
        "d+": this.getDate(), //Day
        "h+": this.getHours(), //Hour
        "m+": this.getMinutes(), //Minute
        "s+": this.getSeconds(), //Second
        "q+": Math.floor((this.getMonth() + 3) / 3), //Season
        "S": this.getMilliseconds() //millesecond
    };
    if (/(y+)/.test(fmt)) fmt = fmt.replace(RegExp.$1, (this.getFullYear() + "").substr(4 - RegExp.$1.length));
    for (var k in o)
        if (new RegExp("(" + k + ")").test(fmt)) fmt = fmt.replace(RegExp.$1, (RegExp.$1.length == 1) ? (o[k]) : (("00" + o[k]).substr(("" + o[k]).length)));
    return fmt;
}

String.prototype.startWith = function(s) {
    if (s == null || s == "" || this.length == 0 || s.length > this.length)
        return false
    if (this.substr(0, s.length) == s)
        return true
    else
        return false
    return true
}

var keepworkHost = 'http://localhost:8080';

/**
 * number format english eg: 1 -> 1st 2 -> 2nd
 * @param number 
 */
var genEnNum = function( number ) {
    if( isNaN(number) ) {
        return '0'
    }
    var g = number % 10;
    var b = number % 100;
    if(number == 0) {
        return '0';
    } else if(b == 11 || b == 12 || b == 13) {
        return number + 'th';
    } else if(g == 1) {
        return number + 'st';
    } else if(g == 2) {
        return number + 'nd';
    } else if(g == 3) {
        return number + 'rd';
    } else {
        return number + 'th';
    }
}

/**
 * format date -> Friday 27th, April, 2018
 * @param dateStr 
 */
var fmtDate = function( dateStr , fmtStr ) {
    var weekArr = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    var monthArr = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    var d = new Date(dateStr);
    var week = weekArr[ d.getDay() ];
    var day = genEnNum( d.getDate() );
    var month = monthArr[ d.getMonth() ];
    var year = d.getFullYear();
    if(fmtStr && fmtStr == 'dd, MM, yyyy') {
        return day + ', ' + month + ', ' + year;
    }
    return week + ' ' + day + ', ' + month + ', ' + year;
}