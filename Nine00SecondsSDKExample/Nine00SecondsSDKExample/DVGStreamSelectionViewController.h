//
//  DVGStreamSelectionViewController.h
//  NineHundredSeconds
//
//  Created by Nikolay Morev on 03.10.14.
//  Copyright (c) 2014 DENIVIP Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DVGStreamsDataController.h"

@interface DVGStreamSelectionViewController : UITableViewController <DVGStreamsDataControllerDelegate>
@property (nonatomic, strong) DVGStreamsDataController *dataController;

- (void)streamsDataControllerDidUpdateStreams:(DVGStreamsDataController *)controller;
@end
