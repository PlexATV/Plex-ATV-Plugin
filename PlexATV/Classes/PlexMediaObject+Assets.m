//
//  PlexMediaObject+Assets.m
//  plex
//
//  Created by ccjensen on 03/05/2011.
//

#import "PlexMediaObject+Assets.h"
#import "PlexPreviewAsset.h"
#import "PlexMediaAsset.h"
#import "PlexSongAsset.h"
#import "HWUserDefaults.h"
#import "Constants.h"

@implementation PlexMediaObject (Assets)


#pragma mark -
#pragma mark Assets
- (PlexPreviewAsset *)previewAsset {
    return [[[PlexPreviewAsset alloc] initWithURL:nil mediaProvider:nil mediaObject:self] autorelease];
}

- (PlexMediaAsset *)mediaAsset {
    return [[[PlexMediaAsset alloc] initWithURL:nil mediaProvider:nil mediaObject:self] autorelease];
}

//- (PlexSongAsset *)songAsset {
//    
//}


#pragma mark -
#pragma mark List Items

- (float)heightForMenuItem {
	float height;
	
	if (self.hasMedia || [@"Video" isEqualToString:self.containerType]) {
		height = 70.0f;
	} else {
		height = 0.0f;
	}
	return height;
}

- (BRMenuItem *)menuItem {
    BRMenuItem *menuItem = nil;
    
	if (self.hasMedia || [@"Video" isEqualToString:self.containerType]) {
		menuItem = [[NSClassFromString(@"BRPlayButtonEnabledMenuItem") alloc] init];
        
		if ([self seenState] == PlexMediaObjectSeenStateUnseen) {
            [menuItem setImage:[[BRThemeInfo sharedTheme] unplayedVideoImage]];
		} else if ([self seenState] == PlexMediaObjectSeenStateInProgress) {
            [menuItem setImage:[[BRThemeInfo sharedTheme] partiallyplayedVideoImage]];
		} else {
            //image will be invisible, but we need it to get the text to line up with ones who have a
            //visible image
			[menuItem setImage:[[BRThemeInfo sharedTheme] partiallyplayedVideoImage]];
            BRImageControl *imageControl = [menuItem valueForKey:@"_imageControl"];
            [imageControl setHidden:YES];
		}
        [menuItem setImageAspectRatio:0.5];
		
        //used to get details about the show, instead of gettings attrs here manually
        PlexPreviewAsset *previewAsset = [self previewAsset];
        
		if ([self.type isEqualToString:PlexMediaObjectTypeEpisode]) {
            NSString *setText = [NSString stringWithFormat:@"%@. %@",[previewAsset episodeNumber],[self name]];
            [menuItem setText:setText withAttributes:[[BRThemeInfo sharedTheme] metadataTitleAttributes]];
            [menuItem setRightJustifiedText:[previewAsset datePublishedString] withAttributes:nil];
		} else {
            NSString *detailedText = previewAsset.year ? previewAsset.year : @" ";
            if ([previewAsset isHD]) {
                [menuItem addAccessoryOfType:11];
            }
            [menuItem setDetailedText:detailedText withAttributes:nil];
            [menuItem setText:[self name] withAttributes:nil];
		}
        
    } else {
        //not a media item
        menuItem = [[BRMenuItem alloc] init];
		
		if ([self.type isEqualToString:PlexMediaObjectTypeShow] || [self.type isEqualToString:PlexMediaObjectTypeSeason]) {
			if ([self.attributes valueForKey:@"agent"] == nil) {
				if ([self seenState] == PlexMediaObjectSeenStateUnseen) {
					[menuItem addAccessoryOfType:[SMF_COMPAT usingFourPointThreePlus] ? 16:15];
				} else if ([self seenState] == PlexMediaObjectSeenStateInProgress) {
					[menuItem addAccessoryOfType:[SMF_COMPAT usingFourPointThreePlus] ? 17:16];
				}
			}
		}
		
		[menuItem setText:[self name] withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
		
		[menuItem addAccessoryOfType:1];
	}
	return [menuItem autorelease];
}

- (id)previewControl {
    id preview = nil;
    
    preview = [[SMFMediaPreview alloc] init];
//    preview = [[BRMetadataPreviewControl alloc] init];
    [preview setShowsMetadataImmediately:![[HWUserDefaults preferences] boolForKey:PreferencesViewListPosterZoomingEnabled]];
    [preview setAsset:self.previewAsset];
    
    return [preview autorelease];
}

@end
