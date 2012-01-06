//
//  PlexViewSettingsController.m
//  atvTwo
//
//  Created by ccjensen on 10/01/2011.
//
//  Inspired by
//
//		MLoader.m
//		MextLoader
//
//		Created by Thomas Cool on 10/22/10.
//		Copyright 2010 tomcool.org. All rights reserved.
//

#import "PlexViewSettingsController.h"
#import "HWUserDefaults.h"
#import "Constants.h"
#import "PlexCommonUtils.h"

#import <plex-oss/Machine.h>
#import <plex-oss/PlexMediaContainer.h>

@implementation PlexViewSettingsController
@synthesize viewTypesDescription, topShelfFilters;

//----------- general -----------
#define ViewTypeForMoviesIndex              0
#define ViewTypeForTvShowsIndex             1
#define ViewThemeMusicEnabledIndex          2
#define ViewThemeMusicLoopEnabledIndex      3
//----------- list -----------
#define ViewListPosterZoomingEnabledIndex   4
//----------- detailed metadata -----------
#define ViewPreplayFanartEnabledIndex       5
#define ViewHideSummaryOnUnseen             6
//----------- top shelf ------------
#define ViewTopShelfMachine                 7
#define ViewTopShelfSection                 8
#define ViewTopShelfFilter                  9

#pragma mark -
#pragma mark Object/Class Lifecycle
- (id)init {
    if( (self = [super init]) != nil ) {
        [self setLabel:@"Plex View Settings"];
        [self setListTitle:@"Plex View Settings"];

        self.viewTypesDescription = [NSArray arrayWithObjects:@"List", @"Grid", @"Bookcase", nil];
        self.topShelfFilters = [NSArray arrayWithObjects:@"Recently added", @"On deck", nil];

        [self setupList];
        [[self list] addDividerAtIndex:0 withLabel:@"General"];
        [[self list] addDividerAtIndex:4 withLabel:@"List"];
        [[self list] addDividerAtIndex:5 withLabel:@"Preplay"];
        [[self list] addDividerAtIndex:7 withLabel:@"Top shelf"];
        
    }
    return self;
}

- (void)dealloc {
    self.viewTypesDescription = nil;
    self.topShelfFilters = nil;
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
    [self setupList];
    [self.list reload];
    [super wasExhumed];
}

- (void)wasBuried {
    [super wasBuried];
}

- (void)setupList {
    [_items removeAllObjects];

    // =========== general ===========
    // =========== view type for movies setting ===========
    SMFMenuItem *viewTypeForMoviesSettingMenuItem = [SMFMenuItem menuItem];

    [viewTypeForMoviesSettingMenuItem setTitle:@"View type for Movies"];
    NSInteger viewTypeForMoviesSettingNumber = [[HWUserDefaults preferences] integerForKey:PreferencesViewTypeForMovies];
    NSString *viewTypeForMoviesSetting = [self.viewTypesDescription objectAtIndex:viewTypeForMoviesSettingNumber];
    [viewTypeForMoviesSettingMenuItem setRightText:viewTypeForMoviesSetting];
    [_items addObject:viewTypeForMoviesSettingMenuItem];


    // =========== view type for tv shows setting ===========
    SMFMenuItem *viewTypeForTvShowsSettingMenuItem = [SMFMenuItem menuItem];

    [viewTypeForTvShowsSettingMenuItem setTitle:@"View type for TV Shows"];
    NSInteger viewTypeForTvShowsSettingNumber = [[HWUserDefaults preferences] integerForKey:PreferencesViewTypeForTvShows];
    NSString *viewTypeForTvShowsSetting = [self.viewTypesDescription objectAtIndex:viewTypeForTvShowsSettingNumber];
    [viewTypeForTvShowsSettingMenuItem setRightText:viewTypeForTvShowsSetting];
    [_items addObject:viewTypeForTvShowsSettingMenuItem];

    // =========== theme music enabled ===========
    SMFMenuItem *themeMusicMenuItem = [SMFMenuItem menuItem];

    [themeMusicMenuItem setTitle:@"Theme music"];
    NSString *themeMusic = [[HWUserDefaults preferences] boolForKey:PreferencesViewThemeMusicEnabled] ? @"Enabled" : @"Disabled";
    [themeMusicMenuItem setRightText:themeMusic];
    [_items addObject:themeMusicMenuItem];


    // =========== theme music looping ===========
    SMFMenuItem *themeMusicLoopingMenuItem = [SMFMenuItem menuItem];

    [themeMusicLoopingMenuItem setTitle:@"Theme music looping"];
    NSString *themeMusicLooping = [[HWUserDefaults preferences] boolForKey:PreferencesViewThemeMusicLoopEnabled] ? @"Enabled" : @"Disabled";
    [themeMusicLoopingMenuItem setRightText:themeMusicLooping];
    [_items addObject:themeMusicLoopingMenuItem];


    // =========== list ===========
    // =========== poster zooming ===========
    SMFMenuItem *posterZoomMenuItem = [SMFMenuItem menuItem];

    [posterZoomMenuItem setTitle:@"Poster zoom"];
    NSString *posterZoom = [[HWUserDefaults preferences] boolForKey:PreferencesViewListPosterZoomingEnabled] ? @"Enabled" : @"Disabled";
    [posterZoomMenuItem setRightText:posterZoom];
    [_items addObject:posterZoomMenuItem];


    // =========== Preplay ===========
    // =========== fanart ===========
    SMFMenuItem *fanartMenuItem = [SMFMenuItem menuItem];

    [fanartMenuItem setTitle:@"Fanart"];
    NSString *fanart = [[HWUserDefaults preferences] boolForKey:PreferencesViewPreplayFanartEnabled] ? @"Enabled" : @"Disabled";
    [fanartMenuItem setRightText:fanart];
    [_items addObject:fanartMenuItem];

    // =========== Preplay ===========
    // =========== summary ===========
    SMFMenuItem *hiddenSummary = [SMFMenuItem menuItem];
    [hiddenSummary setTitle:@"Hide summary on unseen TV Series"];
    NSString *summary = [[HWUserDefaults preferences] boolForKey:PreferencesViewHiddenSummary] ? @"Enabled" : @"Disabled";
    [hiddenSummary setRightText:summary];
    [_items addObject:hiddenSummary];

    // =========== Top Shelf ===========
    // =========== Source Machine ===========
    SMFMenuItem *sourceMachine = [SMFMenuItem menuItem];
    [sourceMachine setTitle:@"Select Plex Media Server"];
    NSString *sourceMachineID = [[HWUserDefaults preferences] stringForKey:PreferencesViewTopShelfSourceMachine];
    
    Machine *m = nil;
    if (!sourceMachineID || sourceMachineID.isZeroLength) {
        m = [PlexCommonUtils findHighPrioLocalMachineWithSections:YES];
    } else {
        m = [[MachineManager sharedMachineManager] machineForMachineID:sourceMachineID];
    }

    if (m) {
        [[HWUserDefaults preferences] setObject:m.machineID forKey:PreferencesViewTopShelfSourceMachine];
        [sourceMachine setRightText:m.serverName];
    } else {
        [sourceMachine setRightText:@"No nearby servers"];
    }
    
    [_items addObject:sourceMachine];

    // =========== Top Shelf ===========
    // =========== Source Section ===========
    SMFMenuItem *sourceSectionItem = [SMFMenuItem menuItem];
    [sourceSectionItem setTitle:@"Select Section"];
    NSString *sectionKey = [[HWUserDefaults preferences] stringForKey:PreferencesViewTopShelfSourceSection];
    
    PlexMediaObject *pmo = [m.librarySections findObjectWithKey:sectionKey];
    if (!pmo) {
        pmo = [m.librarySections.directories objectAtIndex:0];
    }
    
    if (!sectionKey || sectionKey.isZeroLength) {
        [[HWUserDefaults preferences] setObject:pmo.key forKey:PreferencesViewTopShelfSourceSection];
    }
        
    [sourceSectionItem setRightText:pmo.name];
    [_items addObject:sourceSectionItem];

    // =========== Top Shelf ===========
    // =========== Source Filter ===========
    SMFMenuItem *sourceFilterItem = [SMFMenuItem menuItem];
    [sourceFilterItem setTitle:@"Select Filter"];
    NSInteger idx = [[HWUserDefaults preferences] integerForKey:PreferencesViewTopShelfSourceFilter];
    DLog(@"filter index = %d", idx);
    
    NSString *filterName = [self.topShelfFilters objectAtIndex:idx];
    DLog(@"filtername = %@", filterName);
    [sourceFilterItem setRightText:filterName];
    [_items addObject:sourceFilterItem];

}

#pragma mark -
#pragma mark List Delegate Methods
- (void)itemSelected:(long)selected {
    BOOL refreshTopShelf = NO;
    switch (selected) {
        case ViewTypeForMoviesIndex: {
            NSInteger viewTypeNumber = [[HWUserDefaults preferences] integerForKey:PreferencesViewTypeForMovies];
            viewTypeNumber++;
            if (viewTypeNumber >= 2) {
                viewTypeNumber = 0;
            }
            [[HWUserDefaults preferences] setInteger:viewTypeNumber forKey:PreferencesViewTypeForMovies];
            
            [self setupList];
            [self.list reload];
            break;
        }
        case ViewTypeForTvShowsIndex: {
            NSInteger viewTypeNumber = [[HWUserDefaults preferences] integerForKey:PreferencesViewTypeForTvShows];
            viewTypeNumber++;
            if (viewTypeNumber >= FINAL_kATVPlexViewTypeBookcase_MAX) {
                viewTypeNumber = 0;
            }
            [[HWUserDefaults preferences] setInteger:viewTypeNumber forKey:PreferencesViewTypeForTvShows];
            
            [self setupList];
            [self.list reload];
            break;
        }
        case ViewThemeMusicEnabledIndex: {
            BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesViewThemeMusicEnabled];
            [[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesViewThemeMusicEnabled];
            [self setupList];
            [self.list reload];
            break;
        }
        case ViewThemeMusicLoopEnabledIndex: {
            BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesViewThemeMusicLoopEnabled];
            [[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesViewThemeMusicLoopEnabled];
            [self setupList];
            [self.list reload];
            break;
        }
            //--------------------- seperator ---------------------
        case ViewListPosterZoomingEnabledIndex: {
            BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesViewListPosterZoomingEnabled];
            [[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesViewListPosterZoomingEnabled];
            [self setupList];
            [self.list reload];
            break;
        }
            //--------------------- seperator ---------------------
        case ViewPreplayFanartEnabledIndex: {
            BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesViewPreplayFanartEnabled];
            [[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesViewPreplayFanartEnabled];
            [self setupList];
            [self.list reload];
            break;
        }
            //--------------------- seperator ---------------------
        case ViewHideSummaryOnUnseen: {
            BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesViewHiddenSummary];
            [[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesViewHiddenSummary];
            [self setupList];
            [self.list reload];
            break;
        }
            //--------------------- seperator ---------------------
        case ViewTopShelfMachine: {
            NSArray *allMachines = [PlexCommonUtils allMachinesIOwnWithSections];
            NSString *machineID = [[HWUserDefaults preferences] stringForKey:PreferencesViewTopShelfSourceMachine];
            NSInteger idx = [allMachines indexOfObject:[[MachineManager sharedMachineManager] machineForMachineID:machineID]];
            idx ++;
            if (idx >= [allMachines count])
                idx = 0;
            [[HWUserDefaults preferences] setObject:((Machine*)[allMachines objectAtIndex:idx]).machineID forKey:PreferencesViewTopShelfSourceMachine];
            [self setupList];
            [self.list reload];
            refreshTopShelf = YES;
            break;
        }
        case ViewTopShelfSection: {
            Machine *m = [[MachineManager sharedMachineManager] machineForMachineID:[[HWUserDefaults preferences] stringForKey:PreferencesViewTopShelfSourceMachine]];
            NSArray *allSections = [PlexCommonUtils allMovieAndTVSections:m.librarySections];
            NSString *sectionKey = [[HWUserDefaults preferences] stringForKey:PreferencesViewTopShelfSourceSection];
            PlexMediaObject *pmo = [m.librarySections findObjectWithKey:sectionKey];
            NSInteger idx = [allSections indexOfObject:pmo];
            idx ++;
            if (idx >= [allSections count])
                idx = 0;
            [[HWUserDefaults preferences] setObject:((PlexMediaObject*)[allSections objectAtIndex:idx]).key forKey:PreferencesViewTopShelfSourceSection];
            [self setupList];
            [self.list reload];
            refreshTopShelf = YES;
            break;
        }
        case ViewTopShelfFilter: {
            NSInteger idx = [[HWUserDefaults preferences] integerForKey:PreferencesViewTopShelfSourceFilter];
            idx ++;
            if (idx >= [self.topShelfFilters count])
                idx = 0;
            [[HWUserDefaults preferences] setInteger:idx forKey:PreferencesViewTopShelfSourceFilter];
            [self setupList];
            [self.list reload];
            refreshTopShelf = YES;
            break;
        }

            
        default:
            break;
    }
    if (refreshTopShelf) {
        DLog();
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PlexTopShelfRefresh" object:nil];
    }
}

- (id)previewControlForItem:(long)item {
    SMFBaseAsset *asset = [[SMFBaseAsset alloc] init];
    switch (item) {
    case ViewTypeForMoviesIndex: {
        [asset setTitle:@"Select the view type for the Movies screens"];
        [asset setSummary:@"Sets the type of view used when navigating Movies. Choose between list or grid view"];
        break;
    }
    case ViewTypeForTvShowsIndex: {
        [asset setTitle:@"Select the view type for the TV Shows screens"];
        [asset setSummary:@"Sets the type of view used when navigating TV Shows. Choose between list, grid or bookcase view"];
        break;
    }
    case ViewThemeMusicEnabledIndex: {
        [asset setTitle:@"Toggles whether theme music plays"];
        [asset setSummary:@"Enables/Disables the playback of theme music upon entering a section that has theme music available"];
        break;
    }
    case ViewThemeMusicLoopEnabledIndex: {
        [asset setTitle:@"Toggles whether the theme music loops"];
        [asset setSummary:@"Enables/Disables the looping of theme music when playback of theme music completes"];
        break;
    }
    case ViewListPosterZoomingEnabledIndex: {
        [asset setTitle:@"Toggles whether to zoom the poster"];
        [asset setSummary:@"Enables/Disables the image starting out covering the majority of metadata view and animating to show the metadata"];
        break;
    }
    case ViewPreplayFanartEnabledIndex: {
        [asset setTitle:@"Toggles whether to display fanart"];
        [asset setSummary:@"Enables/Disables fanart used as the background for the Preplay screen"];
        break;
    }
    case ViewHideSummaryOnUnseen: {
        [asset setTitle:@"Toggles whether to show summaries when unseen"];
        [asset setSummary:@"Enables/Disables the summary for movies you have not seen yet"];
        break;
    }
    default:
        break;
    }
    [asset setCoverArt:[BRImage imageWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"PlexSettings" ofType:@"png"]]];
    SMFMediaPreview *p = [[SMFMediaPreview alloc] init];
    [p setShowsMetadataImmediately:YES];
    [p setAsset:asset];
    [asset release];
    return [p autorelease];
}


@end
