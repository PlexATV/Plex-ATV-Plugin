//
//  NSArray+ObjectFilter.m
//  plex
//
//  Created by Tobias Hieta on 1/6/12.
//  Copyright (c) 2012 Tobias Hieta. All rights reserved.
//

#import "NSArray+ObjectFilter.h"

@implementation NSArray (ObjectFilter)

- (NSArray*)objectsPassingTest:(BOOL (^)(id, NSUInteger, BOOL *))predicate
{
    NSIndexSet *indexSet = [self indexesOfObjectsPassingTest:predicate];
    return [self objectsAtIndexes:indexSet];
}

@end
