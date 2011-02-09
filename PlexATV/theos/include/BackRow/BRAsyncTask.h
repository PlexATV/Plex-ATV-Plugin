/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/BackRow.framework/BackRow
 */

//

@class BRAsyncTaskContext, NSThread, NSString;

@interface BRAsyncTask : NSObject {
@private
	NSThread *_callingThread;	// 4 = 0x4
	id _target;	// 8 = 0x8
	SEL _selector;	// 12 = 0xc
	id _object;	// 16 = 0x10
	id _result;	// 20 = 0x14
	BRAsyncTaskContext *_context;	// 24 = 0x18
	int _state;	// 28 = 0x1c
	NSString *_identifier;	// 32 = 0x20
}
@property(readonly, retain) NSThread *callingThread;	// G=0x32d81359; converted property
@property(readonly, retain) BRAsyncTaskContext *context;	// G=0x32e10069; converted property
@property(retain) NSString *identifier;	// G=0x32e10079; S=0x32e10099; converted property
@property(readonly, retain) id object;	// G=0x32e10059; converted property
@property(readonly, retain) id result;	// G=0x32d83749; converted property
@property(readonly, assign) SEL selector;	// G=0x32e10039; converted property
@property(assign) int state;	// G=0x32d81ab9; S=0x32e10089; converted property
@property(readonly, retain) id target;	// G=0x32e10049; converted property
+ (void)initialize;	// 0x32d8102d
+ (id)taskWithSelector:(SEL)selector onTarget:(id)target withObject:(id)object;	// 0x32d81081
+ (id)taskWithSelector:(SEL)selector onTarget:(id)target withObject:(id)object withContext:(id)context;	// 0x32d810b5
+ (id)voidReturnValue;	// 0x32e1002d
- (id)_initWithSelector:(SEL)selector onTarget:(id)target withObject:(id)object withContext:(id)context;	// 0x32d81109
// converted property getter: - (id)callingThread;	// 0x32d81359
- (void)cancel;	// 0x32e100d1
// converted property getter: - (id)context;	// 0x32e10069
- (void)dealloc;	// 0x32d83829
- (id)description;	// 0x32e10101
// converted property getter: - (id)identifier;	// 0x32e10079
- (id)invoke;	// 0x32d81ac9
// converted property getter: - (id)object;	// 0x32e10059
// converted property getter: - (id)result;	// 0x32d83749
- (void)run;	// 0x32d811c1
// converted property getter: - (SEL)selector;	// 0x32e10039
// converted property setter: - (void)setIdentifier:(id)identifier;	// 0x32e10099
// converted property setter: - (void)setState:(int)state;	// 0x32e10089
// converted property getter: - (int)state;	// 0x32d81ab9
// converted property getter: - (id)target;	// 0x32e10049
@end
