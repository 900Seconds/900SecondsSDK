//
//  DVGStreamAnnotationView.m
//  NineHundredSeconds
//
//  Created by Nikolay Morev on 12.11.14.
//  Copyright (c) 2014 DENIVIP Group. All rights reserved.
//

#import "DVGStreamAnnotationView.h"

@interface UIBezierPath (DVGUtilities)

+ (UIBezierPath *)dvg_equilateralTriangleInRect:(CGRect)rect;

@end

@interface DVGStreamAnnotationView ()

@property (nonatomic, weak) CAShapeLayer *triangle;

@end

@implementation DVGStreamAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    CGRect rect = CGRectMake(0.f, 0.f, 30.f, 30.f);
    
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier frame:rect]) {
        CGRect triRect = CGRectInset(self.innerRect, 4.f, 4.f);
        CAShapeLayer *triangle = [CAShapeLayer layer];
        triangle.fillColor = [UIColor whiteColor].CGColor;
        triangle.strokeColor = [UIColor colorWithHue:0.f saturation:0.f brightness:1.f alpha:0.5f].CGColor;
        triangle.lineWidth = 1.f;
        triangle.path = [UIBezierPath dvg_equilateralTriangleInRect:triRect].CGPath;
        [self.layer addSublayer:triangle];
        _triangle = triangle;

        self.frame = rect;
    }
    return self;
}

- (CAAnimation *)fillColorAnimation
{
    UIColor * (^fillColor)(CGFloat) = ^UIColor * (CGFloat keyTime) {
        return [UIColor colorWithHue:keyTime saturation:0.8f brightness:1.0f alpha:1.f];
    };

    CAKeyframeAnimation *colorAnimation = [CAKeyframeAnimation animationWithKeyPath:@"fillColor"];
    colorAnimation.values = @[ (id)fillColor(0.0f).CGColor,
                               (id)fillColor(0.1f).CGColor,
                               (id)fillColor(0.2f).CGColor,
                               (id)fillColor(0.3f).CGColor,
                               (id)fillColor(0.4f).CGColor,
                               (id)fillColor(0.5f).CGColor,
                               (id)fillColor(0.6f).CGColor,
                               (id)fillColor(0.7f).CGColor,
                               (id)fillColor(0.8f).CGColor,
                               (id)fillColor(0.9f).CGColor,
                               (id)fillColor(1.0f).CGColor ];
    colorAnimation.keyTimes = @[ @(0.0), @(0.1), @(0.2), @(0.3), @(0.4), @(0.5),
                                 @(0.6), @(0.7), @(0.8), @(0.9), @(1.0) ];
    colorAnimation.duration = 1.0;
    colorAnimation.repeatCount = HUGE_VALF;
    colorAnimation.fillMode = kCAFillModeBoth;

    return colorAnimation;
}

- (void)setBlinking:(BOOL)blinking
{
    if (_blinking != blinking) {
        _blinking = blinking;

        [self.triangle removeAnimationForKey:@"triangle.fillColor"];
        self.triangle.fillColor = [UIColor whiteColor].CGColor;

        if (_blinking) {
            [self.triangle addAnimation:[self fillColorAnimation] forKey:@"triangle.fillColor"];
        }
    }
}

@end

@implementation UIBezierPath (DVGUtilities)

+ (UIBezierPath *)dvg_equilateralTriangleInRect:(CGRect)triRect
{
    CGPoint triCenter = CGPointMake(CGRectGetMidX(triRect), CGRectGetMidY(triRect));
    CGFloat triRadius = CGRectGetWidth(triRect) / 2.f;

    UIBezierPath *triPath = [UIBezierPath bezierPath];
    [triPath moveToPoint:CGPointMake(triCenter.x + triRadius, triCenter.y)];
    [triPath addLineToPoint:CGPointMake(triCenter.x + triRadius * cosf(2.f * M_PI / 3.f), triCenter.y + triRadius * sinf(2.f * M_PI / 3.f))];
    [triPath addLineToPoint:CGPointMake(triCenter.x + triRadius * cosf(4.f * M_PI / 3.f), triCenter.y + triRadius * sinf(4.f * M_PI / 3.f))];
    [triPath closePath];

    return triPath;
}

@end

