/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/BackRow.framework/BackRow
 */

#import "BRControlHeightFactory.h"
#import "BRControlFactory.h"
//


@interface BRMediaObjectControlFactory : NSObject <BRControlFactory, BRControlHeightFactory> {
}
+ (id)factory;	// 0x32da83e1
- (id)controlForData:(id)data currentControl:(id)control requestedBy:(id)by;	// 0x32da8411
- (float)heightForControlForData:(id)data requestedBy:(id)by;	// 0x32da8329
@end
