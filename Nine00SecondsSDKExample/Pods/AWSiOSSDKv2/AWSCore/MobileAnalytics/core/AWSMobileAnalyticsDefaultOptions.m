/*
 * Copyright 2010-2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import "AWSMobileAnalyticsDefaultOptions.h"

@implementation AWSMobileAnalyticsDefaultOptions
+(AWSMobileAnalyticsDefaultOptions*) optionsWithAllowEventCollection:(BOOL)allowEventCollection
                                          withWANDelivery:(BOOL)allowWANDelivery
{
    return [[AWSMobileAnalyticsDefaultOptions alloc] initWithAllowEventCollection:allowEventCollection
                                                       withWANDelivery:allowWANDelivery];
}

-(id)initWithAllowEventCollection:(BOOL)allowEventCollection
                  withWANDelivery:(BOOL)allowWANDelivery
{
    if(self = [super init])
    {
        _allowEventCollection = allowEventCollection;
        _allowWANDelivery = allowWANDelivery;
    }
    return self;
}


@end
