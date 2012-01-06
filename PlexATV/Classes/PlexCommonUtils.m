//
//  PlexCommonUtils.m
//  plex
//
//  Created by Tobias Hieta on 1/6/12.
//  Copyright (c) 2012 Tobias Hieta. All rights reserved.
//

#import "PlexCommonUtils.h"
#import "HWUserDefaults.h"
#import <plex-oss/Machine.h>
#import <plex-oss/MachineConnectionBase.h>
#import "Constants.h"
#import <plex-oss/PlexMediaContainer.h>
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexDirectory.h>

@implementation PlexCommonUtils

+ (BOOL)machineIsExcluded:(Machine *)m
{
    NSArray *machinesExcludedFromServerList = [[HWUserDefaults preferences] objectForKey:PreferencesMachinesExcludedFromServerList];
    if (!m.owned) return YES;
    if ([machinesExcludedFromServerList containsObject:m.machineID]) return YES;
    return NO;
}


+ (Machine*)findHighPrioLocalMachineWithSections:(BOOL)wantSections
{
    NSArray *machines = [[MachineManager sharedMachineManager] threadSafeMachines];
    NSArray *sortedMachines = [machines sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Machine *m1 = obj1;
        Machine *m2 = obj2;
        
        if ((m1.bestConnection.inLocalNetwork == m2.bestConnection.inLocalNetwork) &&
            ([PlexCommonUtils machineIsExcluded:m1] == [self machineIsExcluded:m2]))
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
            BOOL haveSections = m.librarySections && m.librarySections.directories && [m.librarySections.directories count] > 0;
            
            if (wantSections && haveSections)
                return m;
            if (wantSections)
                continue;
            
            return m;
        }
    }
    
    return nil;
}

+ (NSArray*)allMachinesIOwnSorted
{
    NSArray *allMachines = [[MachineManager sharedMachineManager] threadSafeMachines];
    NSArray *filtered = [allMachines objectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        Machine *m = obj;
        if ([m.machineID isEqualToString:@"myPlex"]) return NO;
        return ((Machine*)obj).owned;
    }];
    NSArray *sorted = [filtered sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Machine *m1 = obj1; Machine *m2 = obj2;
        return [m1.serverName compare:m2.serverName];
    }];
    
    return sorted;
}

+ (NSArray*)allMachinesIOwnWithSections
{
    NSArray *allMachines = [PlexCommonUtils allMachinesIOwnSorted];
    NSArray *filtered = [allMachines objectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        Machine *m = obj;
        if (m.librarySections && m.librarySections.directories && [m.librarySections.directories count] > 0)
            return YES;
        return NO;
    }];
    return filtered;
}

+ (NSArray*)allMovieSections:(PlexMediaContainer*)container
{
    NSArray *allMovieSections = [container.directories objectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        PlexDirectory *dir = obj;
        if ([[dir.attributes objectForKey:@"type"] isEqualToString:@"movie"]) {
            return YES;
        }
        return NO;
    }];
    
    return allMovieSections;
}

+ (NSArray*)allMovieAndTVSections:(PlexMediaContainer*)container
{
    NSArray *allSections = [container.directories objectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        PlexDirectory *dir = obj;
        NSString *type = [dir.attributes objectForKey:@"type"];
        if ([type isEqualToString:@"movie"] || [type isEqualToString:@"show"]) {
            return YES;
        }
        return NO;
    }];
    
    return allSections;
}

+ (PlexDirectory*)findHighPrioMovieSection:(PlexMediaContainer*)container
{
    NSArray *allMovieSections = [PlexCommonUtils allMovieSections:container];
    DLog(@"movie count = %d", [allMovieSections count]);
    if ([allMovieSections count] == 0) return nil;
    
    /* compare the sections order the one with most subobject first
     * if for some reason we have sections with the same number of 
     * subobjects, we compare on name
     */
    NSArray *sorted = [allMovieSections sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        PlexDirectory *d1 = obj1; PlexDirectory *d2 = obj2;
        NSNumber *c1 = [NSNumber numberWithInt:d1.subObjects.count];
        NSNumber *c2 = [NSNumber numberWithInt:d2.subObjects.count];
        NSComparisonResult res = [c1 compare:c2];
        DLog(@"%d compare %d = %d", d1.subObjects.count, d2.subObjects.count, res);
        if (res == NSOrderedSame) return [d1.name compare:d2.name];
        return res;
    }];
    
    return [sorted objectAtIndex:0];
}

@end
