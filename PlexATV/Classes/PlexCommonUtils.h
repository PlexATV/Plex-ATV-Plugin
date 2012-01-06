//
//  PlexCommonUtils.h
//  plex
//
//  Created by Tobias Hieta on 1/6/12.
//  Copyright (c) 2012 Tobias Hieta. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Machine, PlexDirectory, PlexMediaContainer;

@interface PlexCommonUtils : NSObject

+ (Machine*)findHighPrioLocalMachineWithSections:(BOOL)wantSections;
+ (BOOL)machineIsExcluded:(Machine *)m;
+ (NSArray*)allMachinesIOwnSorted;
+ (NSArray*)allMachinesIOwnWithSections;
+ (PlexDirectory*)findHighPrioMovieSection:(PlexMediaContainer*)container;
+ (NSArray*)allMovieSections:(PlexMediaContainer*)container;
+ (NSArray*)allMovieAndTVSections:(PlexMediaContainer*)container;

@end
