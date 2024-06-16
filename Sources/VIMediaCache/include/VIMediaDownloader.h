//
//  VIMediaDownloader.h
//  VIMediaCacheDemo
//
//  Created by Vito on 4/21/16.
//  Copyright © 2016 Vito. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol VIMediaDownloaderDelegate;
@class VIContentInfo;
@class VIMediaCacheWorker;

@interface VIMediaDownloaderStatus : NSObject

@property (class, nonatomic, strong, readonly) VIMediaDownloaderStatus *sharedInstance;

- (void)addURL:(NSURL *)url;
- (void)removeURL:(NSURL *)url;

/**
 return YES if downloading the url source
 */
- (BOOL)containsURL:(NSURL *)url;
@property (nonatomic, copy, readonly) NSSet<NSURL *> *urls;

@end

@interface VIMediaDownloader : NSObject

- (instancetype)initWithURL:(NSURL *)url cacheWorker:(VIMediaCacheWorker *)cacheWorker;
@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, weak, nullable) id<VIMediaDownloaderDelegate> delegate;
@property (nonatomic, strong) VIContentInfo *info;
@property (nonatomic, assign) BOOL saveToCache;

- (void)downloadTaskFromOffset:(long long)fromOffset
                        length:(NSUInteger)length
                         toEnd:(BOOL)toEnd;
- (void)downloadFromStartToEnd;

- (void)cancel;

@end

@protocol VIMediaDownloaderDelegate <NSObject>

@optional
- (void)mediaDownloader:(VIMediaDownloader *)downloader didReceiveResponse:(NSURLResponse *)response;
- (void)mediaDownloader:(VIMediaDownloader *)downloader didReceiveData:(NSData *)data;
- (void)mediaDownloader:(VIMediaDownloader *)downloader didFinishedWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
