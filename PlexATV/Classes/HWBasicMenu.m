

#import "HWBasicMenu.h"
#import "HWPlexDir.h"
#import <plex-oss/MachineManager.h>
#import <plex-oss/Machine.h>
#import <plex-oss/MachineConnectionBase.h>
#import <plex-oss/PlexRequest.h>

@implementation HWBasicMenu


#pragma mark -
#pragma mark Object/Class Lifecycle
- (id)init {
    if( (self = [super init]) != nil ) {

        //DLog(@"--- %@ %s", self, _cmd);

        [self setListTitle:@"Server List"];

        BRImage *sp = [[BRThemeInfo sharedTheme] gearImage];

        [self setListIcon:sp horizontalOffset:0.0 kerningFactor:0.15];

        _ownServer = [[NSMutableArray alloc] init];
        _sharedServers = [[NSMutableArray alloc] init];

        //start the auto detection
        [[self list] setDatasource:self];
    }
    return (self);
}

- (void)dealloc {
    //DLog(@"--- %@ %s", self, _cmd);
    [_ownServer release];
    [_sharedServers release];

    [super dealloc];
}

- (void)updateDivider
{
    [self.list removeDividers];
    [self.list addDividerAtIndex:0 withLabel:@"Your servers"];
    if ([_sharedServers count] > 0) 
        [self.list addDividerAtIndex:[_ownServer count] withLabel:@"Shared servers"];
}

- (NSArray*)combinedServers
{
    NSMutableArray *combo = [NSMutableArray arrayWithArray:_ownServer];
    [combo addObjectsFromArray:_sharedServers];
    return combo;
}

- (NSArray*)properlySortedMachineList:(NSArray*)unsortedList
{
    NSArray *sortedList = [unsortedList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Machine *m1 = (Machine*)obj1; Machine *m2 = (Machine*)obj2;
        return [m1.serverName compare:m2.serverName];
    }];
    return sortedList;
}

#pragma mark -
#pragma mark Controller Lifecycle behaviour
- (void)wasPushed {
    DLog();
    [[MachineManager sharedMachineManager] setMachineStateMonitorPriority:YES];
    [[ProxyMachineDelegate shared] registerDelegate:self];
    [super wasPushed];
}

- (void)wasPopped {
    DLog();
    [[ProxyMachineDelegate shared] removeDelegate:self];
    [super wasPopped];
}

- (void)wasExhumed {
    DLog();
    [[MachineManager sharedMachineManager] setMachineStateMonitorPriority:YES];
    [super wasExhumed];
}

- (void)wasBuried {
    [super wasBuried];
}


- (id)previewControlForItem:(long)item {
    SMFBaseAsset *asset = [[SMFBaseAsset alloc] init];

    Machine *m = [self.combinedServers objectAtIndex:item];
    
    NSString *logo = @"PmsLogo";
#if 0
    if ([m.bestConnection.type isEqualToString:@"myPlex"])
        logo = @"MyPlexLogo";
#endif

    [asset setCoverArt:[BRImage imageWithPath:[[NSBundle bundleForClass:[HWBasicMenu class]] pathForResource:logo ofType:@"png"]]];
    [asset setTitle:m.hostName];
    
    if (m.bestConnection) {
        NSString *detailedText = [NSString stringWithFormat:@"%@ server at IP: %@, version: %@ via connection type: %@", 
                                  m.bestConnection.inLocalNetwork ? @"Local": @"Remote", m.bestConnection.ip,
                                  m.bestConnection.versionStr, m.bestConnection.type];
        [asset setSummary:detailedText];
    } else {
        [asset setSummary:@"No bestConnection here"];
    }
    
    SMFMediaPreview *p = [[SMFMediaPreview alloc] init];
    p.asset = asset;
    p.showsMetadataImmediately = YES;
    [asset release];
    
    return p;
}

- (BOOL)shouldRefreshForUpdateToObject:(id)object {
    return YES;
}

- (void)itemSelected:(long)selected {
    if (selected < 0 || selected >= self.combinedServers.count) return;
    Machine *m = [self.combinedServers objectAtIndex:selected];
    DLog(@"machine selected: %@", m);

    HWPlexDir *menuController = [[HWPlexDir alloc] initWithRootContainer:[m.request rootLevel] andTabBar:nil];
    //menuController.rootContainer = [m.request rootLevel];
    [[[BRApplicationStackManager singleton] stack] pushController:menuController];
    [menuController release];
}

- (float)heightForRow:(long)row {
    return 50.0f;
}

- (long)itemCount {
    return self.combinedServers.count;
}

- (id)itemForRow:(long)row {
    if (row >= [self.combinedServers count] || row < 0)
        return nil;

    BRMenuItem *result = [[BRMenuItem alloc] init];
    Machine *m = [self.combinedServers objectAtIndex:row];
    NSString *name = [NSString stringWithFormat:@"%@", m.serverName, m];
    [result setText:name withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
    [result addAccessoryOfPlexType:m.hostName ? kPlexAccessoryTypeComputer : kPlexAccessoryTypeNone];
    [result setDetailedText:m.owner withAttributes:nil];


    return [result autorelease];
}

- (BOOL)rowSelectable:(long)selectable {
    return TRUE;
}

- (id)titleForRow:(long)row {
    if (row >= [self.combinedServers count] || row < 0)
        return @"";
    Machine *m = [self.combinedServers objectAtIndex:row];
    return m.serverName;
}

- (void)setNeedsUpdate {
    DLog(@"Updating UI");
    //  [self updatePreviewController];
    //	[self refreshControllerForModelUpdate];
    [self.list reload];
}

#pragma mark
#pragma mark Machine Manager Delegate
- (void)machineWasRemoved:(Machine*)m {
    DLog(@"Removed %@", m);
    if ([_ownServer containsObject:m])
        [_ownServer removeObject:m];
    if ([_sharedServers containsObject:m])
        [_sharedServers removeObject:m];
    
    [self updateDivider];
}

- (void)machineWasAdded:(Machine*)m {
    DLog();

    if ( !runsServer(m.role) ) return;
    if ([self.combinedServers containsObject:m]) return;
    
    /* skip myPlex in server list */
    if ([m.machineID isEqualToString:@"myPlex"]) return;
    
    DLog();

    if (m.owned) {
        NSMutableArray *unsorted = [_ownServer mutableCopy];
        [unsorted addObject:m];
        [_ownServer removeAllObjects];
        [_ownServer addObjectsFromArray:[self properlySortedMachineList:unsorted]];
        [unsorted release];
    }
    else {
        NSMutableArray *unsorted = [_sharedServers mutableCopy];
        [unsorted addObject:m];
        [_sharedServers removeAllObjects];
        [_sharedServers addObjectsFromArray:[self properlySortedMachineList:unsorted]];
        [unsorted release];
    }
    DLog(@"Added %@", m);

    //[m resolveAndNotify:self];
    [self updateDivider];
    [self setNeedsUpdate];
}

- (void)machineWasChanged:(Machine*)m {
    if (m == nil) return;

    if (runsServer(m.role) && ![self.combinedServers containsObject:m]) {
        [self machineWasAdded:m];
        return;
    } else if (!runsServer(m.role) && [self.combinedServers containsObject:m]) {
        [self machineWasRemoved:m];
        DLog(@"Removed %@", m);
    } else {
        DLog(@"Changed %@", m);
    }

    [self setNeedsUpdate];
}

- (void)machine:(Machine*)m receivedInfoForConnection:(MachineConnectionBase*)con {
}

- (void)machine:(Machine*)m changedClientTo:(ClientConnection*)cc {
}
@end
