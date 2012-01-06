//
//  NSObject+NSArray_ObjectFilter.h
//  plex
//
//  Created by Tobias Hieta on 1/6/12.
//  Copyright (c) 2012 Tobias Hieta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (ObjectFilter)

- (NSArray*)objectsPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;

@end
