//
//  BRMenuItem+PlexAccessory.h
//  plex
//
//  Created by Tobias Hieta on 2011-12-27.
//  Copyright (c) 2011 Tobias Hieta. All rights reserved.
//

#import <BackRow/BRMenuItem.h>

typedef enum kPlexAccessoryTypes_t {
    kPlexAccessoryTypeNone,
    kPlexAccessoryTypeFolder,
    kPlexAccessoryTypeShuffle,
    kPlexAccessoryTypeReload,
    kPlexAccessoryTypeLinked,
    kPlexAccessoryTypeLocked,
    kPlexAccessoryTypeSpinner,
    kPlexAccessoryTypeDownload,
    kPlexAccessoryTypeComputer,
    kPlexAccessoryTypeBlank,
    kPlexAccessoryTypeGenius,
    kPlexAccessoryTypeHD,
    kPlexAccessoryTypeStack,
    kPlexAccessoryTypeVolume,
    kPlexAccessoryTypeBlank2,
    kPlexAccessoryTypeLeftUnseen,
    kPlexAccessoryTypeLeftPartialSeen,
    kPlexAccessoryTypeLeftCheckbox,
    kPlexAccessoryTypeLeftGreenPlaylist,
    kPlexAccessoryTypeLeftPurplePlaylist,
    kPlexAccessoryTypeLeftPlaylist,
    kPlexAccessoryTypeLeftGeniusLeft,
    kPlexAccessoryTypeLeftFolder,
    kPlexAccessoryTypeLeftPhoto,
    kPlexAccessoryTypeLeftMosqito,
    kPlexAccessoryTypeLeftPerson,
} kPlexAccessoryTypes;

@interface BRMenuItem (PlexAccessory)

- (void)addAccessoryOfPlexType:(kPlexAccessoryTypes)type;

@end
