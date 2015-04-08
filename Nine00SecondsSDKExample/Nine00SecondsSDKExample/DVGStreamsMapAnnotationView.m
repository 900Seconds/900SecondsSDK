//
//  DVGStreamsMapAnnotationView.m
//  NineHundredSeconds
//
//  Created by Nikolay Morev on 19.12.14.
//  Copyright (c) 2014 900 Seconds Oy. All rights reserved.
//

#import "DVGStreamsMapAnnotationView.h"

@interface DVGStreamsMapAnnotationView ()

@property (nonatomic, weak) CAShapeLayer *borderCircle;
@property (nonatomic, weak) CAShapeLayer *fillCircle;

@end

@implementation DVGStreamsMapAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation
                   reuseIdentifier:(NSString *)reuseIdentifier
                             frame:(CGRect)rect
{
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        CAShapeLayer *borderCircle = [CAShapeLayer layer];
        borderCircle.fillColor = [[self class] borderColorWithIntensity:0.f].CGColor;
        borderCircle.strokeColor = [UIColor colorWithHue:0.f saturation:0.f brightness:1.f alpha:0.5f].CGColor;
        borderCircle.lineWidth = 1.f;
        borderCircle.path = [UIBezierPath bezierPathWithOvalInRect:rect].CGPath;
        [self.layer addSublayer:borderCircle];
        _borderCircle = borderCircle;

        CGRect innerRect = CGRectInset(rect, 4.f, 4.f);
        CAShapeLayer *fillCircle = [CAShapeLayer layer];
        fillCircle.fillColor = [[self class] fillColorWithIntensity:0.f].CGColor;
        fillCircle.path = [UIBezierPath bezierPathWithOvalInRect:innerRect].CGPath;
        fillCircle.strokeColor = [UIColor colorWithHue:0.f saturation:0.f brightness:1.f alpha:0.5f].CGColor;
        fillCircle.lineWidth = 1.f;
        [self.layer addSublayer:fillCircle];
        _fillCircle = fillCircle;

        _innerRect = innerRect;
    }
    return self;
}

+ (UIColor *)borderColorWithIntensity:(CGFloat)intensity
{
    return [UIColor colorWithHue:159.f/360 saturation:(1.f - 0.86f) + 0.86f * intensity brightness:0.85f alpha:1.f];
}

+ (UIColor *)fillColorWithIntensity:(CGFloat)intensity
{
    return [UIColor colorWithHue:355.f/360 saturation:(1.f - 0.77f) + 0.77f * intensity brightness:0.86f alpha:1.f];
}

- (CAAnimation *)blinkingAnimationWithIntensity:(CGFloat)intensity
{
    NSArray *keyTimes = @[ @(0.0), @(0.5), @(1.0) ];

    CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scale.values = @[ @(1.0), @(1.2), @(1.0) ];
    scale.keyTimes = keyTimes;

    CAKeyframeAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacity.values = @[ @(0.75), @(1.0), @(0.75) ];
    opacity.keyTimes = keyTimes;

    CAAnimationGroup *anim = [CAAnimationGroup animation];
    anim.animations = @[ scale, opacity ];
    anim.duration = 0.2 / (intensity ?: 0.0001);
    anim.repeatCount = HUGE_VALF;
    anim.fillMode = kCAFillModeBoth;

    return anim;
}

- (void)setPopularity:(float)popularity
{
    _popularity = MAX(0.f, MIN(1.f, popularity));
    self.fillCircle.fillColor = [[self class] fillColorWithIntensity:_popularity].CGColor;
}

- (void)setAge:(float)age
{
    if (_age != age) {
        _age = MAX(0.f, MIN(1.f, age));

        [self.layer removeAnimationForKey:@"blinking"];
        self.borderCircle.fillColor = [[self class] borderColorWithIntensity:_age].CGColor;

        [self.layer addAnimation:[self blinkingAnimationWithIntensity:_age] forKey:@"blinking"];
    }
}

@end
