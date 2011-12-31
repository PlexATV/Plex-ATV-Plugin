//
//  PlexTrackingUtil.h
//  plex
//
//  Created by Tobias Hieta on 2011-12-30.
//  Copyright (c) 2011 Tobias Hieta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GANTracker.h"

@interface PlexTrackingUtil : NSObject<GANTrackerDelegate>

+ (PlexTrackingUtil*)sharedPlexTrackingUtil;
- (void)setupTracking;
- (void)trackEvent:(NSString*)event;
- (void)trackEvent:(NSString*)event withValue:(NSInteger)value;
- (void)trackPage:(NSString*)page;

@end
