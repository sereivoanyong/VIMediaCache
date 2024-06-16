//
//  VIResourceLoaderManager.h
//  VIMediaCacheDemo
//
//  Created by Vito on 4/21/16.
//  Copyright © 2016 Vito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol VIResourceLoaderManagerDelegate;

@interface VIResourceLoaderManager : NSObject <AVAssetResourceLoaderDelegate>


@property (nonatomic, weak, nullable) id<VIResourceLoaderManagerDelegate> delegate;

/**
 Normally you no need to call this method to clean cache. Cache cleaned after AVPlayer delloc.
 If you have a singleton AVPlayer then you need call this method to clean cache at suitable time.
 */
- (void)cleanCache;

/**
 Cancel all downloading loaders.
 */
- (void)cancelLoaders;

@end

@protocol VIResourceLoaderManagerDelegate <NSObject>

- (void)resourceLoaderManagerLoadURL:(NSURL *)url didFailWithError:(NSError *)error;

@end

@interface VIResourceLoaderManager (Convenient)

+ (NSURL *)assetURLWithURL:(NSURL *)url;
- (AVURLAsset *)URLAssetWithURL:(NSURL *)url options:(nullable NSDictionary<NSString *, id> *)options;
- (AVPlayerItem *)playerItemWithURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
