//
//  HWDetailedMovieMetadataController.m
//  atvTwo
//
//  Created by ccjensen on 2/7/11.
//
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

#define LOCAL_DEBUG_ENABLED 1

#import "PlexPreplayController.h"
#import "PlexMediaProvider.h"
#import "PlexNavigationController.h"
#import "PlexAudioSubsController.h"
#import <plex-oss/PlexRequest.h>
#import <plex-oss/PlexMediaObject + VideoDetails.h>
#import <plex-oss/PlexImage.h>
#import <plex-oss/PlexMedia.h>
#import "PlexMediaObject+Assets.h"
#import "PlexPreviewAsset.h"
#import "PlexControlFactory.h"
#import "PlexMoreInfoController.h"
#import "HWUserDefaults.h"
#import "Constants.h"

//these are in the AppleTV.framework, but cannot #import <AppleTV/AppleTV.h> due to
//naming conflicts with Backrow.framework. below is a hack!
@interface BRThemeInfo (PlexExtentions)
- (id)ccBadge;
- (id)hdPosterBadge;
- (id)dolbyDigitalBadge;
- (id)moreActionImage;
@end

typedef enum {
    kPreviewButton = 0,
    kPlayButton,
    kAudioSubsButton,
    kMoreButton
} ActionButton;

@implementation PlexPreplayController
@synthesize relatedMediaContainer;
@synthesize selectedMediaObject;

#pragma mark -
#pragma mark Object/Class Lifecycle
- (id)init {
    self = [super init];
    if (self) {
        self.datasource = self;
        self.delegate = self;

        //create the popup
        listDropShadowControl = [[SMFListDropShadowControl alloc] init];
        [listDropShadowControl setCDelegate:self];
        [listDropShadowControl setCDatasource:self];
        cachedFlags = nil;
        
        buttonIndex = 0;
    }
    return self;
}

- (id)initWithPlexMediaObject:(PlexMediaObject*)aMediaObject {
    self = [self init];
    if (self) {
        self.selectedMediaObject = aMediaObject;
        self.relatedMediaContainer = self.selectedMediaObject.mediaContainer;
        currentSelectedIndex = [self.relatedMediaContainer.directories indexOfObject:self.selectedMediaObject];
#if LOCAL_DEBUG_ENABLED
        DLog(@"init with media object:%@", self.selectedMediaObject);
#endif
    }
    return self;
}

- (void)dealloc {
    self.selectedMediaObject = nil;
    self.relatedMediaContainer = nil;
    self.datasource = nil;
    self.delegate = nil;
    cachedFlags = nil;

    [listDropShadowControl release];
    DLog(@"********** PlexPrePlayController is dealloced");
    [super dealloc];
}

- (void)changeMetadataViewToShowDataForIndex:(int)newIndex {
    //check that it is a new one, otherwise don't refresh
    if (currentSelectedIndex != newIndex) {
        //set both focused and selected to the new index
        currentSelectedIndex = newIndex;
        lastFocusedIndex = newIndex;
        shelfCtrl.focusedIndexCompat = (id)newIndex;
        self.selectedMediaObject = [self.relatedMediaContainer.directories objectAtIndex:currentSelectedIndex];
        cachedFlags = nil;
        //move the shelf if needed to show the new item
        [shelfCtrl _scrollIndexToVisible:currentSelectedIndex];
        //refresh metadata, but don't touch the shelf
        [self reload];
    }
}


#pragma mark -
#pragma mark Controller Lifecycle behaviour
- (void)wasPushed {
    [[MachineManager sharedMachineManager] setMachineStateMonitorPriority:NO];
    [super wasPushed];
}

- (void)wasPopped {
    DLog(@"PlexPreplayController - was popped!");
    self.datasource = nil;
    self.delegate = nil;
    self.selectedMediaObject = nil;
    self.relatedMediaContainer = nil;
    cachedFlags = nil;

    [listDropShadowControl setCDelegate:nil];
    [listDropShadowControl setCDatasource:nil];

    [super wasPopped];
}

- (void)wasExhumed {
    [[MachineManager sharedMachineManager] setMachineStateMonitorPriority:NO];
    [super wasExhumed];
    [shelfCtrl _scrollIndexToVisible:currentSelectedIndex];
    [self reload];
}

- (void)wasBuried {
    [super wasBuried];
}

- (void)controlWasActivated {
    if (moreInfoSelected) {
        CATransition *transition = [CATransition animation];
        transition.type = @"push";
        transition.subtype = kCATransitionFromTop;
        transition.duration = 0.4f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [[[BRApplicationStackManager singleton] stack] setActions:[NSDictionary dictionaryWithObject:transition forKey:@"sublayers"]];

        moreInfoSelected = NO;
    }
    [super controlWasActivated];
}


#pragma mark -
#pragma mark Delegate Methods
#define ArrowSwitchDelay 0.7f

- (BOOL)controllerCanSwitchToPrevious:(SMFMoviePreviewController*)c {
    return YES;
}

- (void)controllerSwitchToPrevious:(SMFMoviePreviewController*)ctrl {
    [ctrl switchPreviousArrowOn];
    [ctrl performSelector:@selector(switchPreviousArrowOff)withObject:nil afterDelay:ArrowSwitchDelay];

    [[SMFThemeInfo sharedTheme] playNavigateSound];
    int newIndex;
    if (currentSelectedIndex - 1 < 0) {
        //we have reached the beginning, loop around
        newIndex = [self.relatedMediaContainer.directories count] - 1;
    } else {
        //go to previous one
        newIndex = currentSelectedIndex - 1;
    }
#if LOCAL_DEBUG_ENABLED
    DLog(@"switching from item %d to previous one %d", currentSelectedIndex, newIndex);
#endif
    lastFocusedIndex = newIndex;
    [self changeMetadataViewToShowDataForIndex:lastFocusedIndex];
    [self setFocusedControl:[self._buttons objectAtIndex:0]];
}

- (BOOL)controllerCanSwitchToNext:(SMFMoviePreviewController*)c {
    return YES;
}

- (void)doneReloading
{
    DLog();
    if (buttonIndex < 3) {
        [self setFocusedControl:[self._buttons objectAtIndex:buttonIndex]];
    }
}

- (void)controllerSwitchToNext:(SMFMoviePreviewController*)ctrl {
    [ctrl switchNextArrowOn];
    [ctrl performSelector:@selector(switchNextArrowOff)withObject:nil afterDelay:ArrowSwitchDelay];

    [[SMFThemeInfo sharedTheme] playNavigateSound];
    int newIndex;
    if (currentSelectedIndex + 1 < [self.relatedMediaContainer.directories count]) {
        //go to next one
        newIndex = currentSelectedIndex + 1;
    } else {
        //we have reached the end, loop around
        newIndex = 0;
    }
#if LOCAL_DEBUG_ENABLED
    DLog(@"switching from item %d to next one %d", currentSelectedIndex, newIndex);
#endif
    lastFocusedIndex = newIndex;
    [self changeMetadataViewToShowDataForIndex:lastFocusedIndex];
    [self setFocusedControl:[self._buttons lastObject]];

}

- (void)controller:(SMFMoviePreviewController*)c selectedControl:(BRControl*)ctrl {
#if LOCAL_DEBUG_ENABLED
    DLog(@"controller selected %@", ctrl);
#endif

    if ([ctrl isKindOfClass:[BRButtonControl class]]) {
        //one of the buttons have been pushed
        BRButtonControl *buttonControl = (BRButtonControl*)ctrl;
#if LOCAL_DEBUG_ENABLED
        DLog(@"button chosen: %@", buttonControl.identifier);
#endif

        int buttonId = [buttonControl.identifier intValue];
        switch (buttonId) {
            case kPlayButton: {
                DLog(@"initiate movie playback");
                [[PlexNavigationController sharedPlexNavigationController] initiatePlaybackOfMediaObject:self.selectedMediaObject];
                buttonIndex = 0;
                break;
            }
            case kMoreButton: {
                [listDropShadowControl addToController:self]; //show popup for marking movie as watched/unwatched
                buttonIndex = 1;
                break;
            }
            case kAudioSubsButton: {
                PlexAudioSubsController *subCtrl = [[PlexAudioSubsController alloc] initWithMediaObject:self.selectedMediaObject];
                [[[BRApplicationStackManager singleton] stack] pushController:subCtrl];
                buttonIndex = 2;
                [subCtrl release];
            }
            default:
                break;
        }

        //none of the buttons do anything, make error sound for now
        [[SMFThemeInfo sharedTheme] playErrorSound];

    } else if (ctrl == self.shelfControl) {
        //user has selected a media item
        [[SMFThemeInfo sharedTheme] playSelectSound];
        int focusedIndexCompat;
        if ([PLEX_COMPAT usingFourPointFour]) {
            focusedIndexCompat =  [[self.shelfControl focusedIndexPath] indexAtPosition:1];
            DLog(@"using 4.4 index for shelf. %d", focusedIndexCompat);
        } else {
            focusedIndexCompat = [(id)self.shelfControl focusedIndex];
            DLog(@"using 4.2 index for shelf. %d", focusedIndexCompat);
        }
        buttonIndex = 3;
        [self changeMetadataViewToShowDataForIndex:focusedIndexCompat];
    }
}

- (void)controller:(SMFMoviePreviewController*)c switchedFocusTo:(BRControl*)newControl {
    if ([newControl isKindOfClass:[BRButtonControl class]]) {
        //one of the buttons is now focused
        if (shelfIsSelected) {
            shelfIsSelected = NO; //shelf was focused, and now one of the buttons are.
        }
    } else if (newControl == shelfCtrl) {
        //the shelf is now re-focused, load previous focused element
        shelfIsSelected = YES;
        shelfCtrl.focusedIndexCompat = (id)lastFocusedIndex;
    }
}

- (void)controller:(SMFMoviePreviewController*)c shelfLastIndex:(long)index {
    //check if the shelf is currently selected
    //we perform this check because this delegate method is called every time
    //the user focuses a new control in the view
    if (shelfIsSelected) {
        lastFocusedIndex = index;
    }
}

- (void)controller:(SMFMoviePreviewController*)c playButtonEventOnButtonAtIndex:(int)index {
#if LOCAL_DEBUG_ENABLED
    DLog(@"play button on button at index [%d]", index);
#endif
    [[PlexNavigationController sharedPlexNavigationController] initiatePlaybackOfMediaObject:self.selectedMediaObject];
}

- (void)controller:(SMFMoviePreviewController*)c playButtonEventInShelf:(PlexMediaShelfView*)shelfControl {
    int selectedIndex = (int)[shelfControl focusedIndexCompat];
    PlexMediaObject *shelfSelectedMediaObject = [self.relatedMediaContainer.directories objectAtIndex:selectedIndex];
#if LOCAL_DEBUG_ENABLED
    DLog(@"play button in shelf at index [%d]: %@", selectedIndex, shelfSelectedMediaObject);
#endif
    [[PlexNavigationController sharedPlexNavigationController] initiatePlaybackOfMediaObject:shelfSelectedMediaObject];
}

- (void)controller:(SMFMoviePreviewController*)c downButtonEventInShelf:(PlexMediaShelfView*)shelfControl {
#if LOCAL_DEBUG_ENABLED
    DLog();
#endif
    moreInfoSelected = YES;
    PlexMediaContainer *moreInfoContainer = [self.selectedMediaObject loadDetails];
    PlexMoreInfoController *moreInfoController = [[PlexMoreInfoController alloc] initWithMoreInfoContainer:moreInfoContainer];
    [[self stack] pushController:moreInfoController];
    [moreInfoController release];
}


#pragma mark -
#pragma mark datasource methods
- (NSString*)title {
#if LOCAL_DEBUG_ENABLED
    DLog(@"title: %@", [self.selectedMediaObject.previewAsset title]);
#endif
    if (self.selectedMediaObject.isEpisode) {
        return [NSString stringWithFormat:@"%d. %@", [self.selectedMediaObject.previewAsset episode], [self.selectedMediaObject.previewAsset title]];
    } else {
        return [self.selectedMediaObject.previewAsset title];
    }
}
- (NSString*)subtitle {
#if LOCAL_DEBUG_ENABLED
    DLog(@"subtitle: %@", [self.selectedMediaObject.previewAsset broadcaster]);
#endif

    //If we selected a Movie show studio underneath title, if we selected a TVShow then display the season/episode information.
    if (self.selectedMediaObject.isMovie && [self.selectedMediaObject.previewAsset broadcaster] != nil) {
        return ([self.selectedMediaObject.previewAsset broadcaster]);
    }
    else if ([self.selectedMediaObject.previewAsset season]) {
        return [NSString stringWithFormat:@"%@, Season %d", [self.selectedMediaObject.previewAsset seriesName], [self.selectedMediaObject.previewAsset season]];
    }
    else {
        return @"";
    }
}

- (NSString*)summary {
#if LOCAL_DEBUG_ENABLED
    //DLog(@"summary: %@", [self.selectedMediaObject.previewAsset mediaSummary]);
#endif

    return self.selectedMediaObject.previewAsset.mediaSummary;

}

- (NSArray*)headers {

    if ([PlexMediaObjectTypeEpisode isEqualToString:self.selectedMediaObject.type]) {
        return [NSArray arrayWithObjects:@"Details",@"Show",@"Directors",@"Writers",nil];
    } else {
        return [NSArray arrayWithObjects:@"Details",@"Actors",@"Directors",@"Writers",nil];
    }
}

- (NSArray*)columns {
    PlexPreviewAsset *metadataAsset = self.selectedMediaObject.previewAsset;

    //the table will hold all the columns
    NSMutableArray *table = [NSMutableArray array];

    // ======= details column ======
    NSMutableArray *details = [NSMutableArray array];

    BRGenre *genre = [metadataAsset primaryGenre];
    [details addObject:[genre displayString]];

    NSString *releasedDate = nil;
    if ([PlexMediaObjectTypeEpisode isEqualToString:self.selectedMediaObject.type]) {
        releasedDate = [metadataAsset dateCreatedString];
    } else {
        releasedDate = [metadataAsset year];
    }
    NSString *released = [NSString stringWithFormat:@"Released %@", releasedDate];
    [details addObject:released];

    NSString *duration = [NSString stringWithFormat:@"%d minutes", [metadataAsset duration] / 60];
    [details addObject:duration];

    [table addObject:details];

    if ([PlexMediaObjectTypeEpisode isEqualToString:self.selectedMediaObject.type]) {
        NSMutableArray *show = [NSMutableArray array];
        // ======= show column ======
        if ([metadataAsset seriesName]) {
            [show addObject:[metadataAsset seriesName]];
        }
        if ([metadataAsset season]) {
            NSString *seasonString = [NSString stringWithFormat:@"Season %d", [metadataAsset season]];
            [show addObject:seasonString];
        }
        if ([metadataAsset episode]) {
            NSString *episodeString = [NSString stringWithFormat:@"Episode %d", [metadataAsset episode]];
            [show addObject:episodeString];
        }
        [table addObject:show];
    } else {
        // ======= actors column ======
        if ([metadataAsset cast]) {
            NSArray *actors = [metadataAsset cast];
            [table addObject:actors];
        }
    }

    // ======= directors column ======
    if ([metadataAsset directors]) {
        NSArray *directors = [metadataAsset directors];
        [table addObject:directors];
    }

    // ======= writers column ======
    if ([metadataAsset writers]) {
        NSArray *writers = [metadataAsset writers];
        [table addObject:writers];
    }

    // ======= done building table ======
#if LOCAL_DEBUG_ENABLED
    DLog(@"table: %@", table);
#endif
    return table;
}

//why so complicated? well, remote servers ALWAYS need auth headers, that's why
- (BRImage*)flagImageForUrl:(NSURL*)url {
    NSURLRequest *request = [self.selectedMediaObject.request urlRequestWithAuthenticationHeadersForURL:url];
    
    NSDictionary *headerFields = [request allHTTPHeaderFields];
    BRURLImageProxy *aImageProxy = [BRURLImageProxy proxyWithURL:[request URL] headerFields:headerFields];
    aImageProxy.writeToDisk = YES;
    return [aImageProxy imageForImageSize:512];
}

- (NSArray*)flags {
    if (cachedFlags) {
        DLog(@"Flags are cached %d", [cachedFlags count]);
        return cachedFlags;
    }
    
    DLog(@"no cached flags, fetching them");
    cachedFlags = [NSArray array];
    DLog();
        
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *_flags = [NSMutableArray array];
        
        if ([self.selectedMediaObject.previewAsset starRatingImage])
            [_flags addObject:[self.selectedMediaObject.previewAsset starRatingImage]];
        
        NSDictionary *mediaAttributes = self.selectedMediaObject.mediaResource.attributes;
        
        NSArray *flagAttributes = [NSArray arrayWithObjects:PlexFlagTypeContentVideoResolution,
                                   PlexFlagTypeContentVideoCodec, PlexFlagTypeContentAudioCodec,
                                   PlexFlagTypeContentAudioChannels, nil];

        for (PlexFlagTypes attribute in flagAttributes) {
            if ([mediaAttributes valueForKey:attribute]) {
                PlexImage *image = [self.selectedMediaObject.mediaContainer flagForType:attribute named:[mediaAttributes valueForKey:attribute]];
                if (![image loadImage]) {
                    DLog(@"Failed to load image %@", [mediaAttributes valueForKey:attribute]);
                    continue;
                }
                BRImage *img = [BRImage imageWithCGImageRef:[image.image CGImage]];
                if (img) {
                    [_flags addObject:img];
                    DLog(@"adding %@", [mediaAttributes valueForKey:attribute]);
                }
            }
        }
        if ([self.selectedMediaObject.previewAsset hasClosedCaptioning])
            [_flags addObject:[[BRThemeInfo sharedTheme] ccBadge]];

        dispatch_sync(dispatch_get_main_queue(), ^{
            cachedFlags = [NSArray arrayWithArray:_flags];
            DLog(@"done fetching flags, reload");
            [self reload];
        });
    });
    
    return cachedFlags;
}

- (NSString*)rating {
#if LOCAL_DEBUG_ENABLED
    DLog(@"rating: %@", [self.selectedMediaObject.previewAsset rating]);
#endif
    return [self.selectedMediaObject.previewAsset rating];
}

- (BRImage*)coverArt {
    BRImage *coverArt = nil;
    if ([self.selectedMediaObject.previewAsset hasCoverArt] && self.selectedMediaObject.isMovie) {
        coverArt = [[self.selectedMediaObject.previewAsset imageProxy] imageForImageSize:512];
    }
    else {
        coverArt = [self.selectedMediaObject.previewAsset seasonCoverArt];
    }
#if LOCAL_DEBUG_ENABLED
    DLog(@"coverArt: %@", coverArt);
#endif
    return coverArt;
}

- (NSURL*)backgroundImageUrl {
    return [self.selectedMediaObject.previewAsset fanartUrl];
}

- (NSArray*)buttons {
    // built-in images:
    // deleteActionImage, menuActionUnfocusedImage, playActionImage,
    // previewActionImage, queueActionImage, rateActionImage
    NSMutableArray *buttons = [NSMutableArray array];
    BRButtonControl *b = nil;
    BRImage *audioSubOFF = [BRImage imageWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"PlexAudioSubsOFF" ofType:@"png"]];
    BRImage *audioSubON = [BRImage imageWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"PlexAudioSubsON" ofType:@"png"]];

    b = [BRButtonControl actionButtonWithImage:[[BRThemeInfo sharedTheme] playActionImage] subtitle:@"Play" badge:nil];
    [b setIdentifier:[NSNumber numberWithInt:kPlayButton]];
    [b setHighlightedImage:[[BRThemeInfo sharedTheme] playActionHighlightedImage]];
    [buttons addObject:b];
    /*
       b = [BRButtonControl actionButtonWithImage:[[BRThemeInfo sharedTheme]previewActionImage]
       subtitle:@"Preview"
       badge:nil];
       [b setIdentifier:[NSNumber numberWithInt:kPreviewButton]];
       [buttons addObject:b];
     */
    b = [BRButtonControl actionButtonWithImage:audioSubOFF subtitle:@"Audio/Subs" badge:nil];
    [b setIdentifier:[NSNumber numberWithInt:kAudioSubsButton]];
    [b setHighlightedImage:audioSubON];
    [buttons addObject:b];

    b = [BRButtonControl actionButtonWithImage:[[BRThemeInfo sharedTheme] moreActionImage] subtitle:@"More" badge:nil];
    [b setHighlightedImage:[[BRThemeInfo sharedTheme] moreActionHighlightedImage]];
    [b setIdentifier:[NSNumber numberWithInt:kMoreButton]];
    [buttons addObject:b];


    return buttons;
}

- (NSString*)shelfTitle {
    return self.relatedMediaContainer.name;
}

- (BRPhotoDataStoreProvider*)providerForShelf {
    NSSet *_set = [NSSet setWithObject:[BRMediaType photo]];
    NSPredicate *_pred = [NSPredicate predicateWithFormat:@"mediaType == %@",[BRMediaType photo]];
    BRDataStore *store = [[BRDataStore alloc] initWithEntityName:@"Hello" predicate:_pred mediaTypes:_set];

    for (PlexMediaObject*pmo in self.relatedMediaContainer.directories) {
        [store addObject:pmo.previewAsset];
    }

    PlexControlFactory *controlFactory = [[PlexControlFactory alloc] initForMainMenu:NO];
    controlFactory.defaultImage = [[BRThemeInfo sharedTheme] storeRentalPlaceholderImage];
    id provider = [BRPhotoDataStoreProvider providerWithDataStore:store controlFactory:controlFactory];
    [controlFactory release];
    [store release];
#if LOCAL_DEBUG_ENABLED
    DLog(@"providerForShelf: %@", provider);
#endif
    return provider;
}

- (BRImage*)placeHolderImageForShelf {
    return [[BRThemeInfo sharedTheme] storeRentalPlaceholderImage];
}

#pragma mark -
#pragma mark Popup delegates

#define MarkAsWatchedOption 0
#define MarkAsUnwatchedOption 1

- (float)popupHeightForRow:(long)row {
    return 0.0f;
}

- (BOOL)popupRowSelectable:(long)row {
    return YES;
}

- (long)popupItemCount {
    return 3;
}

- (id)popupItemForRow:(long)row {
    SMFMenuItem *it = [SMFMenuItem menuItem];
    switch (row) {
    case MarkAsWatchedOption: {
        [it setTitle:@"Mark as watched"];
        break;
    }
    case MarkAsUnwatchedOption: {
        [it setTitle:@"Mark as unwatched"];
        break;
    }
    default:
        [it setTitle:@"Go back"];
        break;
    }
    return it;
}

- (long)popupDefaultIndex {
    return 0;
}

- (void)popup:(id)p itemSelected:(long)row {
    [p removeFromParent];
    BOOL reload = YES;
    switch (row) {
    case MarkAsWatchedOption: {
        DLog(@"marking movie as watched");
        [self.selectedMediaObject markSeen];
        break;
    }
    case MarkAsUnwatchedOption: {
        DLog(@"marking movie as un-watched");
        [self.selectedMediaObject markUnseen];
        break;
    }
    default:
        DLog(@"going back");
        reload = NO;
        break;
    }
    if (reload) {
        [self reload];
    }
}


@end
