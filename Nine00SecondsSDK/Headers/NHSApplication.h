//
//  NHSApplication.h
//  Nine00SecondsSDK
//
//  Created by Nikolay Morev on 23.12.14.
//  Copyright (c) 2014 900 Seconds Oy. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 NHSApplicationStorageType is a type of remote file storage. Currently only AWS S3 file storage is in use.
 */
typedef NS_ENUM(NSUInteger, NHSApplicationStorageType) {
/**
 File storage type is undefined
 */
    NHSApplicationStorageTypeUndefined = 0,
/**
 File storage is AWS S3.
 */
    NHSApplicationStorageTypeS3,
};

extern NSString *const NHSApplicationStorageCredentialsBucketKey;
extern NSString *const NHSApplicationStorageCredentialsAccessKey;
extern NSString *const NHSApplicationStorageCredentialsSecretKey;
extern NSString *const NHSApplicationStorageRegionKey;

/**
 An instance of NHSApplication is mainly used inside the SDK as an object that holds file storage credentials. Normally developers don't need to create objects of this class by themselves. NHSBroadcastManager creates and retains an object filled with proper credentials after performing authentication.
 */
@interface NHSApplication : NSObject

/**
 The application ID as it was registered on server.
 */
@property (nonatomic, copy, readonly) NSString *applicationID;

/**
 Name of the application as it was registered on server.
 */
@property (nonatomic, copy) NSString *name;

/**
 Type of the remote file storage for this application.
 */
@property (nonatomic) NHSApplicationStorageType storageType;

/**
 Credentials which SDK has to use to upload video chunks to file storage. Normally the credentials shouldn't be set directly. Instead of this a [NHSBroadcastManager registerAppID:withSecret:withCompletion:] method should be called. Completion of that method will create NHSApplication instance with all required credentials filled in.
 To access credentials values developers should use *NHSApplicationStorageCredentials* keyes.
 */
@property (nonatomic) NSDictionary *storageCredentials;

/**
 Creates NHSApplication instance with application ID.
 
 @param applicationID The current application's appID.
 */
- (instancetype)initWithApplicationID:(NSString *)applicationID;

/**
 Creates NHSApplication instance with dictionary of values to set.
 
 @param dictionary A key-value table of values that should be set on a new NHSApplication instance.
 */
+ (instancetype)applicationWithDictionary:(NSDictionary *)dictionary;

@end
