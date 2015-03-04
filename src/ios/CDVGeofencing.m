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

#import <Cordova/CDV.h>
#import "CDVGeofencing.h"

@implementation CDVGeofencing

-(void)setupLocationManager:(CDVInvokedUrlCommand*)command
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest; //TODO: Allow plugin user to set desired accuracy through javasript
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
}

-(void)registerRegion:(CDVInvokedUrlCommand*)command
{
    if ([CLLocationManager locationServicesEnabled]) {
        if([CLLocationManager regionMonitoringAvailable])
        {
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
                NSLog(@"Authorized");
            }
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
                NSLog(@"Denied");
            }
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
                NSLog(@"Undetermined Auth Status");
            }
            NSDictionary *region = [command argumentAtIndex:0];
            CLLocationCoordinate2D location;
            location.latitude = [[region valueForKey:@"latitude"] doubleValue];
            location.longitude = [[region valueForKey:@"longitude"] doubleValue];
            [self.locationManager startMonitoringForRegion:[[CLRegion alloc] initCircularRegionWithCenter:location radius:[[region valueForKey:@"radius"] doubleValue] identifier:[region valueForKey:@"id"]]];
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        } else {
            NSLog(@"Region monitoring is unavailable");
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"This device does not support region monitoring."];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }
    } else {
        NSLog(@"Location services are not enabled");
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Location Services are not enabled for this app."];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"Started monitoring for %@", region.identifier);
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"Entered region %@", region.identifier);
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"Exited region %@",region.identifier);
}

@end