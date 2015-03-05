var exec = require('cordova/exec');
var geofenceController = require('./GeofenceController');

function GeofenceRegistrationQueryOptions(name) {
    this.name = name;
};

module.exports = GeofenceRegistrationQueryOptions
