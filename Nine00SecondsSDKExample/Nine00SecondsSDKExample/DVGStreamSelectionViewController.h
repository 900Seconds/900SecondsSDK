//
//  DVGStreamSelectionViewController.h
//  NineHundredSeconds
//
//  Created by Nikolay Morev on 03.10.14.
//  Copyright (c) 2014 900 Seconds Oy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DVGStreamsDataController;

@interface DVGStreamSelectionViewController : UITableViewController

@property (nonatomic, strong) DVGStreamsDataController *dataController;

@end
