/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/BackRow.framework/BackRow
 */

#import "BRProvider.h"

@class NSArray;

@interface BRImageProxyProvider : NSObject <BRProvider> {
@private
	NSArray *_images;	// 4 = 0x4
}
+ (id)providerWithAssets:(id)assets;	// 0x32d9eb61
+ (id)providerWithImageProxies:(id)imageProxies;	// 0x32d9ebe5
- (id)initWithAssets:(id)assets;	// 0x32d9eb11
- (id)initWithImageProxies:(id)imageProxies;	// 0x32d9eb95
- (id)controlFactory;	// 0x32d9e97d
- (id)dataAtIndex:(long)index;	// 0x32d9ea1d
- (long)dataCount;	// 0x32d9eaa9
- (void)dealloc;	// 0x32d9eac9
- (id)hashForDataAtIndex:(long)index;	// 0x32d9e981
@end
