//
//  DVGStreamOverlayRenderer.m
//  NineHundredSeconds
//
//  Created by Nikolay Morev on 12.11.14.
//  Copyright (c) 2014 DENIVIP Group. All rights reserved.
//

#import "DVGStreamOverlayRenderer.h"

@implementation DVGStreamOverlayRenderer

+ (UIColor *)fillColorWithIntensity:(CGFloat)intensity
{
    return [UIColor colorWithHue:355.f/360 saturation:0.77f * intensity brightness:0.86f alpha:1.f];
}

- (void)setPopularity:(float)popularity
{
    _popularity = MAX(0.f, MIN(1.f, popularity));
    [self setNeedsDisplay];
}

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{
#if 0 // рисуем mapRect-ы
    CGContextSetStrokeColorWithColor(context, [[UIColor redColor] colorWithAlphaComponent:0.6f].CGColor);
    CGContextSetLineWidth(context, 2.f / zoomScale);
    CGRect rect = [self rectForMapRect:mapRect];
    CGContextStrokeRect(context, rect);
#endif

    CGRect overlayRect = [self rectForMapRect:[self.overlay boundingMapRect]];
// CGContextAddEllipseInRect(context, overlayRect);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSArray *gradientColors = @[ (id)[[self class] fillColorWithIntensity:self.popularity].CGColor,
                                 (id)[UIColor colorWithHue:0.f saturation:0.f brightness:1.f alpha:0.f].CGColor ];
    CGFloat gradientLocations[2] = { 0.0, 1.0 };
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)gradientColors, gradientLocations);

    CGPoint overlayCenter = CGPointMake(CGRectGetMidX(overlayRect), CGRectGetMidY(overlayRect));
    CGFloat overlayRadius = CGRectGetWidth(overlayRect) / 2;
    CGContextDrawRadialGradient(context, gradient, overlayCenter, 0.f, overlayCenter, overlayRadius, 0);

    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}

@end
