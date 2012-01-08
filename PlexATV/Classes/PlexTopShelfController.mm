//
//  PlexTopShelfController.m
//  plex
//
//  Created by tomcool
//  Modified by ccjensen
//

#define LOCAL_DEBUG_ENABLED 0

#import "PlexTopShelfController.h"
#import "HWAppliance.h"
#import "BackRowExtras.h"
#import "PlexPreviewAsset.h"
#import <plex-oss/PlexMediaContainer.h>
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexRequest.h>
#import "PlexMediaObject+Assets.h"
#import "PlexNavigationController.h"
#import "HWUserDefaults.h"
#import "Constants.h"
#import "PlexCommonUtils.h"
#import "Plex_SynthesizeSingleton.h"

#pragma mark -
#pragma mark BRTopShelfView Category
@interface BRTopShelfView (specialAdditions)
- (BRImageControl*)productImage;
@end

@implementation BRTopShelfView (specialAdditions)
- (BRImageControl*)productImage {
    return MSHookIvar<BRImageControl*>(self, "_productImage");
}
@end



#pragma mark -
#pragma mark PlexTopShelfController Implementation
@implementation PlexTopShelfController
@synthesize containerName;
@synthesize mediaContainer;
@synthesize topShelfView;

#pragma mark -
#pragma mark Object/Class Lifecycle

PLEX_SYNTHESIZE_SINGLETON_FOR_CLASS(PlexTopShelfController);

- (void)dealloc {
    DLog(@"------- DEALLOC %@ ------", self);
    [topShelfView release];
    [refreshTimer invalidate];
    [refreshTimer release];
    
    self.mediaContainer = nil;
    
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        DLog(@"----- INIT %@ ------", self);
        topShelfView = [[BRTopShelfView alloc] init];
        
        BRImageControl *imageControl = [topShelfView productImage];
        BRImage *theImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[PlexTopShelfController class]] pathForResource:@"PmsMainMenuLogo" ofType:@"png"]];
        [imageControl setImage:theImage];
        
        shelfView = MSHookIvar<BRMediaShelfView*>(topShelfView, "_shelf");
        shelfView.scrollable = YES;
        shelfView.dataSource = self;
        shelfView.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"PlexTopShelfRefresh" object:nil];
        refreshTimer = nil;
    }
    return self;
}

- (void)stopRefresh
{
    DLog(@"stopRefresh %@", self);
    if (refreshTimer) {
        [refreshTimer invalidate];
        refreshTimer = nil;
    }
}

- (PlexMediaContainer*)containerForShelf
{
    NSString *machineID = [[HWUserDefaults preferences] stringForKey:PreferencesViewTopShelfSourceMachine];
    Machine *m = nil;
    if (machineID) {
        m = [[MachineManager sharedMachineManager] machineForMachineID:machineID];
    } else {
        m = [PlexCommonUtils findHighPrioLocalMachineWithSections:YES];
    }
    
    /* couldn't find any machine, no need to create the topshelf */
    if (!m) return nil;
    
    NSString *sectionKey = [[HWUserDefaults preferences] stringForKey:PreferencesViewTopShelfSourceSection];
    if (!sectionKey) {
        sectionKey = [PlexCommonUtils findHighPrioMovieSection:m.librarySections].key;
    }
    
    /* still no sectionKey, damn */
    if (!sectionKey) return nil;
    
    NSInteger filterIdx = [[HWUserDefaults preferences] integerForKey:PreferencesViewTopShelfSourceFilter];
    NSString *filterKey = @"";
    if (filterIdx == 0) filterKey = @"recentlyAdded";
    if (filterIdx == 1) filterKey = @"onDeck";
    
    NSString *queryURL = [NSString stringWithFormat:@"%@/%@", sectionKey, filterKey];
    
    PlexMediaContainer *pmc = [m.request query:queryURL callingObject:nil ignorePresets:YES timeout:20 cachePolicy:NSURLRequestUseProtocolCachePolicy];
    return pmc;
}

- (BOOL)containerIsEqual:(PlexMediaContainer*)container
{
    
    if (![container.key isEqualToString:mediaContainer.key]) {
        return NO;
    }
    
    for (PlexMediaObject *pmo in container.directories) {
        PlexMediaObject *pmm = [mediaContainer findEqualObject:pmo];
        if (!pmm) {
            return NO;
        }
    }
    
    for (PlexMediaObject *pmo in mediaContainer.directories) {
        PlexMediaObject *pmm = [container findEqualObject:pmo];
        if (!pmm) {
            return NO;
        }
    }
    return YES;
}

- (void)refresh {
    if (!refreshTimer) {
        refreshTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
    }

    PlexMediaContainer *newContainer = [self containerForShelf];
    if ([self containerIsEqual:newContainer]) {
        return;
    }
    
    DLog(@"significant change, let's refresh");
    
    self.mediaContainer = newContainer;
    
    //if ([self.onDeckMediaContainer.directories count] > 0 || [self.recentlyAddedMediaContainer.directories count] > 0) {
    if ([self.mediaContainer.directories count] > 0) {  
        if ([PLEX_COMPAT usingFourPointFour])
            [topShelfView setState:2];  //shelf refresh command
        else
            [topShelfView setState:1];
        
        
#if LOCAL_DEBUG_ENABLED
        DLog(@"Activate main menu shelf");
#endif
        [shelfView reloadData];
    } else {
#if LOCAL_DEBUG_ENABLED
        DLog(@"Activate main menu banner");
#endif
        [topShelfView setState:0]; //banner image
    }
}


#pragma mark -
#pragma mark BRMediaShelf Datasource Methods
- (long)numberOfFlatColumnsInMediaShelf:(BRMediaShelfView*)view {
    return 7;
}

- (float)horizontalGapForMediaShelf:(BRMediaShelfView*)view {
    return 30.0f;
}

- (float)coverflowMarginForMediaShelf:(BRMediaShelfView*)view {
    return 0.05000000074505806;
}

- (long)numberOfSectionsInMediaShelf:(BRMediaShelfView*)view {
    return 1;
}

- (id)mediaShelf:(BRMediaShelfView*)view sectionHeaderForSection:(long)section {
    return nil;
}

- (id)mediaShelf:(BRMediaShelfView*)view titleForSectionAtIndex:(long)section {
#if LOCAL_DEBUG_ENABLED
    DLog();
#endif
    //PlexMediaContainer *aMediaContainer = section == 0 ? self.onDeckMediaContainer : self.recentlyAddedMediaContainer;
    
    //TODO: once we've got sections going on, uncomment below for more accurate description of section in topshelf
    //NSString *title = [NSString stringWithFormat:@"%@ : %@", self.containerName, section == 0 ? @"On Deck" : @"Recently Added"];
    NSInteger filterIdx = [[HWUserDefaults preferences] integerForKey:PreferencesViewTopShelfSourceFilter];
    NSString *title = [NSString stringWithFormat:@"%@", filterIdx == 0 ? @"Recently Added":@"On Deck"];
    
    BRTextControl *titleControl = [[BRTextControl alloc] init];
    
    NSMutableDictionary *titleAttributes = [NSMutableDictionary dictionary];
    [titleAttributes setValue:@"HelveticaNeueATV" forKey:@"BRFontName"];
    [titleAttributes setValue:[NSNumber numberWithInt:21] forKey:@"BRFontPointSize"];
    [titleAttributes setValue:[NSNumber numberWithInt:4] forKey:@"BRLineBreakModeKey"];
    [titleAttributes setValue:[NSNumber numberWithInt:0] forKey:@"BRTextAlignmentKey"];
    [titleAttributes setValue:(id)[[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f] CGColor] forKey:@"CTForegroundColor"];
    [titleAttributes setValue:[NSValue valueWithCGSize:CGSizeMake(0, -2)] forKey:@"BRShadowOffset"];
    
    [titleControl setText:title withAttributes:titleAttributes];
    return [titleControl autorelease];
}

- (long)mediaShelf:(BRMediaShelfView*)view numberOfColumnsInSection:(long)section {
#if LOCAL_DEBUG_ENABLED
    DLog();
#endif
        
#if LOCAL_DEBUG_ENABLED
    //DLog(@"cont: %@", aMediaContainer);
#endif
    
    return [self.mediaContainer.directories count];
}


- (id)mediaShelf:(BRMediaShelfView*)view itemAtIndexPath:(NSIndexPath*)indexPath {    
    int row = [indexPath indexAtPosition:1];
        
    PlexMediaObject *pmo = [self.mediaContainer.directories objectAtIndex:row];
    PlexPreviewAsset *asset = pmo.previewAsset;
    NSString *title = [asset title];
    
    BRPosterControl *poster = [[BRPosterControl alloc] init];
    poster.posterStyle = 1;
    poster.cropAspectRatio = 0.66470599174499512;
    
    if (pmo.isEpisode) {
        poster.imageProxy = [asset seasonCoverImageProxy];
    } else {
        poster.imageProxy = [asset imageProxy];
    }
    poster.defaultImage = [asset coverArt];
    poster.reflectionAmount = 0.10000000149011612;
    poster.reflectionBaseline = 0.072999998927116394;
    
    poster.titleVerticalOffset = 0.039999999105930328;
    [poster setNonAttributedTitleWithCrossfade:title];
    
    return [poster autorelease];
}


#pragma mark -
#pragma mark BRMediaShelf Delegate Methods
- (void)mediaShelf:(id)shelf didSelectItemAtIndexPath:(id)indexPath {
    int row = [indexPath indexAtPosition:1];
        
    PlexMediaObject *pmo = [self.mediaContainer.directories objectAtIndex:row];
    
#if LOCAL_DEBUG_ENABLED
    DLog(@"selecting [%@]", pmo);
#endif
    
    [[SMFThemeInfo sharedTheme] playSelectSound];
    [[PlexNavigationController sharedPlexNavigationController] navigateToObjectsContents:pmo];
}

- (void)mediaShelf:(id)shelf didPlayItemAtIndexPath:(id)indexPath {
    int row = [indexPath indexAtPosition:1];
        
    PlexMediaObject *pmo = [self.mediaContainer.directories objectAtIndex:row];
    
#if LOCAL_DEBUG_ENABLED
    DLog(@"playing [%@]", pmo);
#endif
    
    if (pmo.hasMedia) {
        //play media
        [[PlexNavigationController sharedPlexNavigationController] initiatePlaybackOfMediaObject:pmo];
    } else {
        //not media, pretend it was a selection
        [self mediaShelf:shelf didSelectItemAtIndexPath:indexPath];
    }
}

//methods below are never called
- (void)mediaShelf:(id)shelf didFocusItemAtIndexPath:(id)indexPath {
#if LOCAL_DEBUG_ENABLED
    DLog(@"didFocusItemAtIndexPath never called");
#endif
    //int section = [indexPath indexAtPosition:0];
    //int row = [indexPath indexAtPosition:1];
}

- (BOOL)handleObjectSelection:(id)selection userInfo:(id)info {
#if LOCAL_DEBUG_ENABLED
    DLog(@"handleObjectSelection never called");
#endif
    return NO;
}

- (void)selectCategoryWithIdentifier:(id)identifier {
#if LOCAL_DEBUG_ENABLED
    DLog(@"selectCategoryWithIdentifier never called");
#endif
}

@end