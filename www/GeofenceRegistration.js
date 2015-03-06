var exec = require('cordova/exec');
var geofenceController = require('./GeofenceController');
var geofenceRegion = require('./GeofenceRegion');
var circularGeofenceRegion = require('./CircularGeofenceRegion');

function GeofenceRegistration(id, name, lat, lon, radius) {
    this.id = id;
    if (lat != null && lon != null && radius != null) {
	this.region = new CircularGeofenceRegion(name, lat, lon, radius);
    } else {
	this.region = new GeofenceRegion(name);
    }
};

GeofenceRegistration.prototype.unregister = function() {
    var scopeId = this.id;
    return new Promise(function(resolve, reject) {
	var success = function() {
	    resolve();
	};
	var failure = function(err) {
	    reject(err);
	};
	exec(success, failure, "Geofencing", "unregister", [scopeId]);
    });
};

module.exports = GeofenceRegistration;
