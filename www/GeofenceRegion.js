var exec = require('cordova/exec');
var geofenceController = require('./GeofenceManager');

function GeofenceRegion(name) {
    this.name = name;
}

module.exports = GeofenceRegion;
