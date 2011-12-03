//
//  PlexMediaShelfView.m
//  plex
//
//  Created by Tobias Hieta on 8/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PlexMediaShelfView.h"

@implementation PlexMediaShelfView
@synthesize adapter;

- (id)init {
    if ([PLEX_COMPAT usingFourPointThree])
    {
        self = [super init];
    } else {
        self = [[NSClassFromString (@"BRMediaShelfControl")alloc] init];
    }
    if (self) {
    }
    return self;
}

- (id)provider {
    return nil;
}

- (void)dealloc {
    [adapter release];
    [super dealloc];
}

- (void)setProvider:(id)provider {
    if ([PLEX_COMPAT usingFourPointThree])
    {
        DLog(@"Using 4.3+ provider settings!");
        BRProviderDataSourceAdapter *_adapter = [[NSClassFromString (@"BRProviderDataSourceAdapter")alloc] init];
        [_adapter setProviders:[NSArray arrayWithObjects:provider, nil]];
        [self setDelegate:_adapter];
        [self setDataSource:_adapter];
        self.adapter = _adapter;
        [_adapter release];
    } else {
        [(id) self setProvider:provider];
    }
}

- (id)focusedIndexCompat {
    if ([PLEX_COMPAT usingFourPointThree])
    {
        return [self focusedIndexPath];
    } else {
        return [(id) self focusedIndex];
    }
}

- (void)setFocusedIndexCompat:(id)focusedIndexCompat {
    if ([PLEX_COMPAT usingFourPointThree])
    {
        self.focusedIndexPath = focusedIndexCompat;
    } else {
        [(id) self setFocusedIndex:focusedIndexCompat];
    }
}

@end
