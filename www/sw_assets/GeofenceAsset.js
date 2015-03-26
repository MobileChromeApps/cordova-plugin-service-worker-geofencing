function Geofence(id, name, lat, lon, radius) {
    this.id = id;
    if (lat !== undefined  && lon !== undefined && radius !== undefined) {
	this.region = new CircularGeofenceRegion(name, lat, lon, radius);
    } else {
	this.region = new GeofenceRegion(name);
    }
}

Geofence.prototype.unregister = function() {
    unregisterGeofence(this.id);
};

