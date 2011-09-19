//
//  HWUserDefaults.h
//  atvTwo
//
//  Created by ccjensen on 24/01/2011.
//

#import <Foundation/Foundation.h>

@interface HWUserDefaults : PlexPrefs {}

+ (SMFPreferences*)preferences;
+ (void)setupPlexClient;
+ (NSDictionary*)defaultValues;
+ (NSArray*)plexStreamingQualities;

+ (NSInteger)lastTabBarSelectionForViewGroup:(NSString*)viewGroup;
+ (void)setLastTabBarSelection:(NSInteger)selectedIndex forViewGroup:(NSString*)viewGroup;

//plex prefs methods
- (void)syncSettings;

- (void)_setDefaults;

- (void)removeValueForKey:(NSString*)key;

- (id)objectForKey:(NSString*)key;
- (void)setObject:(id)value forKey:(NSString*)key;

- (id)objectForKey:(NSString*)key;
- (void)setObject:(id)obj forKey:(NSString*)key;

- (NSInteger)integerForKey:(NSString*)key;
- (void)setInteger:(NSInteger)v forKey:(NSString*)key;

- (BOOL)boolForKey:(NSString*)key;
- (void)setBool:(BOOL)value forKey:(NSString*)key;

- (double)doubleForKey:(NSString*)key;
- (void)setDouble:(double)value forKey:(NSString*)key;

- (float)floatForKey:(NSString*)key;
- (void)setFloat:(float)value forKey:(NSString*)key;

@end
