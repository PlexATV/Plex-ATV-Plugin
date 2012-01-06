//
//  PlexMachineUtils.h
//  plex
//
//  Created by Tobias Hieta on 1/6/12.
//  Copyright (c) 2012 Tobias Hieta. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Machine;

@interface PlexMachineUtils : NSObject

+ (Machine*)findHighPrioLocalMachine;
+ (BOOL)machineIsExcluded:(Machine *)m;

@end
