//
//  HWPlexDir.m
//  atvTwo
//
//  Created by Frank Bauer on 22.10.10.
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//  

#import "HWPlexDir.h"
#import "Constants.h"
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexMediaContainer.h>
#import <plex-oss/PlexImage.h>
#import <plex-oss/PlexRequest.h>
#import <plex-oss/Preferences.h>
#import "PlexMediaProvider.h"
#import "PlexMediaAsset.h"
#import "PlexMediaAssetOld.h"
#import "PlexPreviewAsset.h"
#import "PlexSongAsset.h"
#import "SongListController.h"
#import "HWUserDefaults.h"
#import "HWMediaGridController.h"
#import "HWDetailedMovieMetadataController.h"
#import "PlexPlaybackController.h"

#define LOCAL_DEBUG_ENABLED 1

@implementation HWPlexDir
@synthesize rootContainer;


#pragma mark -
#pragma mark Object/Class Lifecycle
- (id) init
{
	if((self = [super init]) != nil) {
		[self setListTitle:@"PLEX"];
		
		NSString *settingsPng = [[NSBundle bundleForClass:[HWPlexDir class]] pathForResource:@"PlexIcon" ofType:@"png"];
		BRImage *sp = [BRImage imageWithPath:settingsPng];
		
		[self setListIcon:sp horizontalOffset:0.0 kerningFactor:0.15];
		
		rootContainer = nil;
		[[self list] setDatasource:self];
		return ( self );
		
	}
	
	return ( self );
}

- (id) initWithRootContainer:(PlexMediaContainer*)container {
	self = [self init];
	self.rootContainer = [self applySkipFilteringOnContainer:container];
	return self;
}

- (PlexMediaContainer*) applySkipFilteringOnContainer:(PlexMediaContainer*)container {
	PlexMediaContainer *pmc = container;
	
	BOOL skipFilteringOptionsMenu = [[HWUserDefaults preferences] boolForKey:PreferencesViewEnableSkipFilteringOptionsMenu];
	DLog(@"skipFilteringOption: %@", skipFilteringOptionsMenu ? @"YES" : @"NO");
	
	if (pmc.sectionRoot && !pmc.requestsMessage && skipFilteringOptionsMenu) { 
		//open "/library/section/x/all or the first item in the list"
		//bypass the first filter node
		
		/*
		 at some point wou will present the user a selection for the available filters, right?
		 when the user selects one, you should write to that preference so next time user comes back
		 ATV will use the last filter
		 */
		//[PlexPrefs defaultPreferences] filterForSection]
		Machine *currentMachine = rootContainer.request.machine;
		const NSString* filter = [currentMachine filterForSection:pmc.key];
		BOOL handled = NO;
		PlexMediaContainer* new_pmc = nil;
		
		for(PlexMediaObject* po in pmc.directories){
			DLog(@"%@: %@ == %@", pmc.key, po.lastKeyComponent, filter);
			if ([filter isEqualToString:po.lastKeyComponent]){
				PlexMediaContainer* my_new_pmc = [po contents];
				if (my_new_pmc.directories.count>0) new_pmc = my_new_pmc;
				handled = YES;
				break;
			}
		}
		
		DLog(@"handled: %@", handled ? @"YES" : @"NO");
		if (handled && new_pmc==nil) new_pmc = [[pmc.directories objectAtIndex:0] contents];
		if (new_pmc==nil || new_pmc.directories.count==0){
			for(PlexMediaObject* po in pmc.directories){
				PlexMediaContainer* my_new_pmc = [po contents];
				if (my_new_pmc.directories.count>0) {
					new_pmc = my_new_pmc;
					handled = YES;
					break;
				}
			}
		}
		
		if (new_pmc) {
			pmc = new_pmc;
		}
		
		if (!handled && pmc.directories.count>0) pmc = [[pmc.directories objectAtIndex:0] contents];
	}
	DLog(@"done filtering");
	return pmc;
}

- (void)log:(NSNotificationCenter *)note {
	DLog(@"note = %@", note);
}

-(void)dealloc
{
	DLog(@"deallocing HWPlexDir");
	[playbackItem release];
	[rootContainer release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark Controller Lifecycle behaviour
- (void)wasPushed {
	[[MachineManager sharedMachineManager] setMachineStateMonitorPriority:NO];
	[super wasPushed];
}

- (void)wasPopped {
	[super wasPopped];
}

- (void)wasExhumed {
	[[MachineManager sharedMachineManager] setMachineStateMonitorPriority:NO];
	[super wasExhumed];
}

- (void)wasBuried {
	[super wasBuried];
}


//handle custom event
-(BOOL)brEventAction:(BREvent *)event
{
	int remoteAction = [event remoteAction];
	if ([(BRControllerStack *)[self stack] peekController] != self)
		remoteAction = 0;
	
	int itemCount = [[(BRListControl *)[self list] datasource] itemCount];
	switch (remoteAction)
	{
		case kBREventRemoteActionSelectHold: {
			if([event value] == 1) {
				//get the index of currently selected row
				long selected = [self getSelection];
				[self showModifyViewedStatusViewForRow:selected];
			}
			break;
		}
		case kBREventRemoteActionSwipeLeft:
		case kBREventRemoteActionLeft:
			return YES;
			break;
		case kBREventRemoteActionSwipeRight:
		case kBREventRemoteActionRight:
			return YES;
			break;
		case kBREventRemoteActionPlayPause:
			DLog(@"play/pause event");
			if([event value] == 1)
				[self playPauseActionForRow:[self getSelection]];
			
			
			return YES;
			break;
		case kBREventRemoteActionUp:
		case kBREventRemoteActionHoldUp:
			if([self getSelection] == 0 && [event value] == 1)
			{
				[self setSelection:itemCount-1];
				return YES;
			}
			break;
		case kBREventRemoteActionDown:
		case kBREventRemoteActionHoldDown:
			if([self getSelection] == itemCount-1 && [event value] == 1)
			{
				[self setSelection:0];
				return YES;
			}
			break;
	}
	return [super brEventAction:event];
}

- (id)previewControlForItem:(long)item
{
    
	PlexMediaObject* pmo = [rootContainer.directories objectAtIndex:item];
    
#if LOCAL_DEBUG_ENABLED
	DLog(@"media object: %@", pmo);
#endif	
    
	NSURL* mediaURL = [pmo mediaStreamURL];
	PlexPreviewAsset* pma = [[PlexPreviewAsset alloc] initWithURL:mediaURL mediaProvider:nil mediaObject:pmo];
	BRMetadataPreviewControl *preview =[[BRMetadataPreviewControl alloc] init];
	[preview setShowsMetadataImmediately:[[HWUserDefaults preferences] boolForKey:PreferencesViewDisablePosterZoomingInListView]];
	[preview setAsset:pma];
    [pma release];
	
	return [preview autorelease];
}

#define ModifyViewStatusOptionDialog @"ModifyViewStatusOptionDialog"

- (void)itemSelected:(long)selected; {
	PlexMediaObject* pmo = [rootContainer.directories objectAtIndex:selected];
	
	NSString* type = [pmo.attributes objectForKey:@"type"];
	if ([type empty]) type = pmo.containerType;
	type = [type lowercaseString];
    
    NSString *viewTypeSetting = [[HWUserDefaults preferences] objectForKey:PreferencesViewTypeSetting];
	
	//DLog(@"Item Selected: %@, type:%@", pmo.debugSummary, type);
	
	//DLog(@"viewgroup: %@, viewmode:%@",pmo.mediaContainer.viewGroup, pmo.containerType);
	
	if ([PlexViewGroupAlbum isEqualToString:pmo.mediaContainer.viewGroup] || [@"albums" isEqualToString:pmo.mediaContainer.content] || [@"playlists" isEqualToString:pmo.mediaContainer.content]) {
		DLog(@"Accessing Artist/Album %@", pmo);
		SongListController *songlist = [[SongListController alloc] initWithPlexContainer:[pmo contents] title:pmo.name];
		[[[BRApplicationStackManager singleton] stack] pushController:songlist];
		[songlist autorelease];
	}
	else if (pmo.hasMedia || [@"Video" isEqualToString:pmo.containerType] || [@"Track" isEqualToString:pmo.containerType]){
#if LOCAL_DEBUG_ENABLED
		DLog(@"got some media, switching to PlexPlaybackController");
#endif
		PlexPlaybackController *player = [[PlexPlaybackController alloc] initWithPlexMediaObject:pmo];
		//[player startPlaying];
		[[[BRApplicationStackManager singleton] stack] pushController:player];
    [player release];
	}
    else if ([@"movie" isEqualToString:type] && [viewTypeSetting isEqualToString:@"Grid"]) {
		[self showGridListControl:[pmo contents]];
	}
	else 
    {
		HWPlexDir* menuController = [[HWPlexDir alloc] initWithRootContainer:[pmo contents]];
		[[[BRApplicationStackManager singleton] stack] swapController:menuController];
		
		[menuController autorelease];
	}
}

- (void)showGridListControl:(PlexMediaContainer*)movieCategory {
	PlexMediaObject *recent=nil;
	PlexMediaObject *allMovies=nil;
    //DLog(@"showGridListControl_movieCategory_directories: %@", movieCategory.directories);
	if (movieCategory.directories > 0) {
		NSUInteger i, count = [movieCategory.directories count];
		for (i = 0; i < count; i++) {
			PlexMediaObject * obj = [movieCategory.directories objectAtIndex:i];
			NSString *key = [obj.attributes objectForKey:@"key"];
			//DLog(@"obj_type: %@",key);
			if ([key isEqualToString:@"all"])
				allMovies = obj;
			else if ([key isEqualToString:@"recentlyAdded"])
				recent = obj;
		}
	}
	
	if (recent && allMovies){
		DLog(@"pushing shelfController");
		HWMediaGridController *shelfController = [[HWMediaGridController alloc] initWithPlexAllMovies:[allMovies contents] andRecentMovies:[recent contents]];
		[[[BRApplicationStackManager singleton] stack] pushController:[shelfController autorelease]];
	}
	
}

- (void)showModifyViewedStatusViewForRow:(long)row {
    //get the currently selected row
	PlexMediaObject* pmo = [rootContainer.directories objectAtIndex:row];
	NSString *plexMediaObjectType = [pmo.attributes valueForKey:@"type"];
	
	DLog(@"HERE: %@", plexMediaObjectType);
	
	if (pmo.hasMedia 
		|| [@"Video" isEqualToString:pmo.containerType]
		|| [@"show" isEqualToString:plexMediaObjectType]
		|| [@"season" isEqualToString:plexMediaObjectType]) {
		//show dialog box
		BROptionDialog *optionDialogBox = [[BROptionDialog alloc] init];
		[optionDialogBox setIdentifier:ModifyViewStatusOptionDialog];
		
		[optionDialogBox setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:
									  pmo, @"mediaObject",
									  nil]];
		
		[optionDialogBox setPrimaryInfoText:@"Modify View Status"];
		[optionDialogBox setSecondaryInfoText:pmo.name];
		
		
		NSString *watchOption = nil;
		NSString *unwatchOption = nil;
		if (pmo.hasMedia || [@"Video" isEqualToString:pmo.containerType]) {
			//modify single media item
			watchOption = @"Mark as Watched";
			unwatchOption = @"Mark as Unwatched";
		} else if (!pmo.hasMedia && [@"show" isEqualToString:plexMediaObjectType]) {
			//modify all seasons within show
			watchOption = @"Mark entire show as Watched";
			unwatchOption = @"Mark entire show as Unwatched";
		} else if (!pmo.hasMedia && [@"season" isEqualToString:plexMediaObjectType]) {
			//modify all episodes within season
			watchOption = @"Mark entire season as Watched";
			unwatchOption = @"Mark entire season as Unwatched";
		}
		
		[optionDialogBox addOptionText:watchOption];
		[optionDialogBox addOptionText:unwatchOption];
		[optionDialogBox addOptionText:@"Go back"];
		[optionDialogBox setActionSelector:@selector(optionSelected:) target:self];
		[[self stack] pushController:optionDialogBox];
		[optionDialogBox autorelease];
	}
}

- (void)optionSelected:(id)sender {
	BROptionDialog *option = sender;
	PlexMediaObject *pmo = [option.userInfo objectForKey:@"mediaObject"];
	if ([option.identifier isEqualToString:ModifyViewStatusOptionDialog]) {		
		if([[sender selectedText] hasSuffix:@"Watched"]) {
			//mark item(s) as watched
			[[[BRApplicationStackManager singleton] stack] popController]; //need this so we don't go back to option dialog when going back
			DLog(@"Marking as watched: %@", pmo.name);
            [pmo markSeen];
            [self.list reload];
		} else if ([[sender selectedText] hasSuffix:@"Unwatched"]) {
			//mark item(s) as unwatched
			[[self stack] popController]; //need this so we don't go back to option dialog when going back
			DLog(@"Marking as unwatched: %@", pmo.name);
			[pmo markUnseen];
			[self.list reload];
		} else if ([[sender selectedText] isEqualToString:@"Go back"]) {
			//go back to movie listing...
			[[[BRApplicationStackManager singleton] stack] popController];
		}
	}
}




- (float)heightForRow:(long)row {	
	float height;
	
	PlexMediaObject *pmo = [rootContainer.directories objectAtIndex:row];
	if (pmo.hasMedia || [@"Video" isEqualToString:pmo.containerType]) {
		height = 70.0f;
	} else {
		height = 0.0f;
	}
	return height;
}

- (long)itemCount {
	return [rootContainer.directories count];
}

- (id)itemForRow:(long)row {
	if(row > [rootContainer.directories count])
		return nil;
	
	id result;
	
	PlexMediaObject *pmo = [rootContainer.directories objectAtIndex:row];
	NSString *mediaType = [pmo.attributes valueForKey:@"type"];
    
	if (pmo.hasMedia || [@"Video" isEqualToString:mediaType]) {
		BRMenuItem *menuItem = [[NSClassFromString(@"BRPlayButtonEnabledMenuItem") alloc] init];
        
		if ([pmo seenState] == PlexMediaObjectSeenStateUnseen) {
            [menuItem setImage:[[BRThemeInfo sharedTheme] unplayedVideoImage]];
		} else if ([pmo seenState] == PlexMediaObjectSeenStateInProgress) {
            [menuItem setImage:[[BRThemeInfo sharedTheme] partiallyplayedVideoImage]];
		} else {
            //image will be invisible, but we need it to get the text to line up with ones who have a
            //visible image
			[menuItem setImage:[[BRThemeInfo sharedTheme] partiallyplayedVideoImage]];
            BRImageControl *imageControl = [menuItem valueForKey:@"_imageControl"];
            [imageControl setHidden:YES];
		}
        [menuItem setImageAspectRatio:0.5];
		
        [menuItem setText:[pmo name] withAttributes:nil];
		//used to get details about the show, instead of gettings attrs here manually
		PlexPreviewAsset *previewData = [[PlexPreviewAsset alloc] initWithURL:nil mediaProvider:nil mediaObject:pmo];
		if ([mediaType isEqualToString:PlexMediaObjectTypeEpisode]) {
            NSString *detailedText = [NSString stringWithFormat:@"%@, Season %d, Episode %d",[previewData seriesName] ,[previewData season],[previewData episode]];
			[menuItem setDetailedText:detailedText withAttributes:nil];
            [menuItem setRightJustifiedText:[previewData datePublishedString] withAttributes:nil];
		} else {
            NSString *detailedText = previewData.year ? previewData.year : @" ";
			[menuItem setDetailedText:detailedText withAttributes:nil];
            if ([previewData isHD]) {
                [menuItem addAccessoryOfType:11];
            }
		}
		[previewData release];
		
		result = [menuItem autorelease];
    } else {
		BRMenuItem * menuItem = [[BRMenuItem alloc] init];
		
		if ([mediaType isEqualToString:PlexMediaObjectTypeShow] || [mediaType isEqualToString:PlexMediaObjectTypeSeason]) {
			if ([pmo.attributes valueForKey:@"agent"] == nil) {
				if ([pmo seenState] == PlexMediaObjectSeenStateUnseen) {
					[menuItem addAccessoryOfType:15];
				} else if ([pmo seenState] == PlexMediaObjectSeenStateInProgress) {
					[menuItem addAccessoryOfType:16];
				}
			}
		}
		
		[menuItem setText:[pmo name] withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
		
		[menuItem addAccessoryOfType:1];
		result = [menuItem autorelease];
	}
	return result;
}

- (BOOL)rowSelectable:(long)selectable {
	return TRUE;
}

- (id)titleForRow:(long)row {
	PlexMediaObject *pmo = [rootContainer.directories objectAtIndex:row];
	return pmo.name;
}

@end
