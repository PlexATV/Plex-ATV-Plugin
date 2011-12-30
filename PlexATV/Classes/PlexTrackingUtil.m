//
//  PlexTrackingUtil.m
//  plex
//
//  Created by Tobias Hieta on 2011-12-30.
//  Copyright (c) 2011 Tobias Hieta. All rights reserved.
//

#import "PlexTrackingUtil.h"
#import "GANTracker.h"
#import "HWUserDefaults.h"
#import "Constants.h"
#import "Plex_SynthesizeSingleton.h"

@implementation PlexTrackingUtil

PLEX_SYNTHESIZE_SINGLETON_FOR_CLASS(PlexTrackingUtil);

- (void)setupTracking
{
    if (![[HWUserDefaults preferences] boolForKey:PreferencesAllowTracking])
        return;
    
    [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-28013505-1" dispatchPeriod:10 delegate:self];
    
    NSError *err;
    if (![[GANTracker sharedTracker] setCustomVariableAtIndex:1
                                                         name:@"AppVersion" 
                                                        value:[[NSBundle mainBundle] objectForInfoDictionaryKey:kPlexPluginVersion]
                                                    withError:&err]) {
        DLog(@"Error %@", [err description]);
    }
    
    if (![[GANTracker sharedTracker] setCustomVariableAtIndex:2
                                                         name:@"iOSVersion" 
                                                        value:[[UIDevice currentDevice] systemVersion]
                                                    withError:&err]) {
        DLog(@"Error %@", [err description]);
    }
    
    if (![[GANTracker sharedTracker] setCustomVariableAtIndex:3
                                                         name:@"Platform"
                                                        value:@"AppleTV2"
                                                    withError:&err]) {
        DLog(@"Error %@", [err description]);
    }
    
    [[GANTracker sharedTracker] trackEvent:@"System" action:@"StartUp" label:@"System startup" value:1 withError:nil];
}


- (void)trackEvent:(NSString*)event withValue:(NSInteger)value
{
    if (![[HWUserDefaults preferences] boolForKey:PreferencesAllowTracking])
        return;
    
    [[GANTracker sharedTracker] trackEvent:@"Events" action:event label:@"" value:value withError:nil];
}

- (void)trackEvent:(NSString*)event
{
    [self trackEvent:event withValue:1];
}

- (void)trackerDispatchDidComplete:(GANTracker *)tracker
                  eventsDispatched:(NSUInteger)hitsDispatched
              eventsFailedDispatch:(NSUInteger)hitsFailedDispatch
{
    DLog(@"Successfull dispatch of %d events, failed with %d events", hitsDispatched, hitsFailedDispatch);
}

-(void)hitDispatched:(NSString *)hitString
{
}

@end
