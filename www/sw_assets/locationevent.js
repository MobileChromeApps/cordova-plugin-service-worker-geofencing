Object.defineProperty(this, 'onlocation', {
    configurable: false,
    enumerable: true,
    get: eventGetter('location'),
    set: eventSetter('location')
});

LocationEvent = function() {
    return this;
};

LocationEvent.prototype = new ExtendableEvent('location');

FireLocationEvent = function() {
    var ev = new LocationEvent();
    dispatchEvent(ev);
    if(ev.promises instanceof Array) {
	// TODO something
    } else {
	// TODO something
    }
};

