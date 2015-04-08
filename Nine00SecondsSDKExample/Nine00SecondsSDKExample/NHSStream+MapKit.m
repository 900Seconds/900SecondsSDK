//
//  DVGStream+MapKit.m
//  NineHundredSeconds
//
//  Created by Nikolay Morev on 11.11.14.
//  Copyright (c) 2014 900 Seconds Oy. All rights reserved.
//

#import "NHSStream+MapKit.h"

static CLLocationDistance const kDVGStreamOverlayDiameter = 200.0;

@implementation NHSStream (MapKit)

+ (NSDateFormatter *)dvg_dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        dateFormatter.doesRelativeDateFormatting = YES;
    }

    return dateFormatter;
}

- (CLLocationCoordinate2D)coordinate
{
    return self.locationCoordinate;
}

- (MKMapRect)boundingMapRect
{
    CLLocationCoordinate2D centerCoordinate = self.coordinate;
    MKMapPoint mapPoint = MKMapPointForCoordinate(centerCoordinate);
    double pointsPerMeter = MKMapPointsPerMeterAtLatitude(centerCoordinate.latitude);
    double pointsDiameter = pointsPerMeter * kDVGStreamOverlayDiameter;
    return MKMapRectInset(MKMapRectMake(mapPoint.x, mapPoint.y, 0.0, 0.0), -pointsDiameter, -pointsDiameter);
}

- (NSString *)title
{
    return [NSString stringWithFormat:@"%@%@",
            [[[self class] dvg_dateFormatter] stringFromDate:self.createdAt],
            self.live ? @" (LIVE)" : @""];
}

- (NSString *)subtitle
{
    return self.streamID;
}

@end
