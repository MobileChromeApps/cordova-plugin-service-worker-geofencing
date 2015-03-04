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

FireGeofenceEnterEvent = function() {
    var ev = new GeofenceEnterEvent();
    dispatchEvent(ev);
    if(ev.promises instanceof Array) {
	// TODO something
    } else {
	// TODO something
    }
};

FireGeofenceLeaveEvent = function() {
    var ev = new GeofenceLeaveEvent();
    dispatchEvent(ev);
    if(ev.promises instanceof Array) {
	// TODO something
    } else {
	// TODO something
    }
};

FireGeofenceErrorEvent = function() {
    var ev = new GeofenceErrorEvent();
    dispatchEvent(ev);
    if(ev.promises instanceof Array) {
	// TODO something
    } else {
	// TODO something
    }
};
