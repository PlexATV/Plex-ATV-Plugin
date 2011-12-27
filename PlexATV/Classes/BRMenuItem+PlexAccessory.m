//
//  BRMenuItem+PlexAccessory.m
//  plex
//
//  Created by Tobias Hieta on 2011-12-27.
//  Copyright (c) 2011 Tobias Hieta. All rights reserved.
//

#import "BRMenuItem+PlexAccessory.h"

@implementation BRMenuItem (PlexAccessory)

- (void)addAccessoryOfPlexType:(kPlexAccessoryTypes)type
{
    if ([PLEX_COMPAT usingFourPointThree] && type >= 15) {
        type += 1;
    }
    [self addAccessoryOfType:type];
}

@end
