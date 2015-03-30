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

var exec = require('cordova/exec');
var serviceWorker = require('org.apache.cordova.serviceworker.ServiceWorker');

function GeofenceManager() {}

GeofenceManager.prototype.add = function(region, options) {
    return new Promise(function(resolve, reject) {
	var success = function(id) {
	    resolve(new Geofence(id, region.name, region.center.latitude, region.center.longitude, region.radius));
	};
	var failure = function(err) {
	    if (err === "PermissionDeniedError") {
		throw DOMException;
	    }
	    reject(err);
	};
	exec(success, failure, "Geofencing", "registerRegion", [region]);
    });
};

GeofenceManager.prototype.getAll = function(options) {
    return new Promise(function(resolve, reject) {
	var success = function(regs) {
	    regs.forEach(function(reg) {
		reg.remove = Geofence.prototype.remove;
	    });
	    resolve(regs);
	};
	if (options !== undefined && options.name !== null) {
	    exec(success, reject, "Geofencing", "getRegistrations", [options.name]);
	} else {
	    exec(success, reject, "Geofencing", "getRegistrations", []);
	}
    });
};

GeofenceManager.prototype.getById = function(id) {
    return new Promise(function(resolve, reject) {
	var success = function(registration) {
	    resolve(registration);
	};
	exec(success, reject, "Geofencing", "getRegistration", [id]);
    });
};

navigator.serviceWorker.ready.then(function(serviceWorkerRegistration) {
    serviceWorkerRegistration.geofencing = new GeofenceManager();
    exec(null, null, "Geofencing", "setupLocationManager", []);
});

module.exports = GeofenceManager;
