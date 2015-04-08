//
//  NSDate+DVGUtilities.h
//  Nine00SecondsSDK
//
//  Created by Nikolay Morev on 09.10.14.
//  Copyright (c) 2014 900 Seconds Oy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (NHSUtilities)

+ (instancetype)dateWithISO8601String:(NSString *)string;
- (NSString *)ISO8601String;

@end
