//
//  NHSStreamPlayerController.h
//  Nine00SecondsSDK
//
//  Created by Mikhail Grushin on 26/12/14.
//  Copyright (c) 2014 900 Seconds Oy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@import MediaPlayer;

@class NHSStream;

/**
 NHSStreamPlayerController is a subclass of MPMoviePlayerController that lets you play broadcasts in it's view and add it to an any view hierarchy. Instances of this class automatically notify server when user started to watch video so the server side can increase broadcasts popularity. Notifications are going every minute. Device's coordinates are also passed to server in order to know where the video viewers are. With respect to user's privacy coordinates' accuracy is about 100 meters.
 */
@interface NHSStreamPlayerController : MPMoviePlayerController

/**
 Currently playing stream.
 */
@property (nonatomic, strong, readonly) NHSStream *stream;

/**
 Creates new instance with specified stream.
 
 @param stream A broadcast to play.
 */
- (instancetype)initWithStream:(NHSStream *)stream;

/**
 Convinience method that will make player's view to disappear smoothly and remove it from superview afterwards.
 */
- (void)hidePlayer;

@end
