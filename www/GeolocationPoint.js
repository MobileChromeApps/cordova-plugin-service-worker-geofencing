var exec = require('cordova/exec');
var geofenceController = require('./GeofenceManager');

function GeolocationPoint(lat, lon) {
    if (lat > 90 || lat < -90 || lon > 180 || lon < -180) {
	throw new RangeError("Latitude must be between -90 and 90 inclusive; Longitude must be between -180 and 180 inclusive.");
    }
    this.latitude = lat;
    this.longitude = lon;
}

module.exports = GeolocationPoint;
