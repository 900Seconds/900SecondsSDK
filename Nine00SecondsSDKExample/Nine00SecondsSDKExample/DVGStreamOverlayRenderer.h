//
//  DVGStreamOverlayRenderer.h
//  NineHundredSeconds
//
//  Created by Nikolay Morev on 12.11.14.
//  Copyright (c) 2014 900 Seconds Oy. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface DVGStreamOverlayRenderer : MKOverlayRenderer

//! From 0 to 1 (inclusive). 1 means most popular.
@property (nonatomic) float popularity;

@end
