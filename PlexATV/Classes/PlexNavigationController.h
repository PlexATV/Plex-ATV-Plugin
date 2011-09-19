//
//  PlexNavigationController.h
//  plex
//
//  Created by ccjensen on 18/04/2011.
//

#import <Foundation/Foundation.h>
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexMediaContainer.h>

@interface PlexNavigationController : BRController {}

@property (retain) BRWaitPromptControl *waitControl;
@property (retain) PlexMediaObject *targetMediaObject;
@property (retain) BRController *targetController;
@property (retain) NSString *promptText;

+ (PlexNavigationController*)sharedPlexNavigationController;

//Navigation Methods
- (void)initiatePlaybackOfMediaObject:(PlexMediaObject*)aMediaObject;
- (void)navigateToObjectsContents:(PlexMediaObject*)aMediaObject;
- (void)navigateToChannelsForMachine:(Machine*)aMachine;
- (void)navigateToSearchForMachine:(Machine*)aMachine;
- (void)navigateToSettingsWithTopLevelController:(BRBaseAppliance*)topLevelController;
- (void)navigateToServerList;

//Determine View Type Methods
- (BRController*)newControllerForObject:(PlexMediaObject*)aMediaObject;
- (BRTabControl*)newTabBarForContents:(PlexMediaContainer*)someContents;

//Container Manipulation Methods
- (BRController*)newTVShowsController:(PlexMediaContainer*)tvShowCategory;
- (BRController*)newGridController:(PlexMediaContainer*)movieCategory withShelfKeyString:(NSString*)shelfKey;
- (PlexMediaContainer*)applySkipFilteringOnContainer:(PlexMediaContainer*)container;

@end
