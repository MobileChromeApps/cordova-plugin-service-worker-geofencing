var exec = require('cordova/exec');
var serviceWorker = require('org.apache.cordova.serviceworker.ServiceWorker');

GeofenceManager = function() {
    return this;
};

GeofenceManager.prototype.add = function(region, options) {
    return new Promise(function(resolve, reject) {
	var success = function(id) {
	    resolve(new Geofence(id, region.name, region.center.latitude, region.center.longitude, region.radius));
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

GeofenceManager.prototype.getAll = function(options) {
    return new Promise(function(resolve, reject) {
	var success = function(regs) {
	    regs.forEach(function(reg) {
		reg.remove = Geofence.prototype.remove;
	    });
	    resolve(regs);
	};
	var failure = function(err) {
	    reject(err);
	};
	if (options !== undefined && options.name !== null) {
	    exec(success, failure, "Geofencing", "getRegistrations", [options.name]);
	} else {
	    exec(success, failure, "Geofencing", "getRegistrations", []);
	}
    });
};

GeofenceManager.prototype.getById = function(id) {
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
    serviceWorkerRegistration.geofencing = new GeofenceManager();
    exec(null, null, "Geofencing", "setupLocationManager", []);
});

module.exports = GeofenceManager;
