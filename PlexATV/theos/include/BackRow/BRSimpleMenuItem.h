/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/BackRow.framework/BackRow
 */

//

@class NSString;

@interface BRSimpleMenuItem : NSObject {
@private
	NSString *_title;	// 4 = 0x4
	NSString *_rightJustifiedText;	// 8 = 0x8
	int _titlePosition;	// 12 = 0xc
	int _menuItemType;	// 16 = 0x10
}
@property(readonly, assign) int menuItemType;	// G=0x32da1619; converted property
@property(readonly, retain) NSString *rightJustifiedText;	// G=0x32da15f9; converted property
@property(readonly, retain) NSString *title;	// G=0x32da15e9; converted property
@property(readonly, assign) int titlePosition;	// G=0x32da1609; converted property
+ (id)simpleMenuItemWithTitle:(id)title rightJustifiedText:(id)text titlePosition:(int)position menuItemType:(int)type;	// 0x32da164d
+ (id)simpleMenuItemWithTitle:(id)title titlePosition:(int)position menuItemType:(int)type;	// 0x32da169d
- (id)initWithTitle:(id)title rightJustifiedText:(id)text titlePosition:(int)position menuItemType:(int)type;	// 0x32da1749
- (id)initWithTitle:(id)title titlePosition:(int)position menuItemType:(int)type;	// 0x32da1629
- (void)dealloc;	// 0x32da16ed
// converted property getter: - (int)menuItemType;	// 0x32da1619
// converted property getter: - (id)rightJustifiedText;	// 0x32da15f9
// converted property getter: - (id)title;	// 0x32da15e9
// converted property getter: - (int)titlePosition;	// 0x32da1609
@end
