var exec = require('cordova/exec');
var geofenceController = require('./GeofenceController');

function GeofenceRegion(name) {
    this.name = name;
};

module.exports = GeofenceRegion;
