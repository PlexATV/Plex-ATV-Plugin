/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/BackRow.framework/BackRow
 */

//

@class NSMutableDictionary;

@interface BRMappingDictionary : NSObject {
@private
	NSMutableDictionary *_info;	// 4 = 0x4
}
- (id)init;	// 0x32d72809
- (long)count;	// 0x32e1ac1d
- (void)dealloc;	// 0x32e1ac51
- (id)keyEnumerator;	// 0x32d730a1
- (id)objectEnumerator;	// 0x32e1abfd
- (id)objectForKey:(id)key;	// 0x32d72995
- (void)setObject:(id)object forKey:(id)key;	// 0x32d72865
- (void)setValue:(id)value forKey:(id)key;	// 0x32e1ac3d
- (void)setValueTransformer:(id)transformer forKey:(id)key;	// 0x32d72885
- (id)transformedValueForKey:(id)key forObject:(id)object;	// 0x32d73109
- (id)valueForKey:(id)key;	// 0x32d73165
- (id)valueTransformerForKey:(id)key;	// 0x32d73179
@end
