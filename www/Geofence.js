var exec = require('cordova/exec');
var geofenceController = require('./GeofenceManager');
var geofenceRegion = require('./GeofenceRegion');
var circularGeofenceRegion = require('./CircularGeofenceRegion');

function Geofence(id, name, lat, lon, radius) {
    this.id = id;
    if (lat !== undefined && lon !== undefined && radius !== undefined) {
	this.region = new CircularGeofenceRegion(name, lat, lon, radius);
    } else {
	this.region = new GeofenceRegion(name);
    }
}

Geofence.prototype.remove = function() {
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

module.exports = Geofence;
