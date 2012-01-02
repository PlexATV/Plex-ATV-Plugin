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
#import "gitversion.h"
#import <plex-oss/MyPlex.h>

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
                                                        value:[NSString stringWithFormat:@"%@-%@", kPlexPluginVersion, PLEX_GIT_VERSION]
                                                    withError:&err]) {
        DLog(@"Error %@", [err description]);
    }
    
    NSString *versionStr = [[UIDevice currentDevice] systemVersion];
    Class cls = NSClassFromString(@"ATVVersionInfo");
    if (cls) {
        versionStr = [cls currentOSVersion];
    }
    
    if (![[GANTracker sharedTracker] setCustomVariableAtIndex:2
                                                         name:@"currentOSVersion" 
                                                        value:versionStr
                                                    withError:&err]) {
        DLog(@"Error %@", [err description]);
    }
        
    //[[GANTracker sharedTracker] trackEvent:@"System" action:@"StartUp" label:@"System startup" value:1 withError:nil];
    if ([[MyPlex sharedMyPlex] authenticated]) {
        [self trackEvent:@"Using myPlex"];
    }
    
    [self trackPage:@"/"];
}


- (void)trackPage:(NSString*)page
{
    [[GANTracker sharedTracker] trackPageview:page withError:nil];
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
