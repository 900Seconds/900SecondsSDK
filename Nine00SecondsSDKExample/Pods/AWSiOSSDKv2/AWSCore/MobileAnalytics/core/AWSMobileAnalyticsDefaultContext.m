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

#import "AWSMobileAnalyticsContext.h"
#import "AWSMobileAnalyticsDefaultContext.h"
#import "AWSMobileAnalyticsUniqueIdService.h"
#import "AWSMobileAnalyticsIOSSystem.h"
#import "AWSMobileAnalyticsPrefsUniqueIdService.h"
#import "AWSMobileAnalyticsHttpCachingConfiguration.h"
#import "AWSMobileAnalyticsJSONSerializer.h"
#import "AWSMobileAnalyticsDefaultDeliveryClient.h"
#import "AWSMobileAnalyticsIOSLifeCycleManager.h"
#import "AWSMobileAnalyticsIOSClientContext.h"
#import "AWSMobileAnalyticsConfiguration.h"
#import "AWSMobileAnalyticsIOSClientContext.h"
#import "AWSMobileAnalyticsConfiguration.h"

@interface AWSMobileAnalyticsDefaultContext()

@property(nonatomic) id<AWSMobileAnalyticsUniqueIdService> uniqueIdService;

@end

@implementation AWSMobileAnalyticsDefaultContext

+ (id<AWSMobileAnalyticsContext>) contextWithIdentifier:(NSString*) theIdentifier
                                            withSdkInfo:(AWSMobileAnalyticsSDKInfo*)sdkInfo
                              withConfigurationSettings:(NSDictionary*)settings {
    return [AWSMobileAnalyticsDefaultContext contextWithIdentifier:theIdentifier
                                           withClientConfiguration:[AWSMobileAnalyticsConfiguration new]
                                                       withSdkInfo:sdkInfo
                                         withConfigurationSettings:settings];
}

+ (id<AWSMobileAnalyticsContext>) contextWithIdentifier:(NSString*) theIdentifier
                                withClientConfiguration:(AWSMobileAnalyticsConfiguration *)clientConfiguration
                                            withSdkInfo:(AWSMobileAnalyticsSDKInfo*)sdkInfo
                              withConfigurationSettings:(NSDictionary*)settings {
    return [[AWSMobileAnalyticsDefaultContext alloc] initWithIdentifier:theIdentifier
                                                withClientConfiguration:clientConfiguration
                                                            withSdkInfo:sdkInfo
                                              withConfigurationSettings:settings];
}

- (id<AWSMobileAnalyticsContext>) initWithIdentifier:(NSString*) theIdentifier
                             withClientConfiguration:(AWSMobileAnalyticsConfiguration *)clientConfiguration
                                         withSdkInfo:(AWSMobileAnalyticsSDKInfo*)sdkInfo
                           withConfigurationSettings:(NSDictionary*)settings {
    if (self = [super init]) {
        _identifier = theIdentifier;


        _sdkInfo = sdkInfo;

        _system = [[AWSMobileAnalyticsIOSSystem alloc] initWithIdentifier:theIdentifier];

        _uniqueIdService = [AWSMobileAnalyticsPrefsUniqueIdService idService];
        _uniqueId = [self.uniqueIdService getUniqueIdWithContext:self]; // TODO: this may need to be broken up since self is not fully instantiated yet

        // now that we have the id, create the client context from the client configuration that
        // was passed in
        AWSMobileAnalyticsEnvironment *environment = clientConfiguration.environment;
        _clientContext = [AWSMobileAnalyticsIOSClientContext clientContextWithAppVersion:environment.appVersion
                                                                            withAppBuild:environment.appBuild
                                                                      withAppPackageName:environment.appPackageName
                                                                             withAppName:environment.appName
                                                                    withCustomAttributes:clientConfiguration.attributes
                                                                               withAppId:theIdentifier];

        _httpClient = [[AWSMobileAnalyticsDefaultHttpClient alloc] init];
		[_httpClient addInterceptor:[[AWSMobileAnalyticsSDKInfoInterceptor alloc] initWithSDKInfo:_sdkInfo]];
        [_httpClient addInterceptor:[[AWSMobileAnalyticsInstanceIdInterceptor alloc] initWithInstanceId:_uniqueId]];
        [_httpClient addInterceptor:[AWSMobileAnalyticsClientContextInterceptor contextInterceptorWithClientContext:_clientContext]];

        [_httpClient addInterceptor:[[AWSMobileAnalyticsLogInterceptor alloc] init]];

        NSOperationQueue* queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:1];


        _configuration = [AWSMobileAnalyticsHttpCachingConfiguration configurationWithContext:self
                                                                              withFileManager:_system.fileManager
                                                                         withOverrideSettings:settings
                                                                           withOperationQueue:queue];
    }
    return self;
}

- (void)synchronize {
    _uniqueId = [self.uniqueIdService getUniqueIdWithContext:self];
    [_configuration refresh];
}

@end
