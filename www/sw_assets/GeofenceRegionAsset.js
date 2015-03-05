function GeofenceRegion(name) {
    this.name = name;
};

function CircularGeofenceRegion(name, lat, lon, radius) {
    GeofenceRegion.call(this, name);
    this.latitude = lat;
    this.longitude = lon;
    this.radius = radius;
};

var constructor = function() {};
constructor.prototype = GeofenceRegion.prototype;
CircularGeofenceRegion.prototype = new constructor();
CircularGeofenceRegion.prototype.constructor = CircularGeofenceRegion;
