Date.prototype.setISO8601 = function (string) {
    var regexp = "([0-9]{4})(-([0-9]{2})(-([0-9]{2})" +
    "(T([0-9]{2}):([0-9]{2})(:([0-9]{2})(\.([0-9]+))?)?" +
    "(Z|(([-+])([0-9]{2}):([0-9]{2})))?)?)?)?";
    var d = string.match(new RegExp(regexp));

    var offset = 0;
    var date = new Date(d[1], 0, 1);

    if (d[3]) { date.setMonth(d[3] - 1); }
    if (d[5]) { date.setDate(d[5]); }
    if (d[7]) { date.setHours(d[7]); }
    if (d[8]) { date.setMinutes(d[8]); }
    if (d[10]) { date.setSeconds(d[10]); }
    if (d[12]) { date.setMilliseconds(Number("0." + d[12]) * 1000); }
    if (d[14]) {
	offset = (Number(d[16]) * 60) + Number(d[17]);
	offset *= ((d[15] == '-') ? 1 : -1);
    }

    offset -= date.getTimezoneOffset();
    time = (Number(date) + (offset * 60 * 1000));
    this.setTime(Number(time));
}

Date.prototype.now = function() { return new Date; }
Date.prototype.n_hours_ago = function(n) {
    return new Date((new Date).getTime() - n*60*60*1000);
}
Date.prototype.one_hour_ago = function() { return this.n_hours_ago(1); }
Date.prototype.n_days_ago = function(n) { return this.n_hours_ago(24*n); }
Date.prototype.one_day_ago = function() { return this.n_days_ago(1); }

Date.prototype.midnight = function() {
    new Date(this.getFullYear(), 
             this.getMonth(), 
             this.getDate(), 0, 0, 0, 0); }
}
