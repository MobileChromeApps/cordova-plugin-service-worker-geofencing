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
#import <JavaScriptCore/JavaScriptCore.h>
#include <objc/runtime.h>
#import <Cordova/CDVPlugin.h>
#import "CDVServiceWorker.h"
#import "CDVLocation.h"
#import <CoreLocation/CoreLocation.h>

static NSString * const REGION_NAME_LIST_STORAGE_KEY = @"CDVGeofencing_REGION_NAME_LIST_STORAGE_KEY";

@interface CDVGeofencing : CDVPlugin {}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableDictionary *regionNameList;
@property (nonatomic, strong) CDVServiceWorker *serviceWorker;
@property (nonatomic, strong) CDVLocation *geolocation;

@end

static CDVGeofencing *this;

@implementation CDVGeofencing

@synthesize regionNameList;
@synthesize serviceWorker;
@synthesize locationManager;
@synthesize geolocation;

- (void)setupLocationManager:(CDVInvokedUrlCommand*)command
{
    this = self;
    self.serviceWorker = [self.commandDelegate getCommandInstance:@"ServiceWorker"];
    self.geolocation = [self.commandDelegate getCommandInstance:@"Geolocation"];
    self.locationManager = geolocation.locationManager;

    [self restoreRegionNameList];
    [self setupUnregister];
    [self setupDelegateCallbacks];
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
    __weak CDVGeofencing* weakSelf = self;
    serviceWorker.context[@"CDVGeofencing_unregisterGeofence"] = ^(JSValue *regionId) {
        [weakSelf unregisterRegionById:[regionId toString]];
    };
}

- (void)setupDelegateCallbacks
{
    if([geolocation respondsToSelector:@selector(locationManager:didEnterRegion:)]) {
        Method original, swizzled;
        original = class_getInstanceMethod([self class], @selector(locationManager:didEnterRegion:));
        swizzled = class_getInstanceMethod([geolocation class], @selector(locationManager:didEnterRegion:));
        method_exchangeImplementations(original, swizzled);
    } else {
        class_addMethod([geolocation class], @selector(locationManager:didEnterRegion:), class_getMethodImplementation([self class], @selector(locationManager:didEnterRegion:)), nil);
    }
    if([geolocation respondsToSelector:@selector(locationManager:didExitRegion:)]) {
        Method original, swizzled;
        original = class_getInstanceMethod([self class], @selector(locationManager:didExitRegion:));
        swizzled = class_getInstanceMethod([geolocation class], @selector(locationManager:didExitRegion:));
        method_exchangeImplementations(original, swizzled);
    } else {
        class_addMethod([geolocation class], @selector(locationManager:didExitRegion:), class_getMethodImplementation([self class], @selector(locationManager:didExitRegion:)), nil);
    }
    if([geolocation respondsToSelector:@selector(locationManager:didStartMonitoringForRegion:)]) {
        Method original, swizzled;
        original = class_getInstanceMethod([self class], @selector(locationManager:didStartMonitoringForRegion:));
        swizzled = class_getInstanceMethod([geolocation class], @selector(locationManager:didStartMonitoringForRegion:));
        method_exchangeImplementations(original, swizzled);
    } else {
        class_addMethod([geolocation class], @selector(locationManager:didStartMonitoringForRegion:), class_getMethodImplementation([self class], @selector(locationManager:didStartMonitoringForRegion:)), nil);
    }
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
        if ([CLLocationManager regionMonitoringAvailable])
        {
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
                if ([regionNameList count] <= 20) {
                    NSString *id = [self uuid];
                    NSDictionary *region = [command argumentAtIndex:0];
                    CLLocationCoordinate2D location;
                    location.latitude = [region[@"center"][@"latitude"] doubleValue];
                    location.longitude = [region[@"center"][@"longitude"] doubleValue];
                    [self.locationManager startMonitoringForRegion:[[CLRegion alloc] initCircularRegionWithCenter:location radius:[region [@"radius"] doubleValue] identifier:id]];
                    if (self.regionNameList == nil) {
                        self.regionNameList = [NSMutableDictionary dictionaryWithObject:region[@"name"] forKey:id];
                    } else {
                        self.regionNameList[id] = region[@"name"];
                    }

                    // Save the region name list for when the app is quit
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:regionNameList forKey:REGION_NAME_LIST_STORAGE_KEY];
                    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:id];
                    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                } else {
                    NSLog(@"Registration Quota Exceeded");
                    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"QuotaExceededError"];
                    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

                }
            } else {
                NSLog(@"Not authorized to use location services");
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"PermissionDeniedError"];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
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
            geofencingRegion = @{ @"name"       : regionNameList[region.identifier],
                                  @"latitude"   : @(region.center.latitude),
                                  @"longitude"  : @(region.center.longitude),
                                  @"radius"     : @(region.radius)
                                 };
            response = @{ @"id"     : region.identifier,
                          @"region" : geofencingRegion
                         };
        }
    }
    if (response == nil) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    } else {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:response];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

- (void)getRegistrations:(CDVInvokedUrlCommand*)command
{
    NSMutableArray *response = [[NSMutableArray alloc] init];
    NSDictionary *geofencingRegion;
    NSDictionary *registration;
    CLCircularRegion *region;
    for (region in [self.locationManager monitoredRegions]) {
        geofencingRegion = @{ @"name"       : regionNameList[region.identifier],
                              @"latitude"   : @(region.center.latitude),
                              @"longitude"  : @(region.center.longitude),
                              @"radius"     : @(region.radius)
                              };
        registration = @{ @"id"     : region.identifier,
                          @"region" : geofencingRegion
                      };
        [response addObject:registration];
    }
    if ([response count] == 0) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:[NSArray array]];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    } else {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:response];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

- (NSData*)createEventDataWithRegion:(CLRegion*)region
{
    NSError *error;
    NSDictionary *position = [self getCurrentLocation];
    if (position == nil) {
        position = @{ @"latitude"   : @"Location services are unavailable",
                      @"longitude"  : @"Location services are unavailable"
                     };
    }
    NSDictionary *dictionary = @{ @"id"         : region.identifier,
                                  @"name"       : regionNameList[region.identifier],
                                  @"latitude"   : @(region.center.latitude),
                                  @"longitude"  : @(region.center.longitude),
                                  @"radius"     : @(region.radius),
                                  @"position"   : position
                                };
    return [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion*)region
{
    NSLog(@"Started monitoring for %@", region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion*)region
{
    NSLog(@"Entered region %@", region.identifier);
    NSData *json = [this createEventDataWithRegion:region];
    NSString *dispatchCode = [NSString stringWithFormat:@"FireGeofenceEnterEvent(%@);", [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding]];
    [this.serviceWorker.context evaluateScript:dispatchCode];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion*)region
{
    NSLog(@"Exited region %@",region.identifier);
    NSData *json = [this createEventDataWithRegion:region];
    NSString *dispatchCode = [NSString stringWithFormat:@"FireGeofenceLeaveEvent(%@);", [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding]];
    [this.serviceWorker.context evaluateScript:dispatchCode];
}

- (NSString *)uuid
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return (__bridge_transfer NSString *)uuidString;
}

- (void)getCurrentLocation:(CDVInvokedUrlCommand*)command
{
    if ([CLLocationManager locationServicesEnabled]) {
        CLLocation *currentLocation = [self.locationManager location];
        NSDictionary *response = @{ @"latitude"    : @(currentLocation.coordinate.latitude),
                                    @"longitude"   : @(currentLocation.coordinate.longitude)
                                    };
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:response];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    } else {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Location services are not currently enabled"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

- (NSDictionary*)getCurrentLocation
{
    if ([CLLocationManager locationServicesEnabled]) {
        CLLocation *currentLocation = [self.locationManager location];
        return @{ @"latitude"    : @(currentLocation.coordinate.latitude),
                  @"longitude"   : @(currentLocation.coordinate.longitude)
                };
    } else {
        return nil;
    }
}

// For Testing purposes
NSString *callback;

- (void)setupTestResponse:(CDVInvokedUrlCommand*)command
{
    callback = command.callbackId;
    __weak CDVGeofencing* weakSelf = self;
    serviceWorker.context[@"respondToTest"] = ^(JSValue *message) {
        NSString *response = [message toString];
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:response];
        [result setKeepCallback:@(YES)];
        [weakSelf.commandDelegate sendPluginResult:result callbackId:callback];
    };
}

@end
