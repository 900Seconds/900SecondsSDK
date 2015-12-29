//
//  NHSStream.h
//  Nine00SecondsSDK
//
//  Created by Mikhail Grushin on 19.12.14.
//  Copyright (c) 2014 900 Seconds Oy. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kNHSStreamTypeSelfie;
extern NSString *const kNHSStreamTypeLandscape;

@import CoreLocation;

/**
 NHSStream class is a model to a broadcast. Normally developers don't need to create instances of this class themselves as SDK itself would create NHSStream object when broadcast manager starts broadcasting. Also the server side's response to a broadcasts requests will be parsed to an array of NHSStream objects.
 */
@interface NHSStream : NSObject

/**
 Name of the broadcast.
 */
@property (nonatomic, copy) NSString *name;

/**
 ID of the corresponding broadcast.
 */
@property (nonatomic, copy, readonly) NSString *streamID;

/**
 Author ID of the corresponding broadcast. By default all broadcasts that was created by the application has application's appID as it's authorID.
 */
@property (nonatomic, copy) NSString *authorID;

/**
 User-defined type/tag of the broadcast, see kDVGStreamType* (example: "selfie,landsc,customflag")
 */
@property (nonatomic, copy) NSString *streamType;

/**
 URL to stream preview image on file storage.
 */
@property (nonatomic, copy) NSURL *previewImageURL;

/**
 Coordinates of the location where the broadcast was streamed.
 */
@property (nonatomic) CLLocationCoordinate2D locationCoordinate;

/**
 Precision flag (0/1) of the broadcast locationCoordinate.
 */
@property (nonatomic) NSInteger locationPrecision;

/**
 Amount of users who watch this broadcast.
 */
@property (nonatomic) NSInteger popularity;

/**
 Golden streams are more important than other
 */
@property (nonatomic) NSInteger goldenState;

/**
 The time on which last segment of video was recorded.
 */
@property (nonatomic, copy) NSDate *lastSegmentCreatedAt;

/**
 The time by which broadcast stopped streaming.
 */
@property (nonatomic, copy) NSDate *stoppedAt;

/**
 Broadcast's creation time.
 */
@property (nonatomic, copy) NSDate *createdAt;

/**
 Time of last update of server object.
 */
@property (nonatomic, copy) NSDate *updatedAt;


/**
 Time, after which server object will be deleted.
 */
@property (nonatomic, copy) NSDate *validUntil;


/**
 Returns YES, if broadcasts is streaming now. Otherwise returns NO.
 */
@property (nonatomic, readonly, getter=isLive) BOOL live;

/**
 Creates new NHSStream instance with stream ID.
 
 @param streamID Stream ID.
 */
- (instancetype)initWithStreamID:(NSString *)streamID;

/**
 Creates new NHSStream instance with dictionary of parameters that needs to be set.
 Stream instances with the same streamID will be the same objects too.
 
 @param dictionary Key-value table of paramters to set.
 */
+ (instancetype)streamWithDictionary:(NSDictionary *)dictionary;

@end
