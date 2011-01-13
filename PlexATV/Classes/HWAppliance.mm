

#import "BackRowExtras.h"
#import "HWPlexDir.h"
#import "HWSettingsController.h"
#import <Foundation/Foundation.h>
#import <plex-oss/PlexRequest + Security.h>
#import <plex-oss/MachineManager.h>
#import <plex-oss/PlexMediaContainer.h>
#define HELLO_ID @"hwHello"
#define SETTINGS_ID @"hwSettings"

#define HELLO_CAT [BRApplianceCategory categoryWithName:NSLocalizedString(@"Servers", @"Servers") identifier:HELLO_ID preferredOrder:0]
#define SETTINGS_CAT [BRApplianceCategory categoryWithName:NSLocalizedString(@"Settings", @"Settings") identifier:SETTINGS_ID preferredOrder:99]

@interface UIDevice (ATV)
+(void)preloadCurrentForMacros;
@end

@interface BRTopShelfView (specialAdditions)
- (BRImageControl *)productImage;
@end


@implementation BRTopShelfView (specialAdditions)
- (BRImageControl *)productImage {
	return MSHookIvar<BRImageControl *>(self, "_productImage");
}
@end


@interface TopShelfController : NSObject {}
- (void)selectCategoryWithIdentifier:(id)identifier;
- (id)topShelfView;
- (void)refresh;
@end

@implementation TopShelfController
- (void)initWithApplianceController:(id)applianceController {}
- (void)selectCategoryWithIdentifier:(id)identifier {}
- (void)refresh{}


- (BRTopShelfView *)topShelfView {
	BRTopShelfView *topShelf = [[BRTopShelfView alloc] init];
	BRImageControl *imageControl = [topShelf productImage];
	BRImage *theImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[HWPlexDir class]] pathForResource:@"PlexLogo" ofType:@"png"]];
	//BRImage *theImage = [[BRThemeInfo sharedTheme] largeGeniusIconWithReflection];
	[imageControl setImage:theImage];
	
	return [topShelf autorelease];
}
@end


#pragma mark -
#pragma mark PlexAppliance
@interface PlexAppliance: BRBaseAppliance <MachineManagerDelegate> {
	TopShelfController *_topShelfController;
	NSMutableArray *_applianceCategories;
	NSMutableArray *_machines;
}
@property(nonatomic, readonly, retain) id topShelfController;
@property(retain) NSMutableArray *applianceCat;
@property(nonatomic, retain) NSMutableArray *machines;

- (void)retrieveNewPlexCategories:(Machine *)m;
- (void)addNewApplianceWithDict:(NSDictionary *)dict;
- (void)addNewApplianceWithName:(NSString *)name identifier:(id)ident;
- (void)removeAppliancesWithIdentifier:(id)ident;
@end

@implementation PlexAppliance
@synthesize topShelfController = _topShelfController;
@synthesize applianceCat = _applianceCategories;
@synthesize machines = _machines;

NSString * const CompoundIdentifierDelimiter = @"|||";

+ (void)initialize {}


- (id)init {
	if((self = [super init]) != nil) {
		
		[UIDevice preloadCurrentForMacros];
		//#warning Please check elan.plexapp.com/2010/12/24/happy-holidays-from-plex/?utm_source=feedburner&utm_medium=feed&utm_campaign=Feed%3A+osxbmc+%28Plex%29 to get a set of transcoder keys
		[PlexRequest setStreamingKey:@"k3U6GLkZOoNIoSgjDshPErvqMIFdE0xMTx8kgsrhnC0=" forPublicKey:@"KQMIY6GATPC63AIMC4R2"];
		//instrumentObjcMessageSends(YES);
		
		NSString *logPath = @"/tmp/PLEX.txt"; 
		NSLog(@"Redirecting Log to %@", logPath);
		
		/*		FILE fl1 = fopen([logPath fileSystemRepresentation], "a+");
		 fclose(fl1);*/
		freopen([logPath fileSystemRepresentation], "a+", stderr);
		freopen([logPath fileSystemRepresentation], "a+", stdout);
		
		
		_topShelfController = [[TopShelfController alloc] init];
		_applianceCategories = [[NSMutableArray alloc] initWithObjects:SETTINGS_CAT,nil];
		_machines = [[NSMutableArray alloc] init];
		
		[[MachineManager sharedMachineManager] setDelegate:self];
		[[MachineManager sharedMachineManager] startAutoDetection];
		
	} return self;
}

- (id)controllerForIdentifier:(id)identifier args:(id)args {
	id menuController = nil;
	
	if ([identifier isEqualToString:SETTINGS_ID]) {
		menuController = [[HWSettingsController alloc] init];
	} else {
		// ====== get the name of the category and identifier of the machine selected ======
		NSArray *compoundIdentifierComponents = [(NSString *)identifier componentsSeparatedByString:CompoundIdentifierDelimiter];
		if ([compoundIdentifierComponents count] != 2) {
			NSLog(@"incorrect number of components in compoundIdentifier: [%@]", identifier);
			return nil;
		}
		NSString *ident = [compoundIdentifierComponents objectAtIndex:0];
		NSString *categoryName = [compoundIdentifierComponents objectAtIndex:1];
		
		// ====== find the machine using the identifer (uid) ======
		NSPredicate *machinePredicate = [NSPredicate predicateWithFormat:@"uid == %@", ident];
		NSArray *matchingMachines = [self.machines filteredArrayUsingPredicate:machinePredicate];
		if ([matchingMachines count] != 1) {
			NSLog(@"incorrect number of machine matches to selected appliance");
			return nil;
		}
		Machine *machineWhoCategoryBelongsTo = [matchingMachines objectAtIndex:0];
		
		// ====== find the category selected ======
		NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"name == %@", categoryName];
		NSArray *categories = [[machineWhoCategoryBelongsTo.request rootLevel] directories];
		NSArray *matchingCategories = [categories filteredArrayUsingPredicate:categoryPredicate];
		if ([matchingCategories count] != 1) {
			NSLog(@"incorrect number of category matches to selected appliance");
			return nil;
		}
		PlexMediaObject* matchingCategory = [matchingCategories objectAtIndex:0];
		HWPlexDir* menuController = [[HWPlexDir alloc] init];
		menuController.rootContainer = [matchingCategory contents];
		[[[BRApplicationStackManager singleton] stack] pushController:menuController];		
	}
	
	return [menuController autorelease];;
}

- (id)applianceCategories {
	return self.applianceCat;
}

- (id)identifierForContentAlias:(id)contentAlias { return @"Plex"; }
- (id)selectCategoryWithIdentifier:(id)ident { return nil; }
- (BOOL)handleObjectSelection:(id)fp8 userInfo:(id)fp12 { return YES; }
- (id)applianceSpecificControllerForIdentifier:(id)arg1 args:(id)arg2 { return nil; }
- (id)localizedSearchTitle { return @"Plex"; }
- (id)applianceName { return @"Plex"; }
- (id)moduleName { return @"Plex"; }
- (id)applianceKey { return @"Plex"; }


#pragma mark -
#pragma mark Sync Plex Categories With Appliances
NSString * const ApplianceNameKey = @"PlexApplianceName";
NSString * const MachineUIDKey = @"PlexMachineUID";

- (void)retrieveNewPlexCategories:(Machine *)m {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSLog(@"Retrieving categories for machine %@", m);
	PlexMediaContainer *rootContainer = [m.request rootLevel];
	NSMutableArray *directories = rootContainer.directories;
	
	for (PlexMediaObject *pmo in directories) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setObject:[pmo.name copy] forKey:ApplianceNameKey];
		[dict setObject:[m.uid copy] forKey:MachineUIDKey];
		[self performSelectorOnMainThread:@selector(addNewApplianceWithDict:) withObject:dict waitUntilDone:NO];
		NSLog(@"Adding category [%@] for machine uid [%@]", pmo.name, m.uid);
	}
	[pool drain];
	[m release];
}

- (void)addNewApplianceWithDict:(NSDictionary *)dict {
	//argument is a dict due to objects being passed between threads
	NSString *applianceName = [dict objectForKey:ApplianceNameKey];
	NSString *machineUid = [dict objectForKey:MachineUIDKey];
	
	[self addNewApplianceWithName:applianceName identifier:machineUid];
}
								
- (void)addNewApplianceWithName:(NSString *)name identifier:(id)ident {
	NSString *compoundIdentifier = [[NSString alloc] initWithFormat:@"%@%@%@", (NSString *)ident, CompoundIdentifierDelimiter, name];
	
	float applianceOrder = [self.applianceCat count];
	NSLog(@"Adding appliance with name [%@] with identifier [%@]", name, compoundIdentifier);
	BRApplianceCategory *appliance = [BRApplianceCategory categoryWithName:name identifier:compoundIdentifier preferredOrder:applianceOrder];
	[self.applianceCat addObject:appliance];
	[self reloadCategories];
}

- (void)removeAppliancesWithIdentifier:(id)ident {
	NSLog(@"Removing appliances with identifier [%@]", (NSString *)ident);
	//keep all items whose identifer does not the id
	NSPredicate *machinePredicate = [NSPredicate predicateWithFormat:@"identifier != %@", ident];
	[self.applianceCat filterUsingPredicate:machinePredicate];
}

#pragma mark -
#pragma mark Machine Delegate Methods
-(void)machineWasAdded:(Machine*)m{
	[self.machines addObject:m];
	NSLog(@"Added machine %@", m);
	
	[m resolveAndNotify:self];
	
	//retrieve new categories
	[self performSelectorInBackground:@selector(retrieveNewPlexCategories:) withObject:[m retain]];
}

-(void)machineStateDidChange:(Machine*)m{
	if (m==nil) return;
	
	if (runsServer(m.role) && ![self.machines containsObject:m]){
		[self machineWasAdded:m];
		return;
	} else if (!runsServer(m.role) && [self.machines containsObject:m]){
		[self.machines removeObject:m];
		NSLog(@"Removed %@", m);
		//[self removeAppliancesWithIdentifier:m.uid];
	} else {
		NSLog(@"Changed %@", m);
	}
	
	[self reloadCategories];
}

-(void)machineResolved:(Machine*)m{
	NSLog(@"Resolved %@", m);
}

-(void)machineDidNotResolve:(Machine*)m{
	NSLog(@"Unable to Resolve %@", m);
}

-(void)machineReceivedClients:(Machine*)m{
	NSLog(@"Got list of clients %@", m);
}

@end
