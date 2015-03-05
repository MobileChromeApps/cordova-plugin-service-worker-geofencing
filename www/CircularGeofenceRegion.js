var exec = require('cordova/exec');
var geofenceController = require('./GeofenceController');
var geofenceRegion = require('./GeofenceRegion');
var geofencePoint = require('./GeolocationPoint');

function CircularGeofenceRegion(name, lat, lon, radius) {
    GeofenceRegion.call(this, name);
    this.center = new GeolocationPoint(lat, lon);
    this.radius = radius;
};

var constructor = function() {};
constructor.prototype = GeofenceRegion.prototype;
CircularGeofenceRegion.prototype = new constructor();
CircularGeofenceRegion.prototype.constructor = CircularGeofenceRegion;

module.exports = CircularGeofenceRegion;
