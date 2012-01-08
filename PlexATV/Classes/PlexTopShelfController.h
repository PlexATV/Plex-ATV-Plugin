//
//  PlexTopShelfController.h
//  plex
//
//  Created by tomcool
//  Modified by ccjensen
//

#import <Foundation/Foundation.h>
@class PlexMediaContainer;

@interface PlexTopShelfController : NSObject {
    BRTopShelfView *topShelfView;
    BRMediaShelfView *shelfView;
    int shelfItemCount;
    NSTimer *refreshTimer;
}
@property (copy) NSString *containerName;
@property (retain) PlexMediaContainer *mediaContainer;
@property (readonly) id topShelfView;

- (void)selectCategoryWithIdentifier:(id)identifier;
- (void)refresh;
- (void)stopRefresh;

+ (PlexTopShelfController*)sharedPlexTopShelfController;

@end