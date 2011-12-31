/*
 *  HWAppliance.h
 *  atvTwo
 *
 *  Created by Frank Bauer on 15.01.11.
 *  Modified by ccjensen
 */


#import "BackRowExtras.h"
@class PlexTopShelfController, PlexMediaContainer;

@interface PlexAppliance : BRBaseAppliance <MachineManagerDelegate> { }
@property (nonatomic, retain) PlexTopShelfController *topShelfController;
@property (nonatomic, retain) NSMutableArray *currentApplianceCategories;
@property (nonatomic, retain) BRApplianceCategory *otherServersApplianceCategory;
@property (nonatomic, retain) BRApplianceCategory *settingsApplianceCategory;

- (void)rebuildCategories;
+ (void)XBMCfixUIDevice;

@end