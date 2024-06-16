//
//  VICacheConfiguration.h
//  VIMediaCacheDemo
//
//  Created by Vito on 4/21/16.
//  Copyright © 2016 Vito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VIContentInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface VICacheConfiguration : NSObject <NSCopying>

+ (NSURL *)configurationFileURLForFileURL:(NSURL *)fileURL;

+ (instancetype)configurationWithFileURL:(NSURL *)fileURL;

@property (nonatomic, copy, readonly) NSURL *fileURL;
@property (nonatomic, strong) VIContentInfo *contentInfo;
@property (nonatomic, strong) NSURL *url;

- (NSArray<NSValue *> *)cacheFragments;

/**
 *  cached progress
 */
@property (nonatomic, readonly) float progress;
@property (nonatomic, readonly) long long downloadedBytes;
@property (nonatomic, readonly) float downloadSpeed; // kb/s

#pragma mark - update API

- (void)save;
- (void)addCacheFragment:(NSRange)fragment;

/**
 *  Record the download speed
 */
- (void)addDownloadedBytes:(long long)bytes spent:(NSTimeInterval)time;

@end

@interface VICacheConfiguration (VIConvenient)

+ (BOOL)createAndSaveDownloadedConfigurationForURL:(NSURL *)url error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
