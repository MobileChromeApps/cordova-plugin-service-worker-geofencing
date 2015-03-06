var exec = require('cordova/exec');
var geofenceController = require('./GeofenceController');
var geofenceRegion = require('./GeofenceRegion');
var geofencePoint = require('./GeolocationPoint');

function CircularGeofenceRegion(name, lat, lon, radius) {
    GeofenceRegion.call(this, name);
    this.center = new GeolocationPoint(lat, lon);
    if (radius > 0) {
	this.radius = radius;
    } else {
	this.radius = 150;
    }
};

var constructor = function() {};
constructor.prototype = GeofenceRegion.prototype;
CircularGeofenceRegion.prototype = new constructor();
CircularGeofenceRegion.prototype.constructor = CircularGeofenceRegion;

module.exports = CircularGeofenceRegion;
