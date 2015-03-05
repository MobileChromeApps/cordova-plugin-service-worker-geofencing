var exec = require('cordova/exec');
var geofenceController = require('./GeofenceController');

function GeofenceRegisterOptions(includePosition){
    if (includePosition == null) {
	this.includePosition = false;
    } else {
	this.includePosition = includePosition;
    }
};

module.exports = GeofenceRegisterOptions;
