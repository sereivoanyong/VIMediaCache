//
//  VICacheManager.m
//  VIMediaCacheDemo
//
//  Created by Vito on 4/21/16.
//  Copyright © 2016 Vito. All rights reserved.
//

#import "VICacheManager.h"
#import "VIMediaDownloader.h"
#import "NSString+VIMD5.h"

NSNotificationName const VICacheManagerDidUpdateCacheNotification = @"VICacheManagerDidUpdateCacheNotification";
NSNotificationName const VICacheManagerDidFinishCacheNotification = @"VICacheManagerDidFinishCacheNotification";

VICacheUserInfoKey const VICacheConfigurationKey = @"VICacheConfigurationKey";
VICacheUserInfoKey const VICacheFinishedErrorKey = @"VICacheFinishedErrorKey";

static NSURL *kMCMediaCacheDirectoryURL;
static NSTimeInterval kMCMediaCacheNotifyInterval;
static NSString *(^kMCFileNameRules)(NSURL *url);

@implementation VICacheManager

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setCacheDirectoryURL:[[NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES] URLByAppendingPathComponent:@"vimedia"]];
        [self setCacheUpdateNotifyInterval:0.1];
    });
}

+ (void)setCacheDirectoryURL:(NSURL *)cacheDirectoryURL {
    kMCMediaCacheDirectoryURL = cacheDirectoryURL;
}

+ (NSURL *)cacheDirectoryURL {
    return kMCMediaCacheDirectoryURL;
}

+ (void)setCacheUpdateNotifyInterval:(NSTimeInterval)interval {
    kMCMediaCacheNotifyInterval = interval;
}

+ (NSTimeInterval)cacheUpdateNotifyInterval {
    return kMCMediaCacheNotifyInterval;
}

+ (NSString *(^)(NSURL *url))fileNameRules {
  return kMCFileNameRules;;
}

+ (void)setFileNameRules:(NSString *(^)(NSURL *url))fileNameRules {
    kMCFileNameRules = fileNameRules;
}

+ (NSURL *)cachedFileURLForURL:(NSURL *)url {
    NSString *pathComponent;
    if (kMCFileNameRules) {
        pathComponent = kMCFileNameRules(url);
    } else {
        pathComponent = [url.absoluteString vi_md5];
        pathComponent = [pathComponent stringByAppendingPathExtension:url.pathExtension];
    }
    return [[self cacheDirectoryURL] URLByAppendingPathComponent:pathComponent];
}

+ (VICacheConfiguration *)cacheConfigurationForURL:(NSURL *)url {
    NSURL *fileURL = [self cachedFileURLForURL:url];
    VICacheConfiguration *configuration = [VICacheConfiguration configurationWithFileURL:fileURL];
    return configuration;
}

+ (unsigned long long)calculateCachedSizeWithError:(NSError **)error {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *cacheDirectoryURL = [self cacheDirectoryURL];
    NSArray<NSURL *> *fileURLs = [fileManager contentsOfDirectoryAtURL:cacheDirectoryURL includingPropertiesForKeys:@[NSURLFileSizeKey] options:0 error:error];
    unsigned long long size = 0;
    if (fileURLs) {
        for (NSURL *fileURL in fileURLs) {
            NSNumber *fileSize;
            [fileURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:NULL];
            if (!fileSize) {
                size = -1;
                break;
            }

            size += fileSize.unsignedLongLongValue;
        }
    }
    return size;
}

+ (void)cleanAllCacheWithError:(NSError **)error {
    // Find downloaing file
    NSMutableSet<NSURL *> *downloadingFiles = [NSMutableSet set];
    [[VIMediaDownloaderStatus sharedInstance].urls enumerateObjectsUsingBlock:^(NSURL *obj, BOOL *stop) {
        NSURL *fileURL = [self cachedFileURLForURL:obj];
        [downloadingFiles addObject:fileURL];
        NSURL *configurationFileURL = [VICacheConfiguration configurationFileURLForFileURL:fileURL];
        [downloadingFiles addObject:configurationFileURL];
    }];
    
    // Remove files
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *cacheDirectoryURL = [self cacheDirectoryURL];

    NSArray<NSURL *> *fileURLs = [fileManager contentsOfDirectoryAtURL:cacheDirectoryURL includingPropertiesForKeys:nil options:0 error:error];
    if (fileURLs) {
        for (NSURL *fileURL in fileURLs) {
            if ([downloadingFiles containsObject:fileURL]) {
                continue;
            }
            if (![fileManager removeItemAtURL:fileURL error:error]) {
                break;
            }
        }
    }
}

+ (void)cleanCacheForURL:(NSURL *)url error:(NSError **)error {
    if ([[VIMediaDownloaderStatus sharedInstance] containsURL:url]) {
        NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Clean cache for url `%@` can't be done, because it's downloading", nil), url];
        if (error) {
            *error = [NSError errorWithDomain:@"com.mediadownload" code:2 userInfo:@{NSLocalizedDescriptionKey: description}];
        }
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *fileURL = [self cachedFileURLForURL:url];

    if ([fileManager fileExistsAtPath:fileURL.path]) {
        if (![fileManager removeItemAtURL:fileURL error:error]) {
            return;
        }
    }
    
    NSURL *configurationFileURL = [VICacheConfiguration configurationFileURLForFileURL:fileURL];
    if ([fileManager fileExistsAtPath:configurationFileURL.path]) {
        if (![fileManager removeItemAtURL:configurationFileURL error:error]) {
            return;
        }
    }
}

+ (BOOL)addCacheFileURL:(NSURL *)fileURL forURL:(NSURL *)url error:(NSError **)error {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *cacheURL = [VICacheManager cachedFileURLForURL:url];
    NSURL *cacheFolderURL = [cacheURL URLByDeletingLastPathComponent];
    if (![fileManager fileExistsAtPath:cacheFolderURL.path]) {
        if (![fileManager createDirectoryAtURL:cacheFolderURL
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:error]) {
            return NO;
        }
    }
    
    if (![fileManager copyItemAtURL:fileURL toURL:cacheURL error:error]) {
        return NO;
    }
    
    if (![VICacheConfiguration createAndSaveDownloadedConfigurationForURL:url error:error]) {
        [fileManager removeItemAtURL:cacheURL error:nil]; // if remove failed, there is nothing we can do.
        return NO;
    }
    
    return YES;
}

@end
