//
//  DVGStreamSelectionViewController.h
//  NineHundredSeconds
//
//  Created by Nikolay Morev on 03.10.14.
//  Copyright (c) 2014 DENIVIP Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DVGStreamsDataController;

@interface DVGStreamSelectionViewController : UITableViewController

@property (nonatomic, strong) DVGStreamsDataController *dataController;

@end
