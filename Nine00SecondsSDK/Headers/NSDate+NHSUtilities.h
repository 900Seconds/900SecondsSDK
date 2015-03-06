//
//  NSDate+DVGUtilities.h
//  NineHundredSeconds
//
//  Created by Nikolay Morev on 09.10.14.
//  Copyright (c) 2014 DENIVIP Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (NHSUtilities)

+ (instancetype)dateWithISO8601String:(NSString *)string;
- (NSString *)ISO8601String;

@end
