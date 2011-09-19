//
//  PlexSecuritySettingsController.m
//  atvTwo
//
//  Created by ccjensen on 24/04/2011.
//
//  Inspired by
//
//		MLoader.m
//		MextLoader
//
//		Created by Thomas Cool on 10/22/10.
//		Copyright 2010 tomcool.org. All rights reserved.
//

#import "PlexSecuritySettingsController.h"
#import "HWUserDefaults.h"
#import "Constants.h"

@implementation PlexSecuritySettingsController

#define SecurityPasscodeIndex 0
#define SecuritySettingsLockEnabledIndex 1

#pragma mark -
#pragma mark Object/Class Lifecycle
- (id)init {
    if( (self = [super init]) != nil ) {
        [self setLabel:@"Plex Security Settings"];
        [self setListTitle:@"Plex Security Settings"];

        [self setupList];
    }
    return self;
}

- (void)dealloc {
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

    // =========== set security passcode ===========
    SMFMenuItem *securityPasscodeMenuItem = [SMFMenuItem folderMenuItem];

    [securityPasscodeMenuItem setTitle:@"Security Passcode"];
    NSInteger securityPasscode = [[HWUserDefaults preferences] integerForKey:PreferencesSecurityPasscode];
    NSString *securityPasscodeString = [[NSString alloc] initWithFormat:@"%04d", securityPasscode];
    [securityPasscodeMenuItem setRightText:securityPasscodeString];
    [securityPasscodeString release];
    [_items addObject:securityPasscodeMenuItem];


    // =========== settings lock ===========
    SMFMenuItem *settingsLockMenuItem = [SMFMenuItem menuItem];

    [settingsLockMenuItem setTitle:@"Settings Lock"];
    NSString *settingsLockOptions = [[HWUserDefaults preferences] boolForKey:PreferencesSecuritySettingsLockEnabled] ? @"Enabled" : @"Disabled";
    [settingsLockMenuItem setRightText:settingsLockOptions];
    [_items addObject:settingsLockMenuItem];
}

#pragma mark List Delegate Methods
- (void)itemSelected:(long)selected {
    switch (selected) {
    case SecurityPasscodeIndex: {
        // =========== set security passcode ===========
        SMFPasscodeController *passcodeController = [SMFPasscodeController passcodeWithTitle:@"Security Passcode"
                                                     withDescription:@"Please Select Plex's Security Passcode"
                                                     withBoxes:4
                                                     withDelegate:self];
        NSInteger securityPasscode = [[HWUserDefaults preferences] integerForKey:PreferencesSecurityPasscode];
        [passcodeController setInitialValue:securityPasscode];
        [[[BRApplicationStackManager sharedInstance] stack] pushController:passcodeController];
        break;
        break;
    }
    case SecuritySettingsLockEnabledIndex: {
        // =========== enable settings lock ===========
        BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesSecuritySettingsLockEnabled];
        [[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesSecuritySettingsLockEnabled];
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
    case SecurityPasscodeIndex: {
        // =========== set security passcode ===========
        [asset setTitle:@"Set a custom security passcode"];
        [asset setSummary:@"Lets you customize the plex passcode for any locked screens"];
        break;
    }
    case SecuritySettingsLockEnabledIndex: {
        // =========== settings lock ===========
        [asset setTitle:@"Toggles the Settings lock"];
        [asset setSummary:@"Locks the settings menu option using the security passcode"];
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


#pragma mark -
#pragma mark SMFPasscodeControllerDelegate methods
- (void)textDidChange:(id)sender {
}

- (void)textDidEndEditing:(id)sender {
    NSInteger newPasscode = [[sender stringValue] intValue];
    [[HWUserDefaults preferences] setInteger:newPasscode forKey:PreferencesSecurityPasscode];
    [self.list reload];
    [[[BRApplicationStackManager sharedInstance] stack] popController];
}


@end
