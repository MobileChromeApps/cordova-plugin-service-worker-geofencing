var exec = require('cordova/exec');
var LocationManager = require('./LocationManager');

function Region(_id, _lat, _lon, _radius) {
    this.id = _id;
    this.latitude = _lat;
    this.longitude = _lon;
    this.radius = _radius;
};

module.exports = Region;
