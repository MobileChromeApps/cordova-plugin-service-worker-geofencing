var exec = require('cordova/exec');
var geofenceController = require('./GeofenceManager');

function GeofenceQueryOptions(name) {
    this.name = name;
}

module.exports = GeofenceQueryOptions;
