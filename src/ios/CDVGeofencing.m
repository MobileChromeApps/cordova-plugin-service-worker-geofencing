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
#import <JavaScriptCore/JavaScriptCore.h>

NSString * const REGION_NAME_LIST_STORAGE_KEY = @"CDVGeofencing_REGION_NAME_LIST_STORAGE_KEY";

@implementation CDVGeofencing

@synthesize regionNameList;
@synthesize serviceWorker;
@synthesize locationManager;

- (void)setupLocationManager:(CDVInvokedUrlCommand*)command
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest; //TODO: Allow plugin user to set desired accuracy through javasript
    locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    self.serviceWorker = [(CDVViewController*)self.viewController getCommandInstance:@"ServiceWorker"];
    [self restoreRegionNameList];
    [self setupUnregister];
}

- (void)restoreRegionNameList
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *restored = [[defaults objectForKey:REGION_NAME_LIST_STORAGE_KEY] mutableCopy];
    if (restored != nil) {
        regionNameList = restored;
    }
}

- (void)setupUnregister
{
    //create weak reference to self in order to prevent retain cycle in block
    __weak CDVGeofencing* weakSelf = self;
    
    // Set up service worker unregister event
    serviceWorker.context[@"unregisterGeofence"] = ^(JSValue *regionId) {
        [weakSelf unregisterRegionById:[regionId toString]];
    };
}

- (BOOL)unregisterRegionById:(NSString *)identifier
{
    BOOL didRemove = NO;
    CLRegion *region;
    for (region in [self.locationManager monitoredRegions]) {
        if ([region.identifier isEqualToString:identifier]) {
            [self.locationManager stopMonitoringForRegion:region];
            [self.regionNameList removeObjectForKey:identifier];

            // Save the region name list for when the app is quit
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:regionNameList forKey:REGION_NAME_LIST_STORAGE_KEY];
            [defaults synchronize];

            NSLog(@"Unregistering Geofence %@", identifier);
            didRemove = YES;
        }
    }
    return didRemove;
}

- (void)unregister:(CDVInvokedUrlCommand*)command
{
    if ([self unregisterRegionById:[command argumentAtIndex:0]]) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    } else {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

- (void)registerRegion:(CDVInvokedUrlCommand*)command
{
    if ([CLLocationManager locationServicesEnabled]) {
        if([CLLocationManager regionMonitoringAvailable])
        {
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
                NSString *id = [self uuid];
                NSDictionary *region = [command argumentAtIndex:0];
                CLLocationCoordinate2D location;
                location.latitude = [[region valueForKey:@"latitude"] doubleValue];
                location.longitude = [[region valueForKey:@"longitude"] doubleValue];
                [self.locationManager startMonitoringForRegion:[[CLRegion alloc] initCircularRegionWithCenter:location radius:[[region valueForKey:@"radius"] doubleValue] identifier:id]];
                
                // Store a map of id's to names
                if (self.regionNameList == nil) {
                    self.regionNameList = [NSMutableDictionary dictionaryWithObject:[region valueForKey:@"name"] forKey:id];
                } else {
                    [self.regionNameList setObject:[region valueForKey:@"name"] forKey:id];
                }

                // Save the region name list for when the app is quit
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:regionNameList forKey:REGION_NAME_LIST_STORAGE_KEY];
                [defaults synchronize];

                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:id];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            } else {
                NSLog(@"PermissionDeniedError");
                //TODO: Send display an alert requesting user to change settings
            }
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

- (void)getRegistration:(CDVInvokedUrlCommand*)command
{
    NSString *id = [command argumentAtIndex:0];
    CLCircularRegion *region;
    NSDictionary *response, *geofencingRegion;
    for (region in [self.locationManager monitoredRegions]) {
        if ([region.identifier isEqualToString:id]) {
            geofencingRegion = @{ @"name"       : [regionNameList objectForKey:region.identifier],
                                  @"latitude"   : [NSNumber numberWithDouble:region.center.latitude],
                                  @"longitude"  : [NSNumber numberWithDouble:region.center.longitude],
                                  @"radius"     : [NSNumber numberWithDouble:region.radius]
                                 };
            response = @{ @"id"     : region.identifier,
                          @"region" : geofencingRegion
                         };
        }
    }
    if (response == nil) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"NotFoundError"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    } else {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:response];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

- (void)getRegistrations:(CDVInvokedUrlCommand*)command
{
    NSString *name = [command argumentAtIndex:0];
    NSMutableArray *response = [[NSMutableArray alloc] init];
    NSDictionary *geofencingRegion;
    NSDictionary *registration;
    CLCircularRegion *region;
    for (region in [self.locationManager monitoredRegions]) {
        if ([name isEqualToString:[regionNameList objectForKey:region.identifier]] || name == nil) {
            geofencingRegion = @{ @"name"       : [regionNameList objectForKey:region.identifier],
                                  @"latitude"   : [NSNumber numberWithDouble:region.center.latitude],
                                  @"longitude"  : [NSNumber numberWithDouble:region.center.longitude],
                                  @"radius"     : [NSNumber numberWithDouble:region.radius]
                                  };
            registration = @{ @"id"     : region.identifier,
                              @"region" : geofencingRegion
                          };
            [response addObject:registration];
        }
    }
    if ([response count] == 0) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"NotFoundError"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    } else {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:response];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"Started monitoring for %@", region.identifier);
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error: %@ %@", error, [error userInfo]);
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"Entered region %@", region.identifier);
    NSError *error;
    NSDictionary *dictionary = @{ @"id"         : region.identifier,
                                  @"name"       : [regionNameList objectForKey:region.identifier],
                                  @"latitude"   : [NSNumber numberWithDouble:region.center.latitude],
                                  @"longitude"  : [NSNumber numberWithDouble:region.center.longitude],
                                  @"radius"   : [NSNumber numberWithDouble:region.radius]
                                 };
    NSData *json = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    NSString *dispatchCode = [NSString stringWithFormat:@"FireGeofenceEnterEvent(JSON.parse('%@'));", [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding]];
    [serviceWorker.context evaluateScript:dispatchCode];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"Exited region %@",region.identifier);
    NSError *error;
    NSDictionary *dictionary = @{ @"id"         : region.identifier,
                                  @"name"       : [regionNameList objectForKey:region.identifier],
                                  @"latitude"   : [NSNumber numberWithDouble:region.center.latitude],
                                  @"longitude"  : [NSNumber numberWithDouble:region.center.longitude],
                                  @"radius"   : [NSNumber numberWithDouble:region.radius]
                                  };
    NSData *json = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    NSString *dispatchCode = [NSString stringWithFormat:@"FireGeofenceLeaveEvent(JSON.parse('%@'));", [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding]];
    [serviceWorker.context evaluateScript:dispatchCode];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"Authorization status has changed!");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

}

//Helper function for generating unique ID's for the regions
- (NSString *)uuid
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return (__bridge_transfer NSString *)uuidString;
}

- (void)getCurrentLocation:(CDVInvokedUrlCommand*)command
{
    CLLocation *currentLocation = [self.locationManager location];
    NSDictionary *response = @{ @"latitude"    : [NSNumber numberWithDouble:currentLocation.coordinate.latitude],
                                @"longitude"   : [NSNumber numberWithDouble:currentLocation.coordinate.longitude]
                                };
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:response];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

// For Testing purposes
NSString *callback;

- (void)setupTestResponse:(CDVInvokedUrlCommand*)command
{
    callback = command.callbackId;

    //create weak reference to self in order to prevent retain cycle in block
    __weak CDVGeofencing* weakSelf = self;

    // Set up service worker unregister event
    serviceWorker.context[@"respondToTest"] = ^(JSValue *message) {
        NSString *response = [message toString];
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:response];
        [result setKeepCallback:[NSNumber numberWithBool:YES]];
        [weakSelf.commandDelegate sendPluginResult:result callbackId:callback];
    };

    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [result setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:result callbackId:callback];
}

@end