/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/BackRow.framework/BackRow
 */

//

@class BRMenuItem;

@interface BRMenuItemMediator : NSObject {
@private
	BRMenuItem *_menuItem;	// 4 = 0x4
	SEL _mediaParadeSelector;	// 8 = 0x8
	SEL _menuSelector;	// 12 = 0xc
	id _object;	// 16 = 0x10
}
@property(assign) SEL mediaPreviewSelector;	// G=0x32d8a021; S=0x32d8a001; converted property
@property(assign) SEL menuActionSelector;	// G=0x32d8e86d; S=0x32d89ff1; converted property
@property(readonly, retain) BRMenuItem *menuItem;	// G=0x32d8a011; converted property
@property(readonly, retain) id object;	// G=0x32ddd261; converted property
+ (id)mediatorWithMenuItem:(id)menuItem;	// 0x32ddd2b5
- (id)initWithMenuItem:(id)menuItem;	// 0x32d89fa1
- (void)dealloc;	// 0x32d8c085
// converted property getter: - (SEL)mediaPreviewSelector;	// 0x32d8a021
// converted property getter: - (SEL)menuActionSelector;	// 0x32d8e86d
// converted property getter: - (id)menuItem;	// 0x32d8a011
// converted property getter: - (id)object;	// 0x32ddd261
// converted property setter: - (void)setMediaPreviewSelector:(SEL)selector;	// 0x32d8a001
// converted property setter: - (void)setMenuActionSelector:(SEL)selector;	// 0x32d89ff1
- (void)setMenuActionSelector:(SEL)selector withObject:(id)object;	// 0x32ddd271
@end
