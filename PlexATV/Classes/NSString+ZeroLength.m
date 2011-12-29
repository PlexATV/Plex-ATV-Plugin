//
//  NSString+ZeroLength.m
//  plex
//
//  Created by Tobias Hieta on 2011-12-28.
//  Copyright (c) 2011 Tobias Hieta. All rights reserved.
//

#import "NSString+ZeroLength.h"

@implementation NSString (ZeroLength)

- (BOOL)isZeroLength
{
    if (self == nil)
        return YES;
    
    if ([self length] == 0)
        return YES;
    
    return NO;
}

@end
