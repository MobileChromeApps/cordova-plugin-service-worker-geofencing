var exec = require('cordova/exec');
var geofenceController = require('./GeofenceManager');

function GeofenceOptions(includePosition){
    if (includePosition === undefined) {
	this.includePosition = false;
    } else {
	this.includePosition = includePosition;
    }
}

module.exports = GeofenceOptions;
