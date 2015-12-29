//
//  NHSBroadcastManager.h
//  Nine00SecondsSDK
//
//  Created by Mikhail Grushin on 18.12.14.
//  Copyright (c) 2014 900 Seconds Oy. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;
@import AVFoundation;
@import CoreLocation;

@class NHSStream, NHSApplication, NHSBroadcastManager, AFHTTPRequestOperation;

/**
 These streaming options is used to set a quality of broadcasting video. Choosing one of presets you set the video's resolution and bitrate. Recommended values for HLS bitrate and resolutions described in [Bitrate recommendations](https://developer.apple.com/library/ios/technotes/tn2224/_index.html#//apple_ref/doc/uid/DTS40009745-CH1-BITRATERECOMMENDATIONS) and [Encoding settings](https://developer.apple.com/library/ios/technotes/tn2224/_index.html#//apple_ref/doc/uid/DTS40009745-CH1-SETTINGSFILES).
 */
typedef NS_ENUM(NSUInteger, NHSStreamingQualityPreset) {
    /**
     This is the lowest quality preset. It sets resolution to 480x270 and a bitrate to 464 kbps (real bitrate values may be slightly different after encoding). Suitable for both cellular and Wi-Fi connections.
     */
    NHSStreamingQualityPreset480,
    /**
     This is default quality preset suitable for both Wi-Fi and cellular connections. Also the highest one for cellular. It sets resolution to 640x360 and bitrate to 664 kbps.
     */
    NHSStreamingQualityPreset640,
    /**
     This preset sets resolution to 640x360 and bitrate to 1296 kbps. Can be used only for Wi-Fi connections.
     */
    NHSStreamingQualityPreset640HighBitrate,
    /**
     This preset sets resolution to 960x540 and bitrate to 3596 kbps. Can be used only for Wi-Fi connections.
     */
    NHSStreamingQualityPreset960,
    /**
     This preset sets resolution to 1280x720 and bitrate to 5128 kbps. Can be used only for Wi-Fi connections.
     */
    NHSStreamingQualityPreset1280,
    /**
     This preset sets resolution to 1280x720 and bitrate to 6628 kbps. Can be used only for Wi-Fi connections.
     */
    NHSStreamingQualityPreset1280HighBitrate
};


typedef NS_ENUM(NSUInteger, NHSStreamingFilter) {
    NHSStreamingFilterNoFilter,
    NHSStreamingFilterSepia,
    NHSStreamingFilterSaturation,
    NHSStreamingFilterColorLookup,
    NHSStreamingFilterBlur,
    NHSStreamingFilterVignette,
    NHSStreamingFilterPixellate,
    NHSStreamingLiveOverlay = 99
};

extern NSString *const kNHSApiCompletionStreamsKey;
extern NSString *const kNHSApiCompletionViewersKey;
extern NSString *const kNHSApiCompletionTotalsKey;

/**
 A completion for Api calls. See kNHSApiCompletion* for possible keys
 */
typedef void (^NHSBroadcastApiCallCompletion)(NSDictionary* result, NSError *error);

@protocol NHSBroadcastManagerDelegate;

/**
 NHSBroadcastManager is a single object that manages whole lifecycle of a broadcast from creation to stopping and deletion. All the backend method's calls are performed with broadcast manager. Listing existing broadcasts are also performed with this object.
 Broadcast manager maintains the broadcasts video upload queue keeping it persistent when application is no longer active.
 
 Implement NHSBroadcastManagerDelegate methods to be notified about video streaming events.
 */

@interface NHSBroadcastManager : NSObject

/**
 Broadcast manager delegate object.
 */
@property (nonatomic, weak) id<NHSBroadcastManagerDelegate> delegate;

/**
 Amount of bytes sent by current broadcast.
 */
@property (nonatomic, readonly) int64_t currentStreamBytesSent;

/**
 Use this property to set a streaming video quality. The consistency of broadcasting depends on the quality you choose for particular connection. We advice you to choose lower presets for cellular connections and higher ones for Wi-Fi connections. 
 
    This property defaults to NHSStreamingQualityPreset640. Cannot be applied to a broadcasting that currently is in progress. If you set this property while streaming a video, quality will be applied next broadcasts.
 
 __Important__. The maximum preset which can be used for cellular connections is NHSStreamingQualityPreset640. If you try setting higher preset broadcast manager will automatically be set to NHSStreamingQualityPreset640. The Wi-Fi connection has no restrictions.
 */
@property (nonatomic, assign) NHSStreamingQualityPreset qualityPreset;


/**
 Use this property to setup default hsl stream chunk duration
 Initial duration is kDefaultSegmentTargetDuration = 8 sec
 */
@property (nonatomic, assign) NSTimeInterval chunkDuration;

/**
 NHSBroadcastManager is a singleton object which means it is created only once per application lifetime and then is always available. To get current broadcast manager object developers have to call this class method.
 
 @return Broadcast manager instance.
 */
+ (instancetype)sharedManager;

/**@name Authenticating the application */

/**
 The application that use this SDK need to be registered with it's application ID and secret key. In response server will grant it with credentials to file storage. This class method should be called every time when application starts in order for broadcast manager to be able to upload video chunks to file storage.
 
 @param appID The ID of application that uses Nine00SecondsSDK.
 @param secret The secret key obtained by developers after registering application.
 @param completion A completion to be called on server response. It contains NHSApplication object which holds file storage credentials and NSError object that will contain information in case something went wrong. The NHSApplication object is retained by broadcast manager so there is no need to save it somewhere else.
 */
+ (void)registerAppID:(NSString *)appID
           withSecret:(NSString *)secret
       withCompletion:(void (^)(NHSApplication *application, NSError *error))completion;

/**@name Maintaining the upload queue */

/**
 This method forces broadcast manager to start maintaining upload queue. Normally when startBroadcasting method is called broadcast manager performs upload automatically so there is no need to call this method in this case.
 In order not to loose the upload when application goes to background broadcast manager saves the video upload queue to disk. When application is back to foreground queue will be loaded but won't automatically continue the upload process. Developers have to call this method to continue the upload.
 */
- (void)scheduleSavedUploads;

/**
 @name Recording the video
 */

/**
 Call this method to start transmitting video data from camera to previewView. The preview view must have a superview in order for this method to have effect. This method will arrange all resources required to start a recording and broadcasting.
 */
- (void)startPreview;

/**
 Call this method if you want to switch between front and back camera on the device.
 Use AVCaptureDevicePositionUnspecified to flip camera
 */
- (AVCaptureDevicePosition)setupCameraInto:(AVCaptureDevicePosition)newposition;


/**
 Call this method if you want to switch between front and back camera on the device.
 */
- (void)setupCameraFilter:(NHSStreamingFilter)filterId withParams:(NSDictionary*)filterParams;

/**
 Call this method to mix UIView content into video.
 */
- (void)setupCameraLiveOverlay:(UIView*)liveOvl;

/**
 Mute sound during capture.
 */
- (BOOL)muteSound:(BOOL)mute;

/**
 A preview view for capturing video from camera. Before starting recording video for broadcasting the developers have to add this view to current controller view hierarchy.
 */
- (UIView *)createPreviewViewWithRect:(CGRect)frame;

/**
 Adding focus area animation at specified point with previously created preview view
 */
- (BOOL)showFocusAreaAt:(CGPoint)p withPreview:(UIView *)preview;

/**
 Hiding focus area with previously created preview view
 */
- (BOOL)hideFocusAreaWithPreview:(UIView *)preview;

/**
 This method starts recording video to local temporary file and creates a request for creating a NHSStream object on server side. If server responds with success the broadcasting starts. If a stream fails to be created then no broadcasting will take place and appropriate delegate method will be called. Broadcast manager will start uploading video to the file storage automatically. Also this method triggers the location updates which will be set as broadcast coordinates. This method will have no effect if preview is not started.
 
 When broadcasting have started the SDK starts using AVFoundation to write and compress video and ffmpeg to encode chunks of video as .ts files and then send them to the file storage. Currently all .ts files have a duration of 8 seconds. The upload process is going asynchrounously on background after each next chunk is created.

 */
- (void)startBroadcasting;
- (BOOL)isBroadcastRecording;

/**
 Call this method to pause/unpause broadcast. This method will have no effect if there is no recording session.
 */
- (void)pauseBroadcasting:(BOOL)enable;
- (BOOL)isBroadcastPaused;

/**
 Call this method to stop recording new frames to temporary video file. Afterwards the current stream will upload last chunks of video and will inform server that the corresponding broadcast is stopped. This method will have no effect if there is no recording session.
 */
- (void)stopBroadcasting;

/**
 Call this method to cancel broadcast and remove stream/trails. This method will have no effect if there is no recording session.
 */
- (void)cancelBroadcasting;

/**
 This method stops video data to be transferred to preview view and removes it from superview. This method will have no effect if there is a broadcasting going.
  @param async stop asynchronously on background thread without blocking main queue
 */
- (void)stopPreview:(BOOL)async;

/**@name Fetching broadcasts from server*/

/**
 This method requests list of users currently watching specified stream. Response contains array of NHSViewer objects and NSError.
 
 @param stream A stream which ID will be used to request a viewers list.
 @param untilDate _Optional_. If set the method will return a list of 30 viewers who watched the stream before the _untilDate_. If _nil_ then the method will return last 30 viewers.
 @param completion A completion to be called on server response.
 */
- (void)viewersForStream:(NHSStream *)stream
               untilDate:(NSDate *)untilDate
          withCompletion:(NHSBroadcastApiCallCompletion)completion;

- (void)updateStream:(NHSStream *)stream
             setType:(NSString *)type
      withCompletion:(NHSBroadcastApiCallCompletion)completion;
/**
 Requires server side to remove a broadcast.
 
 @param streamID An ID of the stream corresponding to broadcast.
 @param completion Completion to be called on server respond. NSError object contains information about error, or will be nil if no error has happened.
 */
- (void)removeStreamWithID:(NSString *)streamID
                completion:(void (^)(NSError *error))completion;

/**
 Fetching a list of broadcasts made with current author.
 
 @param untilDate _Optional_. If this parameter has been set method will return 30 streams before this date. If passed _nil_ then method will return 30 most recent streams.
 @param completion Completion has an array of NHSStream objects as returned broadcasts and NSError object with information about error.
 */
- (void)fetchStreamsUntilDate:(NSDate *)untilDate
               withCompletion:(NHSBroadcastApiCallCompletion)completion;

/**
 Fetching a list of broadcasts made by specific author.

 @param authorID String argument which specifies ID of the application that authored fetched videos.
 @param untilDate _Optional_. If this parameter has been set method will return 30 streams before this date. If passed _nil_ then method will return 30 most recent streams.
 @param completion Completion has an array of NHSStream objects as returned broadcasts and NSError object with information about error.
*/
- (void)fetchStreamsOfAuthorWithID:(NSString *)authorID
                         untilDate:(NSDate *)untilDate
                        completion:(NHSBroadcastApiCallCompletion)completion;

/**
 Fetching a list of broadcasts filtered by coordinate, proximity and age.
 
 @param coordinate A reference coordinate which has to be matched by broadcast's coordinates.
 @param radiusInMeters _Optional_. A proximity radius for coordinate parameter. If broadcast's coordinates are happen inside the proximity radius - broadcast will be returned. If radius is set to 0 then it's ignored and all streams will be returned.
 @param date _Optional_. Date before which broadcast have to be made in order to be returned by request. If date is set to nil then this parameter will be ignored and 30 latest streams will be passed in response.
 @param completion Completion will be called on server response and contains returned broadcasts array and an error instance.
 @return Instance of fetch operation is returned by this method. Operation does not require manual start.
 */
- (AFHTTPRequestOperation *)fetchStreamsNearCoordinate:(CLLocationCoordinate2D)coordinate
                                            withRadius:(CGFloat)radiusInMeters
                                             untilDate:(NSDate *)date
                                        withCompletion:(NHSBroadcastApiCallCompletion)completion;

/**@name Playing broadcasts*/

/**
 Method returns a url to video broadcasting. This url can be used in any video player.
 
 @param stream NHSStream object that corresponds to broadcast.
 @return A NSURL object containing a remote video url.
 */
- (NSURL *)broadcastingURLWithStream:(NHSStream *)stream;

@end

/**
 Broadcast manager calling delegate methods to inform about broadcasting events.
 */
@protocol NHSBroadcastManagerDelegate <NSObject>
@optional

/**
 Triggered after calling startBroadcast method if stream was successfully created.
 
 @param manager Current broadcast manager.
 @param stream Created stream.
 */
- (void)broadcastManager:(NHSBroadcastManager *)manager didStartBroadcastWithStream:(NHSStream *)stream;

/**
 Triggered when preview image for current streaming video is created. Afterwards image will be uploaded on server and included into stream object.
 
 After every stream creation it's first captured video frame will be turned into a UIImage object and sent to a file storage. After this was performed the image url is set on the stream object on server.
 
 @param manager Current broadcast manager.
 @param streamID ID of stream for which the preview has been created.
 @param previewImage UIImage object which holds first video frame.
 */
- (void)broadcastManager:(NHSBroadcastManager *)manager didCreatePreviewImageForStreamWithID:(NSString *)streamID image:(UIImage *)previewImage;

/**
 This method is called when NHSBroadcastManager has successfully updated coordinate for streaming video. Stream location gets updated during broadcasting when user location has significantly changed.
 
 @param manager Current broadcast manager.
 @param streamID ID of stream which updated it's location coordinate.
 @param location New location coordinate of stream.
 */
- (void)broadcastManager:(NHSBroadcastManager *)manager didUpdateLocationForStreamWithID:(NSString *)streamID withLocation:(CLLocation*)location;


/**
 This method is called before NHSBroadcastManager ready to update coordinate for streaming video. Stream location gets updated during broadcasting when user location has significantly changed.
 
 @param manager Current broadcast manager.
 @param streamID ID of stream which updated it's location coordinate.
 @param location New location coordinate of stream.
 @return CLLocation to be used for update. nil - do not update
 */
- (CLLocation*)broadcastManager:(NHSBroadcastManager *)manager willUpdateLocationForStreamWithID:(NSString *)streamID withLocation:(CLLocation*)location;

/**
 This method is called when NHSBroadcastManager has successfully uploaded video chunk on server
 
 @param manager Current broadcast manager.
 @param number number of chunk in HLS
 @param streamID ID of stream which updated it's location coordinate.
 @param error uploading error or nil
 */
- (void)broadcastManager:(NHSBroadcastManager *)manager didUploadedChunk:(NSInteger)number forStreamWithID:(NSString *)streamID withError:(NSError *)error;

/**
 Triggered when recording error has occured.
 
 @param manager Current broadcast manager.
 */
- (void)broadcastManagerDidFailToStartRecording:(NHSBroadcastManager *)manager;

/**
 Triggered when server side failed to create broadcast.
 
 @param manager Current broadcast manager.
 @param error Error that occurred on creating a stream.
 */
- (void)broadcastManagerDidFailToCreateStream:(NHSBroadcastManager *)manager withError:(NSError *)error;

/**
 Triggered after when camera stopped recording video to a temporary file.
 
 @param manager Current broadcast manager.
 */
- (void)broadcastManagerDidStopRecording:(NHSBroadcastManager *)manager;

/**
 Triggered when broadcast manager uploaded all chunks of video to file storage after the camera stopped recording.
 
 @param manager Current broadcast manager.
 @param stream Broadcasted stream.
 */
- (void)broadcastManager:(NHSBroadcastManager *)manager didStopBroadcastOfStream:(NHSStream *)stream;

/**
 This method asks delegate about current interface orientation.
 
 @param manager Current broadcast manager.
 @return Current screen interface orientation.
 */
- (UIInterfaceOrientation)broadcastManagerCameraInterfaceOrientation:(NHSBroadcastManager *)manager;

@end
