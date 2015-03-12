# 900SecondsSDK
Live Streaming Video SDK for iOS

900Seconds SDK is a video streaming library made for easily add live streaming into your mobile app. It encapsulates the whole stack of video streaming-related tech involved in live streaming process such as handling device camera, encoding video chunks with ffmpeg, uploading them to file storage. Also it has a backend that handles app authorization, stores streams objects and can be requested for fetching available streams.

Some of the features the SDK handles:
- shooting the video with device camera
- compress video chunks and upload them to a file storage
- fetching available streams around the geolocation
- video streams playback

## Quick start guide
1. [Intallation](md_installation)
2. [Documentation](md_documetation)
3. [Basic usage](md_basic_usage)

### <a name="md_installation"></a>Installation ###
900Seconds SDK uses several third-party libraries in its work. In order to use it in your project you will need to add those libraries too.
These are steps to set all required dependecies:

1. 900Seconds SDK requires following list of libraries

    - AFNetworking ([github](https://github.com/AFNetworking/AFNetworking "Link to the project on GitHub"))
    - AWSiOSSDKv2/S3 (v2.0.8) ([github](https://github.com/aws/aws-sdk-ios "Link to the project on GitHub"))
    - CocoaLumberjack ([github](https://github.com/CocoaLumberjack/CocoaLumberjack "Link to the project on GitHub"))
    - THObserversAndBinders ([github](https://github.com/th-in-gs/THObserversAndBinders "Link to the project on GitHub"))
    - ffmpeg ([github](https://github.com/FFmpeg/FFmpeg "Link to the project on GitHub")) - only requires .a static libraries avcodec.a, avdevice.a, avformat.a, avutil.a
    - libextobjc ([github](https://github.com/jspahrsummers/libextobjc "Link to the project on GitHub"))

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

### <a name="md_documetation"></a>Documentation ###
You can find Apple-style [appledoc](https://github.com/tomaz/appledoc)-generated docs under *Nine00SecondsSDK/Docs/* subdirectory.

### <a name="md_basic_usage"></a>Basic usage ###
#### Autorizing the app

## Requirements
