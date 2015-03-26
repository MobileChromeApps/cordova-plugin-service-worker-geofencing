var exec = require('cordova/exec');
var geofenceController = require('./GeofenceManager');

function GeolocationPoint(lat, lon) {
    this.latitude = lat;
    this.longitude = lon;
}

module.exports = GeolocationPoint;
