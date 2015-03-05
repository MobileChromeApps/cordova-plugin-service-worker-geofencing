self.ongeofenceenter = function(event) {
    respondToTest("Entered Region with Name: " + event.registration.region.name);
};

self.ongeofenceleave = function(event) {
    respondToTest("Exited Region with Name: " + event.registration.region.name);
};
