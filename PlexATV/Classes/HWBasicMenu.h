
#import <plex-oss/MachineManager.h>
@interface HWBasicMenu : BRMediaMenuController<MachineManagerDelegate> {

    NSMutableArray          *_ownServer;
    NSMutableArray          *_sharedServers;

}
//list provider
- (float)heightForRow:(long)row;
- (long)itemCount;
- (id)itemForRow:(long)row;
- (BOOL)rowSelectable:(long)selectable;
- (id)titleForRow:(long)row;
- (void)setNeedsUpdate;


@property (readonly) NSArray *combinedServers;
@end
