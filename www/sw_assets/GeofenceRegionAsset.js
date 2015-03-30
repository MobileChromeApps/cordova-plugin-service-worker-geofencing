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

function GeolocationPoint(lat, lon) {
    this.latitude = lat;
    this.longitude = lon;
}

function GeofenceRegion(name) {
    this.name = name;
}

function CircularGeofenceRegion(name, lat, lon, radius) {
    GeofenceRegion.call(this, name);
    this.center = new GeolocationPoint(lat, lon);
    if (radius > 0) {
	this.radius = radius;
    } else {
	this.radius = 150;
    }
}

var constructor = function() {};
constructor.prototype = GeofenceRegion.prototype;
CircularGeofenceRegion.prototype = new constructor();
CircularGeofenceRegion.prototype.constructor = CircularGeofenceRegion;
