//
//  VIMediaCacheDemoTests.swift
//  VIMediaCacheDemoTests
//
//  Created by Sereivoan Yong on 6/16/24.
//

import XCTest
import VIMediaCache

final class VIMediaCacheDemoTests: XCTestCase {

  func testConfiguration1() throws {
    let configuration = VICacheConfiguration()
    let range1 = NSRange(location: 10, length: 10)
    configuration.addCacheFragment(range1)
    var fragments = configuration.cacheFragments()
    XCTAssert(fragments.count == 1 && NSEqualRanges(fragments[0].rangeValue, range1), "add (10, 10) to [], should equal [(10, 10)]")

    configuration.addCacheFragment(range1)
    fragments = configuration.cacheFragments()
    XCTAssert(fragments.count == 1 && NSEqualRanges(fragments[0].rangeValue, range1) , "add (10, 10) to [(10, 10)], should equal [(10, 10)]")

    let range0 = NSRange(location: 5, length: 1)
    configuration.addCacheFragment(range0)
    fragments = configuration.cacheFragments()
    XCTAssert(fragments.count == 2 && NSEqualRanges(fragments[0].rangeValue, range0) && NSEqualRanges(fragments[1].rangeValue, range1), "add (5, 1) to [(10, 10)], should equal [(5, 1), (10, 10)]")

    let range3 = NSRange(location: 1, length: 1)
    configuration.addCacheFragment(range3)
    fragments = configuration.cacheFragments()
    XCTAssert(fragments.count == 3 &&
              NSEqualRanges(fragments[0].rangeValue, range3) &&
              NSEqualRanges(fragments[1].rangeValue, range0) &&
              NSEqualRanges(fragments[2].rangeValue, range1),
              "add (1, 1) to [(5, 1), (10, 10)], should equal [(1, 1), (5, 1), (10, 10)]")

    let range4 = NSRange(location: 0, length: 9)
    configuration.addCacheFragment(range4)
    fragments = configuration.cacheFragments()
    XCTAssert(fragments.count == 2 &&
              NSEqualRanges(fragments[0].rangeValue, NSRange(location: 0, length: 9)) &&
              NSEqualRanges(fragments[1].rangeValue, range1),
              "add (0, 9) to [(1, 1), (5, 1), (10, 10)], should equal [(0, 9), (10, 10)]")
  }

  func testConfiguration2() throws {
    let configuration = VICacheConfiguration()
    let range1 = NSRange(location: 10, length: 10)
    configuration.addCacheFragment(range1)
    var fragments = configuration.cacheFragments()
    XCTAssert(fragments.count == 1 && NSEqualRanges(fragments[0].rangeValue, range1) , "add (10, 10) to [], should equal [(10, 10)]")

    let range2 = NSRange(location: 30, length: 10)
    configuration.addCacheFragment(range2)
    fragments = configuration.cacheFragments()
    XCTAssert(fragments.count == 2 && NSEqualRanges(fragments[0].rangeValue, range1) && NSEqualRanges(fragments[1].rangeValue, range2), "add (30, 10) to [(10, 10)] should equal [(10, 10), (30, 10)]")

    let range3 = NSRange(location: 50, length: 10)
    configuration.addCacheFragment(range3)
    fragments = configuration.cacheFragments()
    XCTAssert(fragments.count == 3 &&
              NSEqualRanges(fragments[0].rangeValue, range1) &&
              NSEqualRanges(fragments[1].rangeValue, range2) &&
              NSEqualRanges(fragments[2].rangeValue, range3),
              "add (50, 10) to [(10, 10), (30, 10)] should equal [(10, 10), (30, 10), (50, 10)]")

    let range4 = NSRange(location: 25, length: 26)
    configuration.addCacheFragment(range4)
    fragments = configuration.cacheFragments()
    XCTAssert(fragments.count == 2 &&
              NSEqualRanges(fragments[0].rangeValue, range1) &&
              NSEqualRanges(fragments[1].rangeValue, NSRange(location: 25, length: 35)),
              "add (25, 26) to [(10, 10), (30, 10), (50, 10)] should equal [(10, 10), (25, 35)]")
  }

//  func testCacheWorker() throws {
//    let cacheWorker = VIMediaCacheWorker(cacheName: "test.mp4")
//
//    NSArray *startOffsets = @[@(50), @(80), @(200), @(708), @(1024), @(1500)];
//    [cacheWorker setCacheResponse:nil];
//
//    if (!cacheWorker.cachedResponse) {
//      NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"testUrl"]
//                                                                  MIMEType:@"mime"
//                                                     expectedContentLength:2048
//                                                          textEncodingName:nil];
//      [cacheWorker setCacheResponse:response];
//
//
//      for (NSNumber *offset in startOffsets) {
//        NSString *str = @"ddddddddddddddddddddddddddddddddddddddddd"; // 42
//        const char *utfStr = [str UTF8String];
//        NSData *data = [NSData dataWithBytes:utfStr length:strlen(utfStr) + 1];
//        [cacheWorker cacheData:data forRange:NSRange(location: offset.integerValue, length: data.length)];
//        [cacheWorker save];
//      }
//    }
//
//    NSRange range = NSRange(location: 0, length: 50);
//    NSArray *cacheDataActions1 = [cacheWorker cachedDataActionsForRange:range];
//    NSArray *expectActions1 = @[
//      [[VICacheAction alloc] initWithActionType:VICacheAtionTypeRemote range:range]
//    ];
//    XCTAssert([cacheDataActions1 isEqualToArray:expectActions1], @"cacheDataActions1 count should equal to %@", expectActions1);
//
//
//    NSRange range2 = NSRange(location: 51, length: 204);
//    NSArray *cacheDataActions2 = [cacheWorker cachedDataActionsForRange:range2];
//    XCTAssert(cacheDataActions2.count == 4, @"actions count should equal startoffsets's count");
//
//    NSRange range3 = NSRange(location: 1300, length: 300);
//    NSArray *cacheDataActions3 = [cacheWorker cachedDataActionsForRange:range3];
//    NSArray *expectActions3 = @[
//      [[VICacheAction alloc] initWithActionType:VICacheAtionTypeRemote range:NSRange(location: 1300, length: 200)],
//      [[VICacheAction alloc] initWithActionType:VICacheAtionTypeLocal range:NSRange(location: 1500, length: 42)],
//      [[VICacheAction alloc] initWithActionType:VICacheAtionTypeRemote range:NSRange(location: 1542, length: 58)]
//    ];
//    XCTAssert([cacheDataActions3 isEqualToArray:expectActions3], @"actions count should equal");
//  }
}
