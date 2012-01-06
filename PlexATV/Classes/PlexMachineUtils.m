//
//  PlexMachineUtils.m
//  plex
//
//  Created by Tobias Hieta on 1/6/12.
//  Copyright (c) 2012 Tobias Hieta. All rights reserved.
//

#import "PlexMachineUtils.h"
#import "HWUserDefaults.h"
#import <plex-oss/Machine.h>
#import <plex-oss/MachineConnectionBase.h>
#import "Constants.h"

@implementation PlexMachineUtils

+ (BOOL)machineIsExcluded:(Machine *)m
{
    NSArray *machinesExcludedFromServerList = [[HWUserDefaults preferences] objectForKey:PreferencesMachinesExcludedFromServerList];
    if (!m.owned) return YES;
    if ([machinesExcludedFromServerList containsObject:m.machineID]) return YES;
    return NO;
}


+ (Machine*)findHighPrioLocalMachine
{
    NSArray *machines = [[MachineManager sharedMachineManager] threadSafeMachines];
    NSArray *sortedMachines = [machines sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Machine *m1 = obj1;
        Machine *m2 = obj2;
        
        if ((m1.bestConnection.inLocalNetwork == m2.bestConnection.inLocalNetwork) &&
            ([PlexMachineUtils machineIsExcluded:m1] == [self machineIsExcluded:m2]))
            return NSOrderedSame;
        
        else if ((m1.bestConnection.inLocalNetwork && ![self machineIsExcluded:m1]) ||
                 (m1.bestConnection.inLocalNetwork && !m2.bestConnection.inLocalNetwork && 
                  ![self machineIsExcluded:m1] && [self machineIsExcluded:m2]))
            return NSOrderedAscending;
        else
            return NSOrderedDescending;
        
    }];
    
    for (Machine *m in sortedMachines) {
        if (m.owned) {
            return m;
        }
    }
    
    return nil;
}



@end
