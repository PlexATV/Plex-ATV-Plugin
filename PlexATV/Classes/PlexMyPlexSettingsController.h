//
//  PlexMyPlexSettingsController.h
//  plex
//
//  Created by Tobias Hieta on 2011-12-14.
//  Copyright (c) 2011 Tobias Hieta. All rights reserved.
//

@interface PlexMyPlexSettingsController : SMFMediaMenuController
{
    long currentItem;
    NSString *password;
}

@property (retain) NSString *password;

- (void)setupList;
- (void)sendLoginDetailsInBackground;
@end
