//
//  NHSStreamPlayerViewController.h
//  Nine00SecondsSDK
//
//  Created by Mikhail Grushin on 26/12/14.
//  Copyright (c) 2014 DENIVIP Group. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MediaPlayer;

@class NHSStream;

/**
 This class should be used whenever you want to show a user video in a separate view controller. Similar to NHSStreamPlayerController it notifies server about user started to watch a broadcast and user's location.
 */
@interface NHSStreamPlayerViewController : MPMoviePlayerViewController

/**
 Creates new instance with specified stream.
 
 @param stream A broadcast to play.
 */
- (instancetype)initWithStream:(NHSStream *)stream;

@end
