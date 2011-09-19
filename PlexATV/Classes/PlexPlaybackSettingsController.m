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
@synthesize plexStreamingQualities;

//----------- audio -----------
#define PlaybackAudioAC3EnabledIndex        0
#define PlaybackAudioDTSEnabledIndex        2
//----------- video -----------
#define PlaybackVideoQualityProfileIndex    1

#pragma mark -
#pragma mark Object/Class Lifecycle
- (id)init {
    if( (self = [super init]) != nil ) {
        [self setLabel:@"Plex Playback Settings"];
        [self setListTitle:@"Plex Playback Settings"];

        self.plexStreamingQualities = [HWUserDefaults plexStreamingQualities];
        [self setupList];

        [[self list] addDividerAtIndex:0 withLabel:@"Audio"];
        [[self list] addDividerAtIndex:1 withLabel:@"Video"];
    }
    return self;
}

- (void)dealloc {
    self.plexStreamingQualities = nil;

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

    [qualitySettingMenuItem setTitle:@"Quality Profile"];
    NSInteger qualityProfileNumber = [[HWUserDefaults preferences] integerForKey:PreferencesPlaybackVideoQualityProfile];
    PlexStreamingQualityDescriptor *qualitySetting = [self.plexStreamingQualities objectAtIndex:qualityProfileNumber];
    [qualitySettingMenuItem setRightText:qualitySetting.name];
    [_items addObject:qualitySettingMenuItem];
}

#pragma mark -
#pragma mark List Delegate Methods
- (void)itemSelected:(long)selected {
    switch (selected) {
    case PlaybackAudioAC3EnabledIndex: {
        // =========== enable ac3 menu ===========
        BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesPlaybackAudioAC3Enabled];
        [[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesPlaybackAudioAC3Enabled];
        [self setupList];
        [self.list reload];
        break;
    }
    case PlaybackAudioDTSEnabledIndex: {
        // =========== enable dts ===========
        BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesPlaybackAudioDTSEnabled];
        [[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesPlaybackAudioDTSEnabled];
        [self setupList];
        [self.list reload];
        break;
    }
    case PlaybackVideoQualityProfileIndex: {
        NSInteger qualitySetting = [[HWUserDefaults preferences] integerForKey:PreferencesPlaybackVideoQualityProfile];
        qualitySetting++;
        if (qualitySetting >= [self.plexStreamingQualities count]) {
            qualitySetting = 0;
        }
        [[HWUserDefaults preferences] setInteger:qualitySetting forKey:PreferencesPlaybackVideoQualityProfile];

        [self setupList];
        [self.list reload];
        break;
    }
    default:
        break;
    }

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
    case PlaybackAudioDTSEnabledIndex: {
        [asset setTitle:@"Toggles whether you want DTS sound output or not"];
        [asset setSummary:@"Enables your AppleTV to receive DTS sound when available in your videos"];
        break;
    }
    case PlaybackVideoQualityProfileIndex: {
        [asset setTitle:@"Select the video quality profile"];
        [asset setSummary:@"Sets the video quality profile of the streamed video."];
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
