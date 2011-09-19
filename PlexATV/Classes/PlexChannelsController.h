//
//  PlexChannelsController.h
//  plex
//
//  Created by ccjensen on 13/04/2011.
//


#import <Foundation/Foundation.h>
#import <plex-oss/PlexMediaContainer.h>
@class PlexMediaObject;

@interface PlexChannelsController : SMFMediaMenuController {
    PlexMediaContainer *rootContainer;
    PlexMediaObject *playbackItem;
}

@property (readwrite, retain) PlexMediaContainer *rootContainer;
- (void)log:(NSNotificationCenter*)note;

- (id)initWithRootContainer:(PlexMediaContainer*)container;
//list provider
- (float)heightForRow:(long)row;
- (long)itemCount;
- (id)itemForRow:(long)row;
- (BOOL)rowSelectable:(long)selectable;
- (id)titleForRow:(long)row;

@end