self.ongeofenceenter = function(event) {
    respondToTest("Entered Region with Name: " + event.geofence.region.name);
};

self.ongeofenceleave = function(event) {
    respondToTest("Exited Region with Name: " + event.geofence.region.name);
};
