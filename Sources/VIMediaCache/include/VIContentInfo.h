//
//  VIContentInfo.h
//  VIMediaCacheDemo
//
//  Created by Vito on 4/21/16.
//  Copyright © 2016 Vito. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VIContentInfo : NSObject <NSCoding>

@property (nonatomic, copy, nullable) NSString *contentType;
@property (nonatomic, assign) unsigned long long contentLength;
@property (nonatomic, assign) BOOL byteRangeAccessSupported;
@property (nonatomic) unsigned long long downloadedContentLength;

@end

NS_ASSUME_NONNULL_END
