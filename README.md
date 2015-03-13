# 900SecondsSDK
Live Streaming Video SDK for iOS

900Seconds SDK is a video streaming library made for easily add geolocated live streaming into your mobile app. It encapsulates the whole stack of video streaming-related tech involved in live streaming process such as handling device camera, encoding video chunks with ffmpeg, uploading them to your file storage. Also it has a backend that handles app authorization, stores streams objects and can be requested for fetching available streams.

Some of the features the SDK handles:
- shooting the video with device camera
- compress video chunks and upload them to a file storage
- fetching available streams around the geolocation
- video streams playback

## Quick start guide
1. [Intallation](https://github.com/900Seconds/900SecondsSDK#installation-and-dependencies)
2. [Documentation](https://github.com/900Seconds/900SecondsSDK#documentation)
3. [Basic usage](https://github.com/900Seconds/900SecondsSDK#basic-usage)

### Installation and dependencies
900Seconds SDK uses several third-party libraries in its work. In order to use it in your project you will need to add those libraries too.
These are steps to set all required dependecies:

1. 900Seconds SDK requires following list of libraries

    - [AFNetworking](https://github.com/AFNetworking/AFNetworking "Link to the project on GitHub")
    - [AWSiOSSDKv2/S3  (v2.0.8)](https://github.com/aws/aws-sdk-ios "Link to the project on GitHub")
    - [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack "Link to the project on GitHub")
    - [THObserversAndBinders](https://github.com/th-in-gs/THObserversAndBinders "Link to the project on GitHub")
    - [ffmpeg](https://github.com/FFmpeg/FFmpeg "Link to the project on GitHub") - only requires .a static libraries avcodec.a, avdevice.a, avformat.a, avutil.a
    - [libextobjc](https://github.com/jspahrsummers/libextobjc "Link to the project on GitHub")

   Some of the listed libraries (like AWSiOSSDKv2/S3) have their own requirements that have to be set too. Alternatively you can add these listed dependencies using the CocoaPods. It will automatically add all required libraries and frameworks.

   If you want to be able to run you project on simulator then you also have to add iconv system library to it:
    - libiconv.dylib
   
   Simply add it in project settings inside "Link Frameworks and Libraries" section.

2. To add 900Seconds SDK to the project you need to add
    - Nine00SecondsSDK.a library. It is compiled for both iPhone and iPhone Simulator architectures. So it can be used for both.
    - All NHS-prefixed header files which come with it

3. To use the SDK classes you need to import 900Seconds SDK file:

      ` #import "Nine00SecondsSDK.h"`

   Or you can add headers for specific classes that you want to use:

       `#import "NHSBroadcastManager.h"`

### Documentation
You can find Apple-style [appledoc](https://github.com/tomaz/appledoc)-generated docs under *Nine00SecondsSDK/Docs/* subdirectory. It includes all library's APIs and classes with overview on each.

### Basic usage
Overview of all basic library features with comments.

#### Autorizing the app
First of all, you need to register your app with 900Seconds web interface. Registration will require your application ID. Also in order for library to be able to stream video you have to provide it with an access to your file storage. Currently only AWS S3 is supported. You need to register on AWS, get credentials for file storage and use them while registering your app for 900Seconds SDK. In return 900Seconds will give you secret key which you can use for authorizing the app with SDK.

Authorizing itself is very easy and require just one call to _NHSBroadcastManager_:
```objective-c
[NHSBroadcastManager registerAppID:@"YOUR_APP_ID"
                        withSecret:@"YOUR_SECRET_KEY"
                    withCompletion:(void ( ^ ) ( NHSApplication *application , NSError *error ))completion];
```
This call should be made on startup. Presumably on `application:didFinishLaunchingWithOptions:` method of your app delegate but it's really your choice, just make it before your start using the SDK.
A completion in this method is optional, just to check there were no error. _NHSApplication_ object is a model object which encapsulates your file storage credentials and other app info. The SDK keeps this instance by itself so there is no need to store it somewhere in your app.

#### Recording video
900Seconds SDK has all the AVFoundation camera-related and ffmpeg encoding logic inside already so you don't need to set anything at all. To start preview video feed from the camera just add `previewView` from _NHSBroadcastManager_ to your view hierarchy:

```objective-c
[self.view addSubview:[[NHSBroadcastManager sharedInstance] previewView]];
```
and call `startPreview`:

```objective-c
[[NHSBroadcastManager sharedInstance] startPreview];
```
To start streaming you need just another one call:

```objective-c
[[NHSBroadcastManager sharedInstance] startBroadcasting];
```
This call will create stream object on the backend and start writing and uploading video chunks to the file storage. Also it will start observing your location with CoreLocation as every stream in our SDK obliged to have a location. In order to keep user's privacy coordinates are taken with precision up to only 100 meters.
Additionally you can implement _NHSBroadcastManagerDelegate_ methods to know if everything was successful or why something failed.

To stop streaming and preview just call
```objective-c
[[NHSBroadcastManager sharedInstance] stopBroadcasting];
[[NHSBroadcastManager sharedInstance] stopPreview];
```
All the preivew and broadcasting calls are asynchronous. Implement corresponding _NHSBroadcastManagerDelegate_ methods to know exactly when start/stop methods have finished.

#### Fetching live streams
All the streams made by your application with the SDK can be fetched from backend as an array of _NHSStream_ objects. _NHSStream_ is a model object which contains information about stream such as it's ID, author ID, when it was started or stopped, how much it was watched through it's lifetime and so on.

There are two main options for fetching streams.
The first is to fetch streams with radius around some location point. To perform this fetch you should call
```objective-c
[[NHSBroadcastManager sharedInstance] fetchStreamsNearCoordinate:(CLLocationCoordinate2D)coordinate 
                                                      withRadius:(CGFloat)radiusInMeters 
                                                       sinceDate:(NSDate *)date 
                                                  withCompletion:(NHSBroadcastFetchCompletion)completion];
```

Fetch will request the backend for list of streams satisfying the parameters. When backend responds the completion will be called. Array of _NHSStream_ objects ordered by distance from coordinate are passed as _NSArray_ in the completion along with _NSError_ object. You can set _radius_ to 0 or _date_ to _nil_ to ignore those parameters, it will return all the streams made by this application.

The second fetch option is to fetch last 30 streams made by this application. This method has no parameters except for completion:
```objective-c
[[NHSBroadcastManager sharedInstance] fetchRecentStreamsWithCompletion:(NHSBroadcastFetchCompletion)completion];
```
The completion is the same as in previous method and gets called on server response.

Also you can remove any particular stream by calling
```objective-c
[[NHSBroadcastManager sharedInstance] removeStreamWithID:(NSString *)streamID 
                                              completion:(void ( ^ ) ( NSError *error ))completion];
```

#### Stream playback
To play any stream you can use either SDK player or any other player you want. There are some differences though.
900Seconds SDK can evaluate the popularity of each stream. To make this happen the application must to notify the 900Seconds backend that someone started watching the stream. When the SDK player is used backend gets notified of when and where each particular stream was watched but if the stream is watched by any other player - you just watch the video and nothing else.

The SDK player classes are _NHSStreamPlayerController_ and _NHSStreamPlayerViewController_. The first provides a _UIView_ with video feed to add to any view controller's view hierarchy. The second one is a _UIViewController_ itself with a view set to show the video. To use each of them you have to initialize it with _NHSStream_:
```objective-c
NHSStreamPlayerViewController *player = [[NHSStreamPlayerViewController alloc] initWithStream:(NHSStream *)stream];
[self presentMoviePlayerViewControllerAnimated:player];
```

Player controllers are subclasses of _MPMoviePlayerController_ and _MPMoviePlayerViewController_ so you can get any standard MediaPlayer notifications via Notification Center.

Alternatively you can play stream by yourself. In order to do this you need to obtain streaming URL from _NHSBroadcastManager_:
```objective-c
NSURL *streamingURL = [[NHSBroadcastManager sharedInstance] broadcastingURLWithStream:(NHSStream *)stream];
```

You can play this URL in _MPMoviePlayer_ or _AVPlayer_ or any other player. Just remember that it won't increase stream's popularity since backend won't be told of this playback.

## Requirements
Besides including [listed](https://github.com/900Seconds/900SecondsSDK#installation-and-dependencies) third-party libraries your app have to be deployed at iOS 7 or higher with ARC.
