/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
var app = {
    // Application Constructor
    initialize: function() {
        this.bindEvents();
    },
    // Bind Event Listeners
    //
    // Bind any events that are required on startup. Common events are:
    // 'load', 'deviceready', 'offline', and 'online'.
    bindEvents: function() {
        document.addEventListener('deviceready', this.onDeviceReady, false);
    },
    // deviceready Event Handler
    //
    // The scope of 'this' is the event. In order to call the 'receivedEvent'
    // function, we must explicitly call 'app.receivedEvent(...);'
    onDeviceReady: function() {
        app.receivedEvent('deviceready');
	navigator.serviceWorker.ready.then(function(swreg){
	   console.log('Service Worker is Ready');
	    console.log(swreg);
	    var updateMessage = function(message) {
		document.getElementById("messageArea").value = message;
	    };
	    cordova.exec(updateMessage, null, "Geofencing", "setupTestResponse", []);
	    var createGeofenceAtCurrentLocation = function() {
		var success = function(loc) {
		    var region = new CircularGeofenceRegion(document.getElementById("nameArea").value, loc.latitude, loc.longitude, 50);
		    swreg.geofencing.register(region).then(function(reg) {
			document.getElementById("messageArea").value = "Created Geofence " + reg.region.name + " at:\nLatitude: " + loc.latitude + "\nLongitude: " + loc.longitude;
		    }, function(err) {
			console.log(err);
		    });
		};
		cordova.exec(success, null, "Geofencing", "getCurrentLocation", []);
	    };
	    document.getElementById("createGeofenceBtn").onclick = createGeofenceAtCurrentLocation;
	    var clearFences = function() {
		swreg.geofencing.getRegistrations().then(function(regs) {
		    regs.forEach(function(reg) {
			reg.unregister();
		    });
		    document.getElementById("messageArea").value = "Cleared Fences";
		}, function() {
		    document.getElementById("messageArea").value = "No Fences to Clear";
		});
	    };
	    document.getElementById("clearFencesBtn").onclick = clearFences;
	});
    },
    // Update DOM on a Received Event
    receivedEvent: function(id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

        console.log('Received Event: ' + id);
    }
};

app.initialize();
