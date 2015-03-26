#Geofencing Plugin for Cordova Service Worker
The cordova geofencing plugin enables developers to set up set up region monitoring and handle boundary crossing events with a service worker. Regions persist even when the app is quit and are monitored even when your app is in the background.

##Supported Platforms
Cordova service worker is currently limited to iOS
 - iOS 

##Installation
To add the plugin to your project, use this cli command from within your project
```
cordova plugin add https://github.com/imintz/cordova-plugin-geofencing.git
```
To remove the plugin use
```
cordova plugin rm org.apache.cordova.geofencing
```
##Example Usage
On your active page:
```javascript
navigator.serviceWorker.ready.then(function(serviceWorkerRegistration) {
  var region = new CircularGeofenceRegion("Name", latitude, longitude, radius);
  serviceWorkerRegistration.geofencing.register(region).then(function(regionRegistration) {
    console.log("Created Geofence " + regionRegistration);
  }, function(error) {
    console.log("Error: " + error);
  });
});
```
In your service worker script:
```javascript
self.ongeofenceenter = function(event) {
  console.log("Entered Region with Name: " + event.registration.region.name);
  console.log("Position: " + event.position.latitude + ", " + event.position.longitude);
};

self.ongeofenceleave = function(event) {
  console.log("Exited Region with Name: " + event.registration.region.name);
  console.log("Position: " + event.position.latitude + ", " + event.position.longitude);
};
```
###Sample App
To see this plugin in action, run the following commands to create the [sample app](https://github.com/imintz/cordova-plugin-geofencing/tree/master/test)
```bash
cordova create GeofenceDemo
cd GeofenceDemo
cordova platform add ios
cordova plugin add https://github.com/mwoghiren/cordova-plugin-serviceworker.git
cordova plugin add https://github.com/imintz/cordova-plugin-geofencing.git
mv 'plugins/org.apache.cordova.geofencing/test/config.xml' 'config.xml'
mv 'plugins/org.apache.cordova.geofencing/test/sw.js' 'www/sw.js'
mv 'plugins/org.apache.cordova.geofencing/test/index.html' 'www/index.html'
mv 'plugins/org.apache.cordova.geofencing/test/js/index.js' 'www/js/index.js'
cordova prepare
```

Enter a name into the input box and click "Create Geofence at Current Location" to do just that. The messages box will inform you whenever you enter or exit one of the geofences you created.

