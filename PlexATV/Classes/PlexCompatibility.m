//
//  PlexCompatibility.m
//  plex
//
//  Created by bob on 2011-11-27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

//  BASED ON:
//  SMFCompatibility.m
//  SMFramework
//
//  Created by Thomas Cool on 7/13/11.
//  Copyright 2011 tomcool.org. All rights reserved.
//

#import "PlexCompatibility.h"

@implementation PlexCompatibility


SYNTHESIZE_SINGLETON_FOR_CLASS(PlexCompatibility, compat)
- (id)init {
    self = [super init];
    if (self != nil) {
        Class cls = NSClassFromString(@"ATVVersionInfo");

        _usingFourPointFour = NO;
        _usingFourPointThree = NO;
        _usingFourPointTwo = NO;
        if (cls != nil && [[cls currentOSVersion] isEqualToString:@"4.2"]) {
            _usingFourPointTwo = YES;
        }
        if (cls != nil && [[cls currentOSVersion] isEqualToString:@"4.3"]) {
            _usingFourPointTwo = YES;
            _usingFourPointThree = YES;
        }
        if (cls != nil && [[cls currentOSVersion] rangeOfString:@"5."].location != NSNotFound) {
            _usingFourPointTwo = YES;
            _usingFourPointThree = YES;
            _usingFourPointFour = YES;
        }
    }
    return self;
}
- (BOOL)usingFourPointTwo {
    return _usingFourPointTwo;
}
- (BOOL)usingFourPointThree {
    return _usingFourPointThree;
}
- (BOOL)usingFourPointFour {
    return _usingFourPointFour;
}
@end

