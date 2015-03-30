/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

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

function GeofenceEnterEvent() {}
function GeofenceLeaveEvent() {}
function GeofenceErrorEvent() {}

GeofenceEnterEvent.prototype = new ExtendableEvent('geofenceenter');
GeofenceLeaveEvent.prototype = new ExtendableEvent('geofenceleave');
GeofenceErrorEvent.prototype = new ExtendableEvent('geofenceerror');

FireGeofenceEnterEvent = function(data) {
    var ev = new GeofenceEnterEvent();
    ev.geofence = new Geofence(data.id, data.name, data.latitude, data.longitude, data.radius);
    ev.position = data.position;
    dispatchEvent(ev);
    if (ev.promises instanceof Array) {
	// TODO something
    } else {
	// TODO something
    }
};

FireGeofenceLeaveEvent = function(data) {
    var ev = new GeofenceLeaveEvent();
    ev.geofence = new Geofence(data.id, data.name, data.latitude, data.longitude, data.radius);
    ev.position = data.position;
    dispatchEvent(ev);
    if (ev.promises instanceof Array) {
	// TODO something
    } else {
	// TODO something
    }
};

FireGeofenceErrorEvent = function(data) {
    var ev = new GeofenceErrorEvent();
    dispatchEvent(ev);
    if (ev.promises instanceof Array) {
	// TODO something
    } else {
	// TODO something
    }
};
