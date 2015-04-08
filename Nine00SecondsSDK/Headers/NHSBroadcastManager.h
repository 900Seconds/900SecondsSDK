//
//  NHSBroadcastManager.h
//  Nine00SecondsSDK
//
//  Created by Mikhail Grushin on 18.12.14.
//  Copyright (c) 2014 900 Seconds Oy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NHSCapturePreviewView.h"

@import CoreLocation;

@class NHSStream, NHSApplication, NHSBroadcastManager, AFHTTPRequestOperation;

/**
 A completion for creating stream. Contains stream created with values from server and information about error, or nil if everything is allright.
 */
typedef void (^NHSBroadcastCreateCompletion)(NHSStream *stream, NSError *error);

/**
 A completion for fetching list of streams or viewers. Contains array of fethed items and NSError instance.
 */
typedef void (^NHSBroadcastFetchCompletion)(NSArray *array, NSError *error);

@protocol NHSBroadcastManagerDelegate;

/**
 NHSBroadcastManager is a single object that manages whole lifecycle of a broadcast from creation to stopping and deletion. All the backend method's calls are performed with broadcast manager. Listing existing broadcasts are also performed with this object.
 Broadcast manager maintains the broadcasts video upload queue keeping it persistent when application is no longer active.
 */

@interface NHSBroadcastManager : NSObject

/**
 Broadcast manager delegate object.
 */
@property (nonatomic, weak) id<NHSBroadcastManagerDelegate> delegate;

/**
 A preview view for capturing video from camera. Before starting recording video for broadcasting the developers have to add this view to current controller view hierarchy.
 */
@property (nonatomic, strong, readonly) NHSCapturePreviewView *previewView;

/**
 Amount of bytes sent by current broadcast.
 */
@property (nonatomic, readonly) int64_t currentStreamBytesSent;

/**
 Average bitrate of streaming video. Defaults to 440 kbps. Maximum value equals 8500 kbps. Recommended values for HLS bitrate described in [Bitrate recommendations](https://developer.apple.com/library/ios/technotes/tn2224/_index.html#//apple_ref/doc/uid/DTS40009745-CH1-BITRATERECOMMENDATIONS) and [Encoding settings](https://developer.apple.com/library/ios/technotes/tn2224/_index.html#//apple_ref/doc/uid/DTS40009745-CH1-SETTINGSFILES).
 */
@property (nonatomic, assign) NSUInteger averageBitrate;

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
 */
- (void)toggleCamera;

/**
 This method starts recording video to local temporary file and creates a request for creating a NHSStream object on server side. If server responds with success the broadcasting starts. If a stream fails to be created then no broadcasting will take place and appropriate delegate method will be called. Broadcast manager will start uploading video to the file storage automatically. Also this method triggers the location updates which will be set as broadcast coordinates. This method will have no effect if preview is not started.
 */
- (void)startBroadcasting;

/**
 This method requests list of users currently watching specified stream. Response contains array of NHSViewer objects and NSError.
 
 @param stream A stream which ID will be used to request a viewers list.
 @param completion A completion to be called on server response.
 */
- (void)viewersForStream:(NHSStream *)stream withCompletion:(NHSBroadcastFetchCompletion)completion;

/**
 Call this method to recording new frames to temporary video file. Afterwards the current stream will upload last chunks of video and will inform server that the corresponding broadcast is stopped. This method will have no effect if there is no recording session.
 */
- (void)stopBroadcasting;

/**
 This method stops video data to be transferred to preview view and removes it from superview. This method will have no effect if there is a broadcasting going.
 */
- (void)stopPreview;

/**
 This method is identical to [NHSBroadcastManager stopPreview] method but is will run asynchronously on background thread without blocking main queue.
 */
- (void)stopPreviewAsync;

/**@name Fetching broadcasts from server*/

/**
 Requires server side to remove a broadcast.
 
 @param streamID An ID of the stream corresponding to broadcast.
 @param completion Completion to be called on server respond. NSError object contains information about error, or will be nil if no error has happened.
 */
- (void)removeStreamWithID:(NSString *)streamID
                completion:(void (^)(NSError *error))completion;

/**
 Fetching a list of broadcasts made with current application.
 
 @param completion Completion has an array of NHSStream objects as returned broadcasts and NSError object with information about error.
 */
- (void)fetchRecentStreamsWithCompletion:(NHSBroadcastFetchCompletion)completion;

/**
 Fetching a list of broadcasts filtered by coordinate, proximity and age.
 
 @param coordinate A reference coordinate which has to be matched by broadcast's coordinates.
 @param radiusInMeters A proximity radius for coordinate parameter. If broadcast's coordinates are happen inside the proximity radius - broadcast will be returned.
 @param date Date after which broadcast have to be made in order to be returned by request.
 @param completion Completion will be called on server response and contains returned broadcasts array and an error instance.
 @return Instance of fetch operation is returned by this method. Operation does not require manual start.
 */
- (AFHTTPRequestOperation *)fetchStreamsNearCoordinate:(CLLocationCoordinate2D)coordinate
                                            withRadius:(CGFloat)radiusInMeters
                                             sinceDate:(NSDate *)date
                                        withCompletion:(NHSBroadcastFetchCompletion)completion;

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


/**
 Triggered after calling startBroadcast method if stream was successfully created.
 
 @param manager Current broadcast manager
 @param stream Created stream.
 */
- (void)broadcastManager:(NHSBroadcastManager *)manager didStartBroadcastWithStream:(NHSStream *)stream;

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
