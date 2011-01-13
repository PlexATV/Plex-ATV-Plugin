//
//  PlexRequest.h
//  PlexPad
//
//  Created by Frank Bauer on 17.04.10.
//  Copyright 2010 ambertation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Machine.h"
#import "MemoryObject.h"

extern const NSString* plexSectionsKey;
extern const NSString* plexClientsKey;
extern const NSString* plexServersKey;
extern const NSString* plexPhotoKey;
extern const NSString* plexStoreKey;
extern const NSString* plexVideoKey;
extern const NSString* plexMusicKey;

typedef NSInteger PlexStreamingQuality;
extern const PlexStreamingQuality PlexStreamingQualityAuto;
extern const PlexStreamingQuality PlexStreamingQuality3GLow;
extern const PlexStreamingQuality PlexStreamingQuality3GMed;
extern const PlexStreamingQuality PlexStreamingQuality3GHigh;
extern const PlexStreamingQuality PlexStreamingQualityDefault;
extern const PlexStreamingQuality PlexStreamingQualityWiFi;
extern const PlexStreamingQuality PlexStreamingQualityiPhoneWiFi;
extern const PlexStreamingQuality PlexStreamingQuality720p_1500;
extern const PlexStreamingQuality PlexStreamingQuality720p_2300;
extern const PlexStreamingQuality PlexStreamingQuality720p_4000;
extern const PlexStreamingQuality PlexStreamingQuality1080p_5000;
extern const PlexStreamingQuality PlexStreamingQuality1080p_8000;
extern const PlexStreamingQuality PlexStreamingQuality1080p_10000;
extern const PlexStreamingQuality PlexStreamingQuality1080p_14000;
extern const PlexStreamingQuality PlexStreamingQualityMaxiPad;
extern const PlexStreamingQuality PlexStreamingQualityMaxLowResiPhone;
extern const PlexStreamingQuality PlexStreamingQualityMax;


typedef NSString* PlexRemoteControlType;
extern const PlexRemoteControlType PlexRemoteControlTypeApplication;
extern const PlexRemoteControlType PlexRemoteControlTypeNavigation;
extern const PlexRemoteControlType PlexRemoteControlTypePlayback;

extern const NSString* plexClientsKey ;

@class PlexMediaContainer, PlexMediaObject, PlexImage, PlexServer ,PlexDirectory, Machine, LoadURLOperation, Activity;
@protocol NSURLLoadOperationDelegate;
@interface PlexRequest : MemoryObject {
	Activity* activity;
	NSString* base;
	NSString* host;
	int port, localPort;
	NSMutableDictionary* flagCache;
	BOOL transcoderRunning;
	
	PlexServer* serverObject;
	Machine* machine;
}

@property (readwrite, assign) Machine* machine;
@property (readonly) NSString* base;
@property (readwrite) BOOL transcoderRunning;
@property (readonly) PlexServer* serverObject;

-(id) initWithServer:(NSString*)host onPort:(NSUInteger)port;
-(void)rebaseForHost:(NSString*)h port:(NSUInteger)p;

-(PlexMediaContainer*)processXMLData:(LoadURLOperation*)op;
-(PlexMediaContainer*)processXMLData:(NSData*)receivedData baseKey:(NSString*)key object:(PlexMediaObject*)pmo lastSearch:(NSString*)loaded_preset;
-(NSURL*)prepareQueryForKey:(NSString*)key callingObject:(PlexMediaObject*)pmo ignorePresets:(BOOL)ign lastSearch:(NSString**)loaded_preset;
-(LoadURLOperation*)asyncQuery:(NSString*)key callingObject:(PlexMediaObject*)pmo ignorePresets:(BOOL)ign notify:(id<NSURLLoadOperationDelegate>)opDelegate timeout:(NSTimeInterval)t;
-(PlexMediaContainer*) query:(NSString*)key callingObject:(PlexMediaObject*)pmo ignorePresets:(BOOL)ign timeout:(NSTimeInterval)t;
-(PlexStreamingQuality)bestQuality;

-(NSData*)dataForURL:(NSURL*)url authenticateStreaming:(BOOL)auths timeout:(NSTimeInterval)t didTimeout:(BOOL*)didTimeout;
-(NSData*)dataForRequest:(NSMutableURLRequest*)req timeout:(NSTimeInterval)t didTimeout:(BOOL*)didTimeout;
-(void)asyncDataForURL:(NSURL*)url authenticateStreaming:(BOOL)auths notify:(id<NSURLLoadOperationDelegate>)opDelegate timeout:(NSTimeInterval)t;

-(void)sendRemoteControlCommand:(NSString*)cmd type:(PlexRemoteControlType)type toClient:(Machine*)clientOrNil;
-(void)sendRemoteControlURLSendKey:(NSString*)k client:(Machine*)clientOrNil;
-(void)sendRemoteControlURLSendVirtualKey:(NSString*)k client:(Machine*)clientOrNil;
-(void)sendRemoteControlURLSendString:(NSString*)txt client:(Machine*)clientOrNil;
-(NSURL*)remoteControlURL:(NSString*)command type:(PlexRemoteControlType)type parameter:(NSString*)queryOrNil client:(Machine*)clientOrNil;
-(NSURL*)remoteControlURLSendKey:(NSString*)k client:(Machine*)clientOrNil;
-(NSURL*)remoteControlURLSendVirtualKey:(NSString*)k client:(Machine*)clientOrNil;
-(NSURL*)remoteControlURLSendString:(NSString*)txt client:(Machine*)clientOrNil;

-(NSURL*)pathForScaledImage:(NSString*)key ofSize:(CGSize)sz;
-(NSURL*)streamingURL:(NSString*)key mediaContainer:(PlexMediaContainer*)pmc quality:(PlexStreamingQuality)q callingObject:(PlexMediaObject*)pmo;
-(NSURL*)postSeenNotificationRatingKey:(NSString*)rk identifier:(NSString*)ident;
-(NSURL*)postMediaProgressRatingKey:(NSString*)rk identifier:(NSString*)ident time:(NSTimeInterval)tm;
-(NSURL*)postMediaProgressURL:(PlexMediaObject*)pmo time:(NSTimeInterval)tm;
-(NSMutableURLRequest*)urlRequestWithStreamingHeadersForURL:(NSURL*)url;
-(NSMutableURLRequest*)urlRequestWithAuthenticationHeadersForURL:(NSURL*)url;

-(NSURL*)plexPlayFileURL:(NSString*)file mediaContainer:(PlexMediaContainer*)pmc callingObject:(PlexMediaObject*)pmo;
-(NSURL*)plexPlayAudioObject:(PlexMediaObject*)pmo mediaContainer:(PlexMediaContainer*)pmc;
-(NSURL*)plexPlayObject:(PlexMediaObject*)pmo mediaContainer:(PlexMediaContainer*)pmc;
+(void)stopTranscoders;
-(void)stopTranscoder;
+(void)stopTranscodersSync;
-(void)stopTranscoderSync;

//sends an alive signal to the transcoder
+(void)pingTranscoders;
-(void)pingTranscoder;
-(void)pingTranscoderSync;

+(void)freeCache;

-(PlexImage*)flagForKey:(NSString*)key;
-(PlexMediaContainer*)rootLevel;
-(void)didReceiveMemoryWarning;
- (NSString *) buildAbsoluteKey: (NSString *) key;
- (NSString *) buildAbsoluteKey: (NSString *) key  referenceLocalHost:(BOOL)local;
- (BOOL)isPlexURL: (NSString *) key;
- (NSString *) buildAbsolutePlexURLKey: (NSString *) key;
@end
