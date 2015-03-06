//
//  DVGStreamsDataController.m
//  NineHundredSeconds
//
//  Created by Nikolay Morev on 23.12.14.
//  Copyright (c) 2014 DENIVIP Group. All rights reserved.
//

#import "DVGStreamsDataController.h"
#import "Nine00SecondsSDK.h"

@interface DVGStreamsDataController ()

@end

@implementation DVGStreamsDataController

- (void)refresh
{
    if (self.type == DVGStreamsDataControllerTypeRecent) {
        @weakify(self);
        [[NHSBroadcastManager sharedManager] fetchRecentStreamsWithCompletion:^(NSArray *streams, NSError *error) {
            @strongify(self);
            if (streams) {
                self.streams = streams;
            }
            else {
                // To hide activity indicator
                [self.delegate streamsDataControllerDidUpdateStreams:self];
            }
        }];
    } else {
        [[NHSBroadcastManager sharedManager] fetchStreamsNearCoordinate:self.coordinate
                                                             withRadius:self.radius
                                                              sinceDate:self.sinceDate
                                                         withCompletion:^(NSArray *streamsArray, NSError *error) {
                                                             if (streamsArray.count) {
                                                                 self.streams = streamsArray;
                                                             } else {
                                                                 [self.delegate streamsDataControllerDidUpdateStreams:self];
                                                             }
        }];
    }
}

- (void)removeStreamAtIndex:(NSUInteger)index
{
    NHSStream *stream = self.streams[index];

    NSMutableArray *streams = [self.streams mutableCopy];
    [streams removeObjectAtIndex:index];
    _streams = [NSArray arrayWithArray:streams];

    @weakify(self);
    [[NHSBroadcastManager sharedManager] removeStreamWithID:stream.streamID completion:^(NSError *error) {
        @strongify(self);
        [self.delegate streamsDataControllerDidUpdateStreams:self];
    }];
}

- (void)setStreams:(NSArray *)streams
{
    _streams = [streams copy];
    [self.delegate streamsDataControllerDidUpdateStreams:self];
}

@end
