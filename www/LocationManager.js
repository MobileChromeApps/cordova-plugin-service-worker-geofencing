var exec = require('cordova/exec');
var serviceWorker = require('org.apache.cordova.serviceworker.ServiceWorker');

LocationManager = function() {
    return this;
};

LocationManager.prototype.monitorRegion = function(region) {
    exec(null, null, "Geofencing", "registerRegion", [region]);
};

navigator.serviceWorker.ready.then(function(serviceWorkerRegistration) {
    serviceWorkerRegistration.locationManager = new LocationManager();
    exec(null, null, "Geofencing", "setupLocationManager", []);
});

module.exports = LocationManager;
