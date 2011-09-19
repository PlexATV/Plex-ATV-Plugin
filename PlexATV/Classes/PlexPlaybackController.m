//
//  PlexPlaybackController.m
//  plex
//
//  Created by Bob Jelica on 22.02.2011.
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "PlexPlaybackController.h"
#import "Constants.h"
#import "HWUserDefaults.h"
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexMediaContainer.h>
#import <plex-oss/PlexImage.h>
#import <plex-oss/PlexRequest.h>
#import <plex-oss/PlexClientCapabilities.h>
#import <plex-oss/Preferences.h>
#import <plex-oss/PlexStreamingQuality.h>
#import "PlexMediaProvider.h"
#import "PlexMediaAsset.h"
#import "PlexMediaAssetOld.h"
#import "PlexSongAsset.h"
#import "PlexNavigationController.h"
#import "PlexThemeMusicPlayer.h"

#define LOCAL_DEBUG_ENABLED 1


PlexMediaProvider *__provider = nil;

#define ResumeOptionDialog @"ResumeOptionDialog"
#define StackOptionDialog @"StackOptionDialog"

#define kStartTrackingProgressTime 120.0f
#define kEndTrackingProgressPercentageCompleted 0.95f

@implementation PlexPlaybackController
@synthesize mediaObject, playProgressTimer;


#pragma mark -
#pragma mark Object/Class Lifecycle

- (id)initWithPlexMediaObject:(PlexMediaObject*)aMediaObject {
    self = [super init];
    if (self != nil) {
        self.mediaObject = aMediaObject;
    }

    return self;
}

- (void)dealloc {
    DLog(@"deallocing player controller for %@", self.mediaObject.name);

    self.mediaObject = nil;
    [self.playProgressTimer invalidate];
    self.playProgressTimer = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Controller Lifecycle behaviour
- (void)wasPushed {
    //what capabilities are set up
    DLog(@"machine capabilities: [%@]", [[PlexClientCapabilities sharedPlexClientCapabilities] capStringForMachine:self.mediaObject.request.machine]);

    //register for notifications when a movie has finished playing properly to the end.
    //used to mark movie as seen
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinished:)name:@"AVPlayerItemDidPlayToEndTimeNotification" object:nil];

    [self startPlaying];
    [super wasPushed];
}

- (void)wasPopped {
    //cleanup
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self playerStateChanged:kBRMediaPlayerStateStopped];

    [[PlexThemeMusicPlayer sharedPlexThemeMusicPlayer] startPlayingThemeMusicIfAppropiateForMediaObject:self.mediaObject];
    [super wasPopped];
}

- (void)wasExhumed {
    [super wasExhumed];
    if (playbackCancelled) {
        DLog(@"playback cancelled");
        [self performSelector:@selector(popSelfFromStack)withObject:nil afterDelay:0.0];
    }
}

- (void)wasBuried {
    [super wasBuried];
}

- (void)controlWasActivated {
}

- (void)popSelfFromStack {
    BRControllerStack *stack = [[BRApplicationStackManager singleton] stack];
    if ([stack peekController] == self) {
        [stack popController];
    }
}


#pragma mark -
#pragma mark Playback Methods
- (void)startPlaying {

    if ([@"Track" isEqualToString:self.mediaObject.containerType]) {
        DLog(@"ITS A TRAP(CK)!");
        [self playbackAudio];
    }
    else {
        DLog(@"viewOffset: %@", [self.mediaObject.attributes valueForKey:@"viewOffset"]);

        NSNumber *viewOffset = [NSNumber numberWithInt:[[self.mediaObject.attributes valueForKey:@"viewOffset"] intValue]];

        float totalOffsetInSeconds = [viewOffset intValue] / 1000.0f;
        //if progress is less than start tracking time, don't even bother to ask if video should be resumed.
        if (totalOffsetInSeconds < kStartTrackingProgressTime) {
            viewOffset = [NSNumber numberWithInt:0];
        }

        //we have offset, ie. already watched a part of the movie, show a dialog asking if you want to resume or start over
        if ([viewOffset intValue] > 0) {
            [self showResumeDialog];
        }
        else {
            [self playbackVideoWithOffset:0]; //just start playback from beginning
        }
    }
    [[PlexThemeMusicPlayer sharedPlexThemeMusicPlayer] stopPlayingThemeMusicForMediaObject:nil];
}

- (void)playbackVideoWithOffset:(int)offset {
    DLog(@"playback of video initiated, tell MM to chill");
    //playback started, tell MM to chill
    [[MachineManager sharedMachineManager] stopAutoDetection];
    [[MachineManager sharedMachineManager] stopMonitoringMachineState];

    [self.mediaObject.attributes setObject:[NSNumber numberWithInt:offset] forKey:@"viewOffset"]; //set where in the video we want to start...

    //determine the user selected quality setting
    NSInteger qualityProfileNumber = [[HWUserDefaults preferences] integerForKey:PreferencesPlaybackVideoQualityProfile];
    PlexStreamingQualityDescriptor *streamQuality = [[HWUserDefaults plexStreamingQualities] objectAtIndex:qualityProfileNumber];

    //send our desired quality setting to the PMS
    self.mediaObject.request.machine.streamQuality = streamQuality;

    DLog(@"streaming bitrate: %d", self.mediaObject.request.machine.streamingBitrate);
    DLog(@"Quality: %@", self.mediaObject.request.machine.streamQuality);
    //DLog(@"%@", pmo.request.machine.capabilities.qualities);
    NSURL *mediaURL = [self.mediaObject mediaURL];

    DLog(@"Starting Playback of %@", mediaURL);

    BOOL didTimeOut = NO;
    //TODO: what cache policy should we use??
    [self.mediaObject.request dataForURL:mediaURL authenticateStreaming:YES timeout:0 didTimeout:&didTimeOut cachePolicy:NSURLCacheStorageAllowedInMemoryOnly];



    if (__provider == nil) {
        __provider = [[PlexMediaProvider alloc] init];
        BRMediaHost *mh = [[BRMediaHost mediaHosts] objectAtIndex:0];
        [mh addMediaProvider:__provider];
        [__provider release];
    }

    if (self.playProgressTimer) {
        [self.playProgressTimer invalidate];
    }

    BRBaseMediaAsset *pma = nil;
    if ([[[UIDevice currentDevice] systemVersion] isEqualToString:@"4.1"]) {
        pma = [[PlexMediaAssetOld alloc] initWithURL:mediaURL mediaProvider:nil mediaObject:self.mediaObject];
    } else {
        pma = [[PlexMediaAsset alloc] initWithURL:mediaURL mediaProvider:nil mediaObject:self.mediaObject];
    }

    BRMediaPlayerManager *mgm = [BRMediaPlayerManager singleton];
    NSError *error = nil;
    BRMediaPlayer *player = [mgm playerForMediaAsset:pma error:&error];
    DLog(@"pma=%@, prov=%@, mgm=%@, play=%@, err=%@", pma, __provider, mgm, player, error);
    if ( error != nil ) {
        [pma release];
        return;
    }


    //[mgm presentMediaAsset:pma options:0];
    [mgm presentPlayer:player options:0];
    DLog(@"presented player");

    self.playProgressTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f
                              target:self
                              selector:@selector(reportProgress:)
                              userInfo:nil
                              repeats:YES];

    //we need all the memory we can spare so we don't get killed by the OS
    [pma release];

    //we'll use this notification to catch the menu-ing out of a movie, ie. the stopped notification from the main player instead of relying on our timer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStateChanged:)name:@"BRMPStateChanged" object:nil];
}

- (void)playbackAudio {
    DLog(@"playback of audio initiated, tell MM to chill");
    //playback started, tell MM to chill
    [[MachineManager sharedMachineManager] stopAutoDetection];
    [[MachineManager sharedMachineManager] stopMonitoringMachineState];

    NSError *error;

    DLog(@"track_url: %@", [self.mediaObject mediaStreamURL]);
    DLog(@"key: %@", [self.mediaObject.attributes objectForKey:@"key"]);

    PlexSongAsset *psa = [[PlexSongAsset alloc] initWithURL:[self.mediaObject.attributes objectForKey:@"key"] mediaProvider:nil mediaObject:self.mediaObject];

    BRMediaPlayer *player = [[BRMediaPlayerManager singleton] playerForMediaAsset:psa error:&error];
    [psa release];

    [[BRMediaPlayerManager singleton] presentPlayer:player options:nil];

    DLog(@"presented audio player");
}

#define kProgressCurrentTime @"kProgressCurrentTime"
#define kProgressTotalTime @"kProgressTotalTime"
#define kProgressSeenState @"kProgressSeenState"
- (void)postProgress:(NSDictionary*)progressDict {
    if ([NSThread isMainThread]) {
        [self performSelectorInBackground:@selector(postProgress:)withObject:progressDict];
    } else {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSNumber *currentNumber = [progressDict objectForKey:kProgressCurrentTime];
        NSNumber *totalNumber = [progressDict objectForKey:kProgressTotalTime];
        NSString *seenState = [progressDict objectForKey:kProgressSeenState];

        CGFloat current = [currentNumber floatValue];
        CGFloat total = [totalNumber floatValue];

        // Only report progress after a certain number of seconds have been watched
        // and the movie is less than a certain percentage left
        if (current > kStartTrackingProgressTime
            && kEndTrackingProgressPercentageCompleted > current / total) {
            DLog(@"posting progress [%f]", current);
            [self.mediaObject postMediaProgress:current];
        }

        //if not already marked as seen, and when an item has less than a certain percentage left
        if ( [self.mediaObject seenState] != PlexMediaObjectSeenStateSeen
             && kEndTrackingProgressPercentageCompleted < current / total) {
            DLog(@"more than %f completed, mark as watched", kEndTrackingProgressPercentageCompleted);
            [self.mediaObject markSeen];
        }

        DLog(@"current [%f] out of a total [%f] (%f2 percentage). watched status [%@]", current, total, (current / total) * 100.f, seenState);

        [pool release];
    }
}

- (void)reportProgress:(NSTimer*)tm {
    BRMediaPlayer *playa = [[BRMediaPlayerManager singleton] activePlayer];
    //TODO: keep investigating updating buffer progress
    //playa->_aggregateBufferedRange = [NSMakeRange(0, playa.elapsedTime+30);

    switch (playa.playerState) {
    case kBRMediaPlayerStatePlaying: {
        //report time back to PMS on a background thread so we can continue in the right spot
        CGFloat current = playa.elapsedTime;
        CGFloat total = [[[self.mediaObject mediaResource] attributes] integerForKey:@"duration"] / 1000.0f;

        NSNumber *currentNumber = [NSNumber numberWithFloat:current];
        NSNumber *totalNumber = [NSNumber numberWithFloat:total];

        NSString *seenState;
        if ([self.mediaObject seenState] == PlexMediaObjectSeenStateUnseen) {
            seenState = @"unwatched";
        } else if ([self.mediaObject seenState] == PlexMediaObjectSeenStateInProgress) {
            seenState = @"partial";
        } else if ([self.mediaObject seenState] == PlexMediaObjectSeenStateSeen) {
            seenState = @"watched";
        } else {
            seenState = @"unknown";
        }

        NSDictionary *progressDictionary = [NSDictionary dictionaryWithObjectsAndKeys:totalNumber, kProgressTotalTime, currentNumber, kProgressCurrentTime, seenState, kProgressSeenState, nil];
        [self postProgress:progressDictionary];
        break;
    }
    case kBRMediaPlayerStatePaused:
        DLog(@"paused playback, pinging transcoder");
        [self.mediaObject.request pingTranscoder];
        break;

    case kBRMediaPlayerStateSkipping:
    case kBRMediaPlayerStateForwardSeeking:
    case kBRMediaPlayerStateForwardSeekingFast:
    case kBRMediaPlayerStateForwardSeekingFastest:
    case kBRMediaPlayerStateBackSeeking:
    case kBRMediaPlayerStateBackSeekingFast:
    case kBRMediaPlayerStateBackSeekingFastest:
        break;
    default:
        break;
    }
}

- (void)movieFinished:(NSNotification*)event {
    [self.mediaObject markSeen]; //makes sure the item is marked as seen
}

- (void)playerStateChanged:(NSNotification*)event {
    //DLog(@"%@", event)
    BRMediaPlayer *playa = [[BRMediaPlayerManager singleton] activePlayer];

    switch (playa.playerState) {
    case kBRMediaPlayerStatePlaying:
        //playback has (re)started
        [self reportProgress:nil];

        break;
    case kBRMediaPlayerStateStopped:
        DLog(@"stopping the transcoder");

        //stop the transcoding on PMS
        [self.mediaObject.request stopTranscoder];
        DLog(@"transcoder stopped");

        if (self.playProgressTimer && [self.playProgressTimer isValid]) {
            [self.playProgressTimer invalidate];
            DLog(@"stopped progress timer");
        }

        DLog(@"Finished Playback, fire up MM");
        //playback stopped, tell MM to fire up again
        [[MachineManager sharedMachineManager] startAutoDetection];
        [[MachineManager sharedMachineManager] startMonitoringMachineState];
        [[[BRApplicationStackManager singleton] stack] popController];
        break;

    case kBRMediaPlayerStatePaused:
    case kBRMediaPlayerStateSkipping:
    case kBRMediaPlayerStateForwardSeeking:
    case kBRMediaPlayerStateForwardSeekingFast:
    case kBRMediaPlayerStateForwardSeekingFastest:
    case kBRMediaPlayerStateBackSeeking:
    case kBRMediaPlayerStateBackSeekingFast:
    case kBRMediaPlayerStateBackSeekingFastest:
        break;
    default:
        break;
    }

}

#pragma mark -
#pragma mark BROptionDialog
- (void)showResumeDialog {
    NSNumber *viewOffset = [NSNumber numberWithInt:[[self.mediaObject.attributes valueForKey:@"viewOffset"] intValue]];

    BROptionDialog *option = [[BROptionDialog alloc] init];
    [option setIdentifier:ResumeOptionDialog];

    [option setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                         viewOffset, @"viewOffset",
                         self.mediaObject, @"mediaObject",
                         nil]];
    [option setPrimaryInfoText:@"You have already watched a part of this video.\nWould you like to continue where you left off, or start from beginning?"];
    [option setSecondaryInfoText:self.mediaObject.name];

    int offsetInHrs = [viewOffset intValue] / (1000 * 60 * 60);
    int offsetInMins = ( [viewOffset intValue] % (1000 * 60 * 60) ) / (1000 * 60);
    int offsetInSecs = ( ( [viewOffset intValue] % (1000 * 60 * 60) ) % (1000 * 60) ) / 1000;

    if (offsetInHrs > 0)
        [option addOptionText:[NSString stringWithFormat:@"Resume from %d hrs %d mins %d secs", offsetInHrs, offsetInMins, offsetInSecs]];
    else
        [option addOptionText:[NSString stringWithFormat:@"Resume from %d mins %d secs", offsetInMins, offsetInSecs]];

    [option addOptionText:@"Play from the beginning"];
    [option addOptionText:@"Go back"];
    [option setActionSelector:@selector(optionSelected:)target:self];
    [[[BRApplicationStackManager singleton] stack] pushController:option];
    [option release];
    playbackCancelled = YES; //will get set to no if user chose a playback option
}


#pragma mark -
#pragma mark BROptionDialog handler
- (void)optionSelected:(id)sender {
    BROptionDialog *option = sender;
    if ([option.identifier isEqualToString:ResumeOptionDialog]) {
        NSNumber *viewOffset = [option.userInfo objectForKey:@"viewOffset"];

        if([[sender selectedText] hasPrefix:@"Resume from"]) {
            playbackCancelled = NO;
            [[[BRApplicationStackManager singleton] stack] popController]; //need this so we don't go back to option dialog when going back
            DLog(@"Resuming from %d ms", [viewOffset intValue]);
            [self playbackVideoWithOffset:[viewOffset intValue]];

        } else if ([[sender selectedText] isEqualToString:@"Play from the beginning"]) {
            playbackCancelled = NO;
            [[[BRApplicationStackManager singleton] stack] popController]; //need this so we don't go back to option dialog when going back
            [self playbackVideoWithOffset:0]; //0 offset is beginning, mkay?

        } else if ([[sender selectedText] isEqualToString:@"Go back"]) {
            //go back to movie listing...
            [[[BRApplicationStackManager singleton] stack] popController];
        }
    }
}


@end
