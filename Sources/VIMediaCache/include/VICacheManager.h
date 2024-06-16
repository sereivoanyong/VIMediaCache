//
//  VICacheManager.h
//  VIMediaCacheDemo
//
//  Created by Vito on 4/21/16.
//  Copyright © 2016 Vito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VICacheConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const VICacheManagerDidUpdateCacheNotification;
extern NSNotificationName const VICacheManagerDidFinishCacheNotification;

typedef NSString *VICacheUserInfoKey;

extern VICacheUserInfoKey const VICacheConfigurationKey;
extern VICacheUserInfoKey const VICacheFinishedErrorKey;

@interface VICacheManager : NSObject

@property (class, nonatomic, copy) NSString *cacheDirectory;


/**
 How often trigger `VICacheManagerDidUpdateCacheNotification` notification

 @param interval Minimum interval
 */
@property (class, nonatomic, assign) NSTimeInterval cacheUpdateNotifyInterval;

@property (class, nonatomic, copy, nullable) NSString *(^fileNameRules)(NSURL *url);

+ (NSString *)cachedFilePathForURL:(NSURL *)url;
+ (VICacheConfiguration *)cacheConfigurationForURL:(NSURL *)url;


/**
 Calculate cached files size

 @param error If error not empty, calculate failed
 @return files size, respresent by `byte`, if error occurs, return -1
 */
+ (unsigned long long)calculateCachedSizeWithError:(NSError **)error;
+ (void)cleanAllCacheWithError:(NSError **)error;
+ (void)cleanCacheForURL:(NSURL *)url error:(NSError **)error;


/**
 Useful when you upload a local file to the server

 @param filePath local file path
 @param url remote resource url
 @param error On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information.
 */
+ (BOOL)addCacheFile:(NSString *)filePath forURL:(NSURL *)url error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
