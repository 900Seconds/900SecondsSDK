//
//  DVGClusterAnnotationView.m
//  NineHundredSeconds
//
//  Created by Nikolay Morev on 19.12.14.
//  Copyright (c) 2014 DENIVIP Group. All rights reserved.
//

#import "DVGClusterAnnotationView.h"
#import <kingpin/KPAnnotation.h>

@interface DVGClusterAnnotationView ()

@property (nonatomic, weak) UILabel *countLabel;

@end

@implementation DVGClusterAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    CGRect rect = CGRectMake(0.f, 0.f, 45.f, 45.f);

    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier frame:rect]) {
        UILabel *countLabel = [[UILabel alloc] initWithFrame:self.innerRect];
        countLabel.textAlignment = NSTextAlignmentCenter;
        countLabel.textColor = [UIColor whiteColor];
        [self addSubview:countLabel];
        _countLabel = countLabel;

        self.frame = rect;
    }
    return self;
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

- (void)setAnnotation:(id<MKAnnotation>)annotation
{
    [super setAnnotation:annotation];

    KPAnnotation *kingpin = (id)annotation;
    self.countLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)kingpin.annotations.count];
}

@end
