//
//  PlexAudioSettingsController.m
//  atvTwo
//
//  Created by bob on 10/01/2011.
//
//  Inspired by
//
//		MLoader.m
//		MextLoader
//
//		Created by Thomas Cool on 10/22/10.
//		Copyright 2010 tomcool.org. All rights reserved.
//

#import "PlexPlaybackSettingsController.h"
#import <plex-oss/PlexStreamingQuality.h>
#import "HWUserDefaults.h"
#import "Constants.h"

@implementation PlexPlaybackSettingsController
@synthesize plexStreamingQualities, plexDirectPlayQualities;

//----------- audio -----------
#define PlaybackAudioAC3EnabledIndex                0
//#define PlaybackAudioDTSEnabledIndex        2
//----------- video -----------
#define PlaybackVideoQualityProfileIndex            1
#define PlaybackVideoQualityRemoteProfileIndex      2
#define PlaybackVideoDirectPlay                     3
#define PlaybackVideoDirectPlayQuality              4

#pragma mark -
#pragma mark Object/Class Lifecycle
- (id)init {
    if( (self = [super init]) != nil ) {
        [self setLabel:@"Plex Playback Settings"];
        [self setListTitle:@"Plex Playback Settings"];

        self.plexStreamingQualities = [HWUserDefaults plexStreamingQualities];
        self.plexDirectPlayQualities = [NSArray arrayWithObjects:@"SD", @"720", @"1080", nil];
        
        [self setupList];

        [[self list] addDividerAtIndex:0 withLabel:@"Audio"];
        [[self list] addDividerAtIndex:1 withLabel:@"Video"];
        
    }
    return self;
}

- (void)dealloc {
    self.plexStreamingQualities = nil;
    self.plexDirectPlayQualities = nil;

    [super dealloc];
}


#pragma mark -
#pragma mark Controller Lifecycle behaviour
- (void)wasPushed {
    [[MachineManager sharedMachineManager] setMachineStateMonitorPriority:NO];
    [super wasPushed];
}

- (void)wasPopped {
    [super wasPopped];
}

- (void)wasExhumed {
    [[MachineManager sharedMachineManager] setMachineStateMonitorPriority:NO];
    [self setupList];
    [self.list reload];
    [super wasExhumed];
}

- (void)wasBuried {
    [super wasBuried];
}

- (void)setupList {
    [_items removeAllObjects];

    // =========== AUDIO SETTINGS ===========
    // =========== ac3 ===========
    SMFMenuItem *ac3MenuItem = [SMFMenuItem menuItem];

    [ac3MenuItem setTitle:@"Dolby™ AC3 capable receiver"];
    NSString *ac3 = [[HWUserDefaults preferences] boolForKey:PreferencesPlaybackAudioAC3Enabled] ? @"Yes" : @"No";
    [ac3MenuItem setRightText:ac3];
    [_items addObject:ac3MenuItem];


    // =========== dts ===========
    /*
       SMFMenuItem *dtsMenuItem = [SMFMenuItem menuItem];

       [dtsMenuItem setTitle:@"DTS™ capable receiver"];
       NSString *dts = [[HWUserDefaults preferences] boolForKey:PreferencesPlaybackAudioDTSEnabled] ? @"Yes" : @"No";
       [dtsMenuItem setRightText:dts];
       [_items addObject:dtsMenuItem];
     */


    // =========== VIDEO SETTINGS ===========
    // =========== quality setting ===========
    SMFMenuItem *qualitySettingMenuItem = [SMFMenuItem menuItem];

    [qualitySettingMenuItem setTitle:@"Quality Profile (local content)"];
    NSInteger qualityProfileNumber = [[HWUserDefaults preferences] integerForKey:PreferencesPlaybackVideoQualityProfile];
    PlexStreamingQualityDescriptor *qualitySetting = [self.plexStreamingQualities objectAtIndex:qualityProfileNumber];
    [qualitySettingMenuItem setRightText:qualitySetting.name];
    [_items addObject:qualitySettingMenuItem];

    // =========== quality setting (remote) ===========
    SMFMenuItem *qualitySettingRemoteMenuItem = [SMFMenuItem menuItem];
    
    [qualitySettingRemoteMenuItem setTitle:@"Quality Profile (remote content)"];
    NSInteger qualityProfileRemoteNumber = [[HWUserDefaults preferences] integerForKey:PreferencesPlaybackVideoQualityRemoteProfile];
    PlexStreamingQualityDescriptor *qualityRemoteSetting = [self.plexStreamingQualities objectAtIndex:qualityProfileRemoteNumber];
    [qualitySettingRemoteMenuItem setRightText:qualityRemoteSetting.name];
    [_items addObject:qualitySettingRemoteMenuItem];

    // =========== direct play ===========
    SMFMenuItem *allowDirectPlayEnabled = [SMFMenuItem menuItem];
    
    [allowDirectPlayEnabled setTitle:@"Direct Play"];
    BOOL directPlayAllowed = [[HWUserDefaults defaultPreferences] allowDirectPlayback];
    [allowDirectPlayEnabled setRightText:directPlayAllowed ? @"Enabled" : @"Disabled"];
    [_items addObject:allowDirectPlayEnabled];

    // =========== quality setting (direct play) ===========
    SMFMenuItem *directPlayQualityItem = [SMFMenuItem menuItem];
    
    [directPlayQualityItem setTitle:@"Direct Play Quality Profile"];
    NSInteger dpQualityIndex = [[HWUserDefaults preferences] integerForKey:PreferencesPlaybackVideoDirectPlayQuality];
    NSString *dpQualStr = [self.plexDirectPlayQualities objectAtIndex:dpQualityIndex];
    [directPlayQualityItem setRightText:dpQualStr];
    [_items addObject:directPlayQualityItem];
}


#pragma mark -
#pragma mark List Delegate Methods
- (void)itemSelected:(long)selected {
    switch (selected) {
    case PlaybackAudioAC3EnabledIndex: {
        // =========== enable ac3 menu ===========
        BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesPlaybackAudioAC3Enabled];
        [[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesPlaybackAudioAC3Enabled];
        break;
    }
#if 0
    case PlaybackAudioDTSEnabledIndex: {
        // =========== enable dts ===========
        BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesPlaybackAudioDTSEnabled];
        [[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesPlaybackAudioDTSEnabled];
        break;
    }
#endif
    case PlaybackVideoQualityProfileIndex: {
        NSInteger qualitySetting = [[HWUserDefaults preferences] integerForKey:PreferencesPlaybackVideoQualityProfile];
        qualitySetting++;
        if (qualitySetting >= [self.plexStreamingQualities count]) {
            qualitySetting = 0;
        }
        [[HWUserDefaults preferences] setInteger:qualitySetting forKey:PreferencesPlaybackVideoQualityProfile];
        break;
    }
    case PlaybackVideoQualityRemoteProfileIndex: {
        NSInteger qualitySetting = [[HWUserDefaults preferences] integerForKey:PreferencesPlaybackVideoQualityRemoteProfile];
        qualitySetting++;
        if (qualitySetting >= [self.plexStreamingQualities count]) {
            qualitySetting = 0;
        }
        [[HWUserDefaults preferences] setInteger:qualitySetting forKey:PreferencesPlaybackVideoQualityRemoteProfile];        
        break;
    }
    case PlaybackVideoDirectPlay: {
        BOOL allowDP = [[HWUserDefaults defaultPreferences] allowDirectPlayback];
        if (allowDP) allowDP = NO;
        else allowDP = YES;
        NSLog(@"AllowDP = %d", allowDP);
        [[HWUserDefaults defaultPreferences] setAllowDirectPlayback:allowDP];
        break;
    }
    case PlaybackVideoDirectPlayQuality: {
        NSInteger dpQuality = [[HWUserDefaults preferences] integerForKey:PreferencesPlaybackVideoDirectPlayQuality];
        
        dpQuality ++;
        if (dpQuality >= 3)
            dpQuality = 0;
        
        [[HWUserDefaults preferences] setInteger:dpQuality forKey:PreferencesPlaybackVideoDirectPlayQuality];
        
        NSString *dpQualityStr = [self.plexDirectPlayQualities objectAtIndex:dpQuality];
        DLog(@"directStreamQual = %@", dpQualityStr);
        [[HWUserDefaults defaultPreferences] setDirectStreamQuality:[dpQualityStr intValue]];
    }
    default:
        break;
    }

    [self setupList];
    [self.list reload];

    //re-send the caps to the PMS
    [HWUserDefaults setupPlexClient];
}

- (id)previewControlForItem:(long)item {
    SMFBaseAsset *asset = [[SMFBaseAsset alloc] init];
    switch (item) {
    case PlaybackAudioAC3EnabledIndex: {
        [asset setTitle:@"Toggles whether you want AC3 sound output or not"];
        [asset setSummary:@"Enables your AppleTV to receive AC3 sound when available in your videos"];
        break;
    }
#if 0
    case PlaybackAudioDTSEnabledIndex: {
        [asset setTitle:@"Toggles whether you want DTS sound output or not"];
        [asset setSummary:@"Enables your AppleTV to receive DTS sound when available in your videos"];
        break;
    }
#endif
    case PlaybackVideoQualityProfileIndex: {
        [asset setTitle:@"Select the video quality profile"];
        [asset setSummary:@"Sets the video quality profile of the streamed video."];
        break;
    }
    case PlaybackVideoQualityRemoteProfileIndex: {
        [asset setTitle:@"Select the video quality profile"];
        [asset setSummary:@"Sets the video quality profile of the streamed video from remote sites"];
        break;
    }
    case PlaybackVideoDirectPlay: {
        [asset setTitle:@"Toggles whether you want to enable direct play"];
        [asset setTitle:@"Direct play allows you to play comptabible files directly on the Apple TV, but might not work at all times"];
        break;
    }
    case PlaybackVideoDirectPlayQuality: {
        [asset setTitle:@"Select the video quality when playing directly"];
        [asset setTitle:@"Prefer this verison of the video when playing directly"];
        break;
    }

        default:
        break;
    }
    [asset setCoverArt:[BRImage imageWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"PlexSettings" ofType:@"png"]]];
    SMFMediaPreview *p = [[SMFMediaPreview alloc] init];
    [p setShowsMetadataImmediately:YES];
    [p setAsset:asset];
    [asset release];
    return [p autorelease];
}


@end
