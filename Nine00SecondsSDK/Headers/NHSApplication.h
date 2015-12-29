//
//  NHSApplication.h
//  Nine00SecondsSDK
//
//  Created by Nikolay Morev on 23.12.14.
//  Copyright (c) 2014 900 Seconds Oy. All rights reserved.
//


/**

 Required Frameworks
 1) By GPUImage
 - CoreMedia
 - CoreVideo
 - OpenGLES
 - AVFoundation
 - QuartzCore
 
 2) By FFMPEG
 - libavutil
 - libavdevice
 - libavformat
 - libavcodec
 - libz

 3) By uploading module
 - AWSCore
 - AWSS3
 - libsqllite3
 
 SSL reqirements
 See http://stackoverflow.com/questions/31231696/ios-9-ats-ssl-error-with-supporting-server
*/

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
@property (nonatomic, copy, readonly) NSString *nhsApplicationID;

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
 Returns current author ID string. If [NHSApplication loginWithAuthorID:] was called, this property returns passed authorID. Otherwise it returns anonymous authorID which is generated UUID.
 */
@property (nonatomic, readonly) NSString *currentAuthorID;

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

/**
 Call this method to manually set author ID of current user.
 */
- (void)loginWithAuthorID:(NSString *)authorID;

/**
 This method sets the authorID to _nil_. Next time when the property _currentAuthorID_ will be called - it'll generate new authorID on return.
 */
- (void)logout;

@end
