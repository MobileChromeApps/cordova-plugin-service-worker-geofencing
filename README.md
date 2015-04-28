#Geofencing Plugin for Cordova Service Worker
The cordova geofencing plugin enables developers to set up set up region monitoring and handle boundary crossing events with a service worker. Regions persist even when the app is quit and are monitored even when your app is in the background.

##Supported Platforms
This plugin is currently supported on iOS only.

##Installation
To add the plugin to your project, use this cli command from within your project
```
cordova plugin add https://github.com/MobileChromeApps/cordova-plugin-geofencing.git
```

or, to install from npm:
```
cordova plugin add cordova-plugin-geofencing
```

To remove the plugin use
```
cordova plugin rm cordova-plugin-geofencing
```
##Example Usage
On your active page:
```javascript
navigator.serviceWorker.ready.then(function(serviceWorkerRegistration) {
  var region = new CircularGeofenceRegion("Name", latitude, longitude, radius);
  serviceWorkerRegistration.geofencing.add(region).then(function(regionRegistration) {
    console.log("Created Geofence " + regionRegistration);
  }, function(error) {
    console.log("Error: " + error);
  });
});
```
In your service worker script:
```javascript
self.ongeofenceenter = function(event) {
  console.log("Entered Region with Name: " + event.geofence.region.name);
  console.log("Position: " + event.position.latitude + ", " + event.position.longitude);
};

self.ongeofenceleave = function(event) {
  console.log("Exited Region with Name: " + event.geofence.region.name);
  console.log("Position: " + event.position.latitude + ", " + event.position.longitude);
};
```
###Sample App
To see this plugin in action, run the following commands to create the [sample app](https://github.com/MobileChromeApps/cordova-plugin-geofencing/tree/master/test)
```bash
cordova create GeofenceDemo io.cordova.geofencedemo GeofenceDemo
cd GeofenceDemo
cordova platform add ios
cordova plugin add cordova-plugin-geofencing
mv 'plugins/cordova-plugin-geofencing/sample/config.xml' 'config.xml'
mv 'plugins/cordova-plugin-geofencing/sample/sw.js' 'www/sw.js'
mv 'plugins/cordova-plugin-geofencing/sample/index.html' 'www/index.html'
mv 'plugins/cordova-plugin-geofencing/sample/js/index.js' 'www/js/index.js'
cordova prepare
```

Enter a name into the input box and click "Create Geofence at Current Location" to do just that. The messages box will inform you whenever you enter or exit one of the geofences you created.

