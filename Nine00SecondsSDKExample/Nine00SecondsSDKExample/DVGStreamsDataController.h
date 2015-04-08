//
//  DVGStreamsDataController.h
//  NineHundredSeconds
//
//  Created by Nikolay Morev on 23.12.14.
//  Copyright (c) 2014 900 Seconds Oy. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

typedef NS_ENUM(NSUInteger, DVGStreamsDataControllerType) {
    DVGStreamsDataControllerTypeRecent,
    DVGStreamsDataControllerTypeLocation
};

@class DVGStreamsDataController;

@protocol DVGStreamsDataControllerDelegate <NSObject>

- (void)streamsDataControllerDidUpdateStreams:(DVGStreamsDataController *)controller;

@end

@interface DVGStreamsDataController : NSObject

@property (nonatomic, weak) id<DVGStreamsDataControllerDelegate> delegate;
@property (nonatomic, copy) NSArray *streams;

@property (nonatomic, assign) DVGStreamsDataControllerType type;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) float radius;
@property (nonatomic, strong) NSDate *sinceDate;

- (void)refresh;
- (void)removeStreamAtIndex:(NSUInteger)index;

@end
