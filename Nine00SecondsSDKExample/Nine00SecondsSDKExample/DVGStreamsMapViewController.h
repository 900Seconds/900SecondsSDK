//
//  DVGStreamsMapViewController.h
//  NineHundredSeconds
//
//  Created by Nikolay Morev on 10.11.14.
//  Copyright (c) 2014 900 Seconds Oy. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;

@interface DVGStreamsMapViewController : UIViewController

//! In window base coordinates
@property (nonatomic) CGPoint selectedStreamCenter;
@property (nonatomic, assign) CLLocationCoordinate2D initialCoordinates;

@end
