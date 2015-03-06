Object.defineProperty(this, 'ongeofenceenter', {
    configurable: false,
    enumerable: true,
    get: eventGetter('geofenceenter'),
    set: eventSetter('geofenceenter')
});

Object.defineProperty(this, 'ongeofenceleave', {
    configurable: false,
    enumerable: true,
    get: eventGetter('geofenceleave'),
    set: eventSetter('geofenceleave')
});

Object.defineProperty(this, 'ongeofenceerror', {
    configurable: false,
    enumerable: true,
    get: eventGetter('geofenceerror'),
    set: eventSetter('geofenceerror')
});

GeofenceEnterEvent = function() {
    return this;
};

GeofenceLeaveEvent = function() {
    return this;
};

GeofenceErrorEvent = function() {
    return this;
};

GeofenceEnterEvent.prototype = new ExtendableEvent('geofenceenter');
GeofenceLeaveEvent.prototype = new ExtendableEvent('geofenceleave');
GeofenceErrorEvent.prototype = new ExtendableEvent('geofenceerror');

FireGeofenceEnterEvent = function(data) {
    var ev = new GeofenceEnterEvent();
    ev.registration = new GeofenceRegistration(data.id, data.name, data.latitude, data.longitude, data.radius);
    ev.position = data.position;
    dispatchEvent(ev);
    if(ev.promises instanceof Array) {
	// TODO something
    } else {
	// TODO something
    }
};

FireGeofenceLeaveEvent = function(data) {
    var ev = new GeofenceLeaveEvent();
    ev.registration = new GeofenceRegistration(data.id, data.name, data.latitude, data.longitude, data.radius);
    ev.position = data.position;
    dispatchEvent(ev);
    if(ev.promises instanceof Array) {
	// TODO something
    } else {
	// TODO something
    }
};

FireGeofenceErrorEvent = function(data) {
    var ev = new GeofenceErrorEvent();
    dispatchEvent(ev);
    if(ev.promises instanceof Array) {
	// TODO something
    } else {
	// TODO something
    }
};
