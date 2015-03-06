function GeolocationPoint(lat, lon) {
    this.latitude = lat;
    this.longitude = lon;
}

function GeofenceRegion(name) {
    this.name = name;
};

function CircularGeofenceRegion(name, lat, lon, radius) {
    GeofenceRegion.call(this, name);
    this.center = new GeolocationPoint(lat, lon);
    if (radius > 0) {
	this.radius = radius;
    } else {
	this.radius = 150;
    }
};

var constructor = function() {};
constructor.prototype = GeofenceRegion.prototype;
CircularGeofenceRegion.prototype = new constructor();
CircularGeofenceRegion.prototype.constructor = CircularGeofenceRegion;
