var exec = require('cordova/exec');
var serviceWorker = require('org.apache.cordova.serviceworker.ServiceWorker');

GeofenceController = function() {
    return this;
};

GeofenceController.prototype.register = function(region) {
    return new Promise(function(resolve, reject) {
	var success = function(id) {
	    resolve(new GeofenceRegistration(id, region.name, region.latitude, region.longitude, region.radius));
	};
	var failure = function(err) {
	    if (err === "PermissionDeniedError") {
		throw DOMException;
	    }
	    reject(err);
	};
	exec(success, failure, "Geofencing", "registerRegion", [region]);
    });
};

GeofenceController.prototype.getRegistrations = function(options) {

};

GeofenceController.prototype.getRegistration = function(id) {
    return new Promise(function(resolve, reject) {
	var success = function(registration) {
	    resolve(registration);
	};
	var failure = function(err) {
	    reject(err);
	};
	exec(success,failure, "Geofencing", "getRegistration", [id]);
    });
};

navigator.serviceWorker.ready.then(function(serviceWorkerRegistration) {
    serviceWorkerRegistration.geofencing = new GeofenceController();
    exec(null, null, "Geofencing", "setupLocationManager", []);
});

module.exports = GeofenceController;
