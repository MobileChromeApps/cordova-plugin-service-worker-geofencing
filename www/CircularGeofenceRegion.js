var exec = require('cordova/exec');
var geofenceController = require('./GeofenceController');
var geofenceRegion = require('./GeofenceRegion');

function CircularGeofenceRegion(name, lat, lon, radius) {
    GeofenceRegion.call(this, name);
    this.latitude = lat;
    this.longitude = lon;
    this.radius = radius;
};

var constructor = function() {};
constructor.prototype = GeofenceRegion.prototype;
CircularGeofenceRegion.prototype = new constructor();
CircularGeofenceRegion.prototype.constructor = CircularGeofenceRegion;

module.exports = CircularGeofenceRegion;
