//
//  PlexMyPlexSettingsController.m
//  plex
//
//  Created by Tobias Hieta on 2011-12-14.
//  Copyright (c) 2011 Tobias Hieta. All rights reserved.
//

#import "PlexMyPlexSettingsController.h"
#import <plex-oss/MyPlex.h>

@class PlexMyPlexSettingsController;

#import "HWSettingsController.h"

@implementation PlexMyPlexSettingsController

@synthesize password;

#pragma mark -
#pragma mark Object/Class Lifecycle
- (id)init {
    if( (self = [super init]) != nil ) {
        [self setLabel:@"myPlex Settings"];
        [self setListTitle:@"myPlex Settings"];

        isLoggingIn = NO;
        [self setupList];
    }
    return self;
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

#pragma mark -
#pragma mark List setup

- (NSString*)getMyPlexStatus {
    DLog(@"getMyPlexStatus");
    if ([[MyPlex sharedMyPlex] authenticated]) {
        [[MachineManager sharedMachineManager] forceDetectorUpdate];
        return @"OK";
    }
    if ([MyPlex sharedMyPlex].hadError) {
        return [MyPlex sharedMyPlex].lastError;
    }

    return @"Not logged in";
}

enum Indexes {
    StatusMenuItem,
    UserMenuItem,
    PasswordMenuItem
};

- (void)setupList {
    [_items removeAllObjects];

    SMFMenuItem *myPlexStatusMenuItem = [SMFMenuItem menuItem];
    myPlexStatusMenuItem.title = @"myPlex status";
    myPlexStatusMenuItem.rightText = [self getMyPlexStatus];
    if (isLoggingIn) {
        [myPlexStatusMenuItem addAccessoryOfPlexType:kPlexAccessoryTypeSpinner];
    } else {
        [myPlexStatusMenuItem removeAccessoryOfPlexType:kPlexAccessoryTypeSpinner];
    }
    [_items addObject:myPlexStatusMenuItem];

    SMFMenuItem *myPlexUsernameMenuItem = [SMFMenuItem menuItem];
    myPlexUsernameMenuItem.title = @"myPlex user name";
    if ([[PlexPrefs defaultPreferences] myPlexUser]) {
        myPlexUsernameMenuItem.rightText = [[PlexPrefs defaultPreferences] myPlexUser];
    }
    [_items addObject:myPlexUsernameMenuItem];

    SMFMenuItem *myPlexPasswordMenuItem = [SMFMenuItem menuItem];
    myPlexPasswordMenuItem.title = @"myPlex password";
    myPlexPasswordMenuItem.rightText = @"";
    [_items addObject:myPlexPasswordMenuItem];
}

#pragma mark -
#pragma mark List Delegate Methods
- (void)itemSelected:(long)selected {
    currentItem = selected;

    switch (selected) {
        case StatusMenuItem:
            if (![MyPlex sharedMyPlex].authenticated) {
                DLog(@"updating");
                [self sendLoginDetailsInBackground];
            }
            break;
        case UserMenuItem:
        {
            [HWSettingsController showDialogBoxWithTitle:@"myPlex - User name"
                                       secondaryInfoText:@"Set your myPlex user name"
                                             deviceTitle:@"devicetitle"
                                 deviceSecondaryInfoText:@"device info"
                                          textFieldLabel:@"User name"
                                         withInitialText:[[PlexPrefs defaultPreferences] myPlexUser]
                                         usingSecureText:NO
                                                delegate:self];
        }
        break;
        case PasswordMenuItem:
        {
            [HWSettingsController showDialogBoxWithTitle:@"myPlex - Password"
                                       secondaryInfoText:@"Set your myPlex password"
                                             deviceTitle:@"devicetitle"
                                 deviceSecondaryInfoText:@"device info"
                                          textFieldLabel:@"Password"
                                         withInitialText:@""
                                         usingSecureText:YES
                                                delegate:self];
        }
        break;
        default:
            break;
    }
}

#pragma mark TextEntry delegate
- (void)textDidEndEditing:(id)text {
    switch (currentItem) {
        case UserMenuItem:
            [[PlexPrefs defaultPreferences] setMyPlexUser:[text stringValue]];
            break;
        case PasswordMenuItem:
            self.password = [text stringValue];
            break;
        default:
            break;
    }

    [self sendLoginDetailsInBackground];

    [[[BRApplicationStackManager singleton] stack] popController];
}

- (void)sendLoginDetailsInBackground {
    if ([[PlexPrefs defaultPreferences] myPlexUser] && self.password) {
        isLoggingIn = YES;
        [self setupList];
        [self.list release];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[MyPlex sharedMyPlex] loginUser:[[PlexPrefs defaultPreferences] myPlexUser] withPassword:self.password];
            DLog (@"Done with myPlex loginUser");
            dispatch_async (dispatch_get_main_queue (), ^{
                isLoggingIn = NO;
                [self setupList];
                [self.list reload];
            });
            
        });
    }
}

- (id)previewControlForItem:(long)item {
    SMFBaseAsset *asset = [[SMFBaseAsset alloc] init];
    switch (item) {
        case StatusMenuItem: {
            [asset setTitle:@"Current status for myPlex, press to refresh"];
            [asset setSummary:@"Current status for myPlex, press to refresh"];
            break;
        }
        case UserMenuItem: {
            [asset setTitle:@"Your myPlex user name"];
            [asset setSummary:@"Typically this is your email address, if you don't have a myPlex user yet, go to my.plexapp.com in your browser"];
            break;
        }
        case PasswordMenuItem: {
            [asset setTitle:@"Your myPlex password"];
            [asset setSummary:@"Enter your secret secret password here"];
            break;
        }
    }

    [asset setCoverArt:[BRImage imageWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"MyPlexLogo" ofType:@"png"]]];
    SMFMediaPreview *p = [[SMFMediaPreview alloc] init];
    [p setShowsMetadataImmediately:YES];
    [p setAsset:asset];
    [asset release];
    return [p autorelease];
}

@end
