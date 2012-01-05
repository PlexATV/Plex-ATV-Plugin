//
//  HWServersController.m
//  atvTwo
//
//  Created by ccjensen on 10/01/2011.
//

#define LOCAL_DEBUG_ENABLED 1

#import "HWServersController.h"
#import <plex-oss/MachineManager.h>
#import <plex-oss/PlexRequest.h>
#import "Constants.h"
#import "HWServerDetailsController.h"
#import "PlexCompatibility.h"

@implementation HWServersController

@synthesize machines = _machines;


#pragma mark -
#pragma mark Object/Class Lifecycle
- (id)init {
    if( (self = [super init]) != nil ) {
        [self setListTitle:@"All Servers"];
        BRImage *sp = [[BRThemeInfo sharedTheme] gearImage];

        [self setListIcon:sp horizontalOffset:0.0 kerningFactor:0.15];

        _machines = [[NSMutableArray alloc] init];

        NSSortDescriptor *firstSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"usersServerName" ascending:YES];
        NSSortDescriptor *secondSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"serverName" ascending:YES];
        _machineSortDescriptors = [[NSArray alloc] initWithObjects:firstSortDescriptor, secondSortDescriptor, nil];
        [firstSortDescriptor release];
        [secondSortDescriptor release];

        [[self list] setDatasource:self];
        [[self list] addDividerAtIndex:1 withLabel:@"List of Servers"];
    }
    return self;
}

- (void)dealloc {
    self.machines = nil;
    [_machineSortDescriptors release];

    [super dealloc];
}


#pragma mark -
#pragma mark Controller Lifecycle behaviour
- (void)wasPushed {
    [[MachineManager sharedMachineManager] setMachineStateMonitorPriority:YES];
    [[ProxyMachineDelegate shared] registerDelegate:self];
    [self.machines removeAllObjects];
    NSArray *allMachines = [[MachineManager sharedMachineManager] threadSafeMachines];
    /* did I ever tell you that I LOOOOVE blocks */
    [self.machines addObjectsFromArray:[allMachines objectsAtIndexes:[allMachines indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        Machine *m = (Machine*)obj;
        if ([m.machineID isEqualToString:@"myPlex"]) return NO;
        if (m.owned) return YES;
        return NO;
    }]]];
    [self.machines sortUsingDescriptors:_machineSortDescriptors];
    [self.list reload];
    [super wasPushed];
}

- (void)wasPopped {
    [[ProxyMachineDelegate shared] removeDelegate:self];
    [super wasPopped];
}

- (void)wasExhumed {
    [[MachineManager sharedMachineManager] setMachineStateMonitorPriority:YES];
    [[self list] reload];
    [super wasExhumed];
}

- (void)wasBuried {
    [super wasBuried];
}


#pragma mark -
#pragma mark Edit Machine Manager's Machine List Methods
- (void)showAddNewMachineWizard {
    HWServerDetailsController *serverDetailsController = [[HWServerDetailsController alloc] initAndShowAddNewMachineWizard];
    [[self stack] pushController:serverDetailsController];
    [serverDetailsController release];
}

- (void)showEditMachineDetailsViewForMachine:(Machine*)machine {
    HWServerDetailsController *serverDetailsController = [[HWServerDetailsController alloc] initWithMachine:machine];
    [[self stack] pushController:serverDetailsController];
    [serverDetailsController release];
}


#pragma mark -
#pragma mark Menu Controller Delegate Methods
- (id)previewControlForItem:(long)item {
    BRImage *theImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[HWServersController class]] pathForResource:@"PmsLogo" ofType:@"png"]];
    BRImageAndSyncingPreviewController *obj = [[BRImageAndSyncingPreviewController alloc] init];
    [obj setImage:theImage];
    return [obj autorelease];
}

- (BOOL)shouldRefreshForUpdateToObject:(id)object {
    return YES;
}

- (void)itemSelected:(long)selected {
#ifdef LOCAL_DEBUG_ENABLED
    DLog(@"itemSelected: %ld",selected);
#endif
    if (selected == 0) {
        [self showAddNewMachineWizard];
    } else {
        Machine *m = [self.machines objectAtIndex:selected - 1]; //-1 'cause of the "Add remote server" that screws up things
#ifdef LOCAL_DEBUG_ENABLED
        DLog(@"machine selected: %@", m);
#endif
        [self showEditMachineDetailsViewForMachine:m];
    }
}

- (float)heightForRow:(long)row {
    return 0.0f;
}

- (long)itemCount {
    return self.machines.count + 1;
}

- (id)itemForRow:(long)row {
    BRMenuItem *result = [[BRMenuItem alloc] init];

    if(row == 0) {
        [result setText:@"Add new server" withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
        [result addAccessoryOfPlexType:kPlexAccessoryTypeNone];
    } else {
        Machine *m = [self.machines objectAtIndex:row - 1];
        NSString *serverName;

        if (m.usersServerName && [m.usersServerName length] > 0) {
            serverName = m.usersServerName;
        } else if (m.serverName && [m.serverName length] > 0) {
            serverName = m.serverName;
        } else {
            serverName = @"<Unknown>"; //if machine has no connections
        }

        [result setText:serverName withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];

        [result addAccessoryOfPlexType:kPlexAccessoryTypeFolder]; //folder
        if (m.canConnect) {
            [result addAccessoryOfPlexType:kPlexAccessoryTypeLeftGreenPlaylist];
        } else {
            [result addAccessoryOfPlexType:kPlexAccessoryTypeLeftPurplePlaylist];
        }

    }

    return [result autorelease];
}

- (BOOL)rowSelectable:(long)selectable {
    return TRUE;
}

- (id)titleForRow:(long)row {
    if (row >= [self.machines count] || row < 0)
        return @"";
    Machine *m = [self.machines objectAtIndex:row];
    return m.serverName;
}

- (void)setNeedsUpdate {
#ifdef LOCAL_DEBUG_ENABLED
    DLog(@"Updating UI");
#endif
    [self.list reload];
}

#pragma mark -
#pragma mark Machine Delegate Methods
- (void)machineWasRemoved:(Machine*)m {
#if LOCAL_DEBUG_ENABLED
    DLog(@"MachineManager: Removed machine %@", m);
#endif
    if ([self.machines containsObject:m]) {
        [self.machines removeObject:m];
        [self.machines sortUsingDescriptors:_machineSortDescriptors];
        [self.list reload];
    }
}

- (void)machineWasAdded:(Machine*)m {
#if LOCAL_DEBUG_ENABLED
    DLog(@"MachineManager: Added machine %@", m);
#endif
    
    /* skip to add myPlex or servers we don't own */
    if ([m.machineID isEqualToString:@"myPlex"] || !m.owned)
        return;
    
    [self.machines addObject:m];
    [self.machines sortUsingDescriptors:_machineSortDescriptors];
    [self.list reload];
}

- (void)machine:(Machine*)m receivedInfoForConnection:(MachineConnectionBase*)con updated:(ConnectionInfoType)updateMask {
#if LOCAL_DEBUG_ENABLED
    DLog(@"MachineManager: Received Info For connection %@ from machine %@", con, m);
#endif
}

- (void)machineWasChanged:(Machine*)m {
    if (m == nil) return;
    //something changed, refresh
    [self.list reload];
}

- (void)machine:(Machine*)m changedClientTo:(ClientConnection*)cc {
}

@end
