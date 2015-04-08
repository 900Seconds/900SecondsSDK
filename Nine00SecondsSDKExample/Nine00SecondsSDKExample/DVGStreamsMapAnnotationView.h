//
//  DVGStreamsMapAnnotationView.h
//  NineHundredSeconds
//
//  Created by Nikolay Morev on 19.12.14.
//  Copyright (c) 2014 900 Seconds Oy. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface DVGStreamsMapAnnotationView : MKAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation
                   reuseIdentifier:(NSString *)reuseIdentifier
                             frame:(CGRect)frame;

//! From 0 to 1 (inclusive). 1 means most popular.
@property (nonatomic) float popularity;
//! From 0 to 1 (inclusive). 1 means newest.
@property (nonatomic) float age;

// Protected

@property (nonatomic) CGRect innerRect;

@end
