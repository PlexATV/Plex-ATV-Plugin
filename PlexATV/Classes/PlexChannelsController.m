//
//  PlexChannelsController.m
//  plex
//
//  Created by ccjensen on 13/04/2011.
//

#import "PlexChannelsController.h"
#import "Constants.h"
#import <plex-oss/PlexRequest.h>
#import "PlexMediaObject+Assets.h"
#import "HWUserDefaults.h"
#import "HWPlexDir.h"

#define LOCAL_DEBUG_ENABLED 1

@implementation PlexChannelsController
@synthesize rootContainer;


#pragma mark -
#pragma mark Object/Class Lifecycle
- (id)init {
    if( (self = [super init]) != nil ) {
        [self setListTitle:@"PLEX"];

        NSString *settingsPng = [[NSBundle bundleForClass:[PlexChannelsController class]] pathForResource:@"PlexIcon" ofType:@"png"];
        BRImage *sp = [BRImage imageWithPath:settingsPng];

        [self setListIcon:sp horizontalOffset:0.0 kerningFactor:0.15];

        rootContainer = nil;
        rowIsLoading = -1;
        [[self list] setDatasource:self];
        return (self);

    }

    return (self);
}

- (id)initWithRootContainer:(PlexMediaContainer*)container {
    self = [self init];
    self.rootContainer = container;
    DLog(@"rootCont: %@", self.rootContainer);
    return self;
}

- (void)log:(NSNotificationCenter*)note {
    DLog(@"note = %@", note);
}

- (void)dealloc {
    DLog(@"deallocing HWPlexDir");
    [playbackItem release];
    [rootContainer release];

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
    [self.list reload];
    [super wasExhumed];
}

- (void)wasBuried {
    [super wasBuried];
}

- (id)previewControlForItem:(long)item {
    PlexMediaObject *pmo = [rootContainer.directories objectAtIndex:item];
    return pmo.previewControl;
}

#define ModifyViewStatusOptionDialog @"ModifyViewStatusOptionDialog"

- (void)itemSelected:(long)selected; {
    PlexMediaObject *pmo = [rootContainer.directories objectAtIndex:selected];
    rowIsLoading = selected;
    [self.list reload];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PlexMediaContainer *channel = [pmo.request query:[pmo.attributes valueForKey:@"path"] 
                                           callingObject:nil 
                                           ignorePresets:YES
                                                 timeout:20
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy];
        rowIsLoading = -1;
        if (channel) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                HWPlexDir *menuController = [[HWPlexDir alloc] initWithRootContainer:channel andTabBar:nil];
                [[[BRApplicationStackManager singleton] stack] pushController:menuController];
            
                [menuController release];
            });
        }
    });
}


- (float)heightForRow:(long)row {
    return 0.0f;
}

- (long)itemCount {
    return [rootContainer.directories count];
}

- (id)itemForRow:(long)row {
    if(row > [rootContainer.directories count])
        return nil;

    PlexMediaObject *pmo = [rootContainer.directories objectAtIndex:row];
    BRMenuItem *menuItem = [[BRMenuItem alloc] init];

    NSString *menuItemText = nil;
    NSString *path = [pmo.attributes valueForKey:@"path"];

    if ([path hasSuffix:@"iTunes"]) {
        NSString *type = nil;
        if ([path hasPrefix:@"/video"]) {
            type = @"video";
        } else {
            type = @"music";
        }
        menuItemText = [NSString stringWithFormat:@"%@ (%@)", [pmo name], type];
    } else {
        menuItemText = [pmo name];
    }

    [menuItem setText:menuItemText withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
    if (rowIsLoading == row) {
        [menuItem addAccessoryOfPlexType:kPlexAccessoryTypeSpinner];
    } else {
        [menuItem addAccessoryOfPlexType:kPlexAccessoryTypeFolder];
    }
    return [menuItem autorelease];
}

- (BOOL)rowSelectable:(long)selectable {
    if (rowIsLoading == 0 || rowIsLoading > 0)
        return NO;
    return TRUE;
}

- (id)titleForRow:(long)row {
    PlexMediaObject *pmo = [rootContainer.directories objectAtIndex:row];
    return pmo.name;
}

@end