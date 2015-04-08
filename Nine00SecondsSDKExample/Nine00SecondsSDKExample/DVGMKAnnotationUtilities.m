//
//  DVGMKAnnotationUtilities.m
//  NineHundredSeconds
//
//  Created by Nikolay Morev on 19.12.14.
//  Copyright (c) 2014 900 Seconds Oy. All rights reserved.
//

#import "DVGMKAnnotationUtilities.h"

MKMapRect DVGMKAnnotationsBoundingMapRect(NSArray /* id<MKAnnotation> */ *annotations)
{
    // TODO check last meridian edge case

    if (annotations.count == 0) return MKMapRectNull;

    CLLocationCoordinate2D point0 = [annotations[0] coordinate];
    MKMapPoint mapPoint0 = MKMapPointForCoordinate(point0);

    __block double
    minX = mapPoint0.x, minY = mapPoint0.y,
    maxX = mapPoint0.x, maxY = mapPoint0.y;

    for (NSInteger idx = 0; idx < annotations.count; idx++) {
        CLLocationCoordinate2D point = [annotations[idx] coordinate];
        MKMapPoint mapPoint = MKMapPointForCoordinate(point);
        if (mapPoint.x < minX) minX = mapPoint.x;
        if (mapPoint.x > maxX) maxX = mapPoint.x;
        if (mapPoint.y < minY) minY = mapPoint.y;
        if (mapPoint.y > maxY) maxY = mapPoint.y;
    }

    MKMapRect boundingMapRect = MKMapRectMake(minX, minY, maxX - minX, maxY - minY);

    return boundingMapRect;
}
