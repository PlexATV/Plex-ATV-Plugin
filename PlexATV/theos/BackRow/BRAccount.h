/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/BackRow.framework/BackRow
 */

//#import "NSCoding.h"
//

@class NSString, NSMutableDictionary;

@interface BRAccount : NSObject <NSCoding> {
@private
	int _version;	// 4 = 0x4
	NSString *_assignedGUID;	// 8 = 0x8
	NSString *_accountName;	// 12 = 0xc
	NSString *_password;	// 16 = 0x10
	NSMutableDictionary *_metadata;	// 20 = 0x14
	BOOL _automaticAuthentication;	// 24 = 0x18
	BOOL _accountOptionsSet;	// 25 = 0x19
	BOOL _isSystemAccount;	// 26 = 0x1a
	int _currentMode;	// 28 = 0x1c
	int _challengeMode;	// 32 = 0x20
}
@property(retain) NSString *accountName;	// G=0x32d6a33d; S=0x32e01bfd; converted property
@property(readonly, assign) BOOL accountOptionsSet;	// G=0x32e01759; converted property
@property(assign) int challengeMode;	// G=0x32e01779; S=0x32e01789; @synthesize=_challengeMode
@property(assign) int currentMode;	// G=0x32e01799; S=0x32e017a9; @synthesize=_currentMode
@property(retain) NSString *password;	// G=0x32d6a425; S=0x32e01af5; converted property
+ (id)generateRequest:(id)request headers:(id)headers method:(id)method;	// 0x32e01a71
- (id)initWithAccountName:(id)accountName;	// 0x32e01985
- (id)initWithCoder:(id)coder;	// 0x32d5cdc5
- (id)_accountQuery;	// 0x32e017c1
- (id)_assignedGUID;	// 0x32d6aff1
- (id)_decryptPassword:(id)password;	// 0x32e017bd
- (id)_encryptPassword:(id)password;	// 0x32e017b9
- (BOOL)_isSystemAccount;	// 0x32d5d191
// converted property getter: - (id)accountName;	// 0x32d6a33d
// converted property getter: - (BOOL)accountOptionsSet;	// 0x32e01759
- (BOOL)allowAutomaticAuthentication;	// 0x32d6b001
- (void)authenticate;	// 0x32e018bd
// declared property getter: - (int)challengeMode;	// 0x32e01779
// declared property getter: - (int)currentMode;	// 0x32e01799
- (void)dealloc;	// 0x32e01905
- (void)encodeWithCoder:(id)coder;	// 0x32d6da41
- (BOOL)isAuthenticated;	// 0x32e01741
- (BOOL)isPasswordRequired;	// 0x32e01745
- (void)markAccountOptionsAsSet;	// 0x32e01769
- (void)markAsDirty;	// 0x32d6d865
- (id)metadataValueForKey:(id)key;	// 0x32d6a435
// converted property getter: - (id)password;	// 0x32d6a425
- (void)resetAccountOptions;	// 0x32e01845
// converted property setter: - (void)setAccountName:(id)name;	// 0x32e01bfd
- (void)setAutomaticAuthentication:(BOOL)authentication;	// 0x32e01749
// declared property setter: - (void)setChallengeMode:(int)mode;	// 0x32e01789
// declared property setter: - (void)setCurrentMode:(int)mode;	// 0x32e017a9
- (void)setMetadataValue:(id)value forKey:(id)key;	// 0x32d6d7b9
// converted property setter: - (void)setPassword:(id)password;	// 0x32e01af5
- (BOOL)shouldAskForPassword:(int)password;	// 0x32e0187d
- (id)type;	// 0x32e018e5
- (void)willBeDeleted;	// 0x32e01cc9
@end
