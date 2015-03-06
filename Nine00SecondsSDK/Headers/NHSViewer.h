//
//  NHSViewer.h
//  Nine00SecondsSDK
//
//  Created by Mikhail Grushin on 19.12.14.
//  Copyright (c) 2014 DENIVIP Group. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

/**
 NHSViewer class is a model to a user watching the broadcast with his application. Normally developers don't need to create instances of this class by themselves. Broadcast manager will return an array of NHSViewer objects after the request of status of the stream.
 */
@interface NHSViewer : NSObject

/**
 ID of a broadcast user is watching.
 */
@property (nonatomic, copy) NSString *streamID;

/**
 Application ID of an app that playing the broadcast.
 */
@property (nonatomic, copy) NSString *viewerID;

/**
 This property shows how much viewers request watcher's app sent for this broadcast. In other words this can show how long user is watching this video.
 */
@property (nonatomic) NSUInteger hits;

/**
 Coordinates of a user. With respect to privacy coordinates' accuracy is 100 meters.
 */
@property (nonatomic) CLLocationCoordinate2D locationCoordinate;

/**
 Time when the user started to watch the broadcast.
 */
@property (nonatomic, copy) NSDate *createdAt;

/**
 Time of last object update.
 */
@property (nonatomic, copy) NSDate *updatedAt;

/**
 Creates new instance with value that needs to be set.
 
 @param dictionary Key-value table of values to set.
 */
+ (instancetype)viewerWithDictionary:(NSDictionary *)dictionary;

@end