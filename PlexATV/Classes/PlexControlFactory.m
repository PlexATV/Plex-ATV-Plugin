//
//  Plex_SMFControlFactory.m
//  plex
//
//  Created by bob on 2011-04-08.
//

#import "PlexControlFactory.h"
#import <BackRow/BRURLImageProxy.h>

@implementation PlexControlFactory

//Returns the control shown on main menu
-(id)initForMainMenu:(BOOL)arg1
{
    self = [super initForMainMenu:arg1];
    _mainmenu = arg1;
    self._poster=YES;
    self.defaultImage=nil;
    self.favorProxy=YES;
    self._alwaysShowTitles=NO;
    return self;
}
- (float)heightForControlForData:(id)data requestedBy:(id)by {
    return 206.0f;
}

-(BRControl *)controlForImageProxy:(BRURLImageProxy *)imageProxy title:(NSString *)title {
    BRPosterControl *returnObj = [[BRPosterControl alloc] init];
    //returnObj.posterStyle = 1;
    returnObj.title = [[NSAttributedString alloc]initWithString:title attributes:[[BRThemeInfo sharedTheme] menuItemSmallTextAttributes]];
    returnObj.imageProxy=imageProxy;
    
    returnObj.defaultImage=self.defaultImage;
    returnObj.alwaysShowTitles=self._alwaysShowTitles;
    returnObj.posterBorderWidth=1.0f;
    returnObj.titleWidthScale=1.0f;
    returnObj.titleVerticalOffset=0.0f;
    returnObj.reflectionAmount=0.14000000059604645;
    @try {
        [returnObj performSelector:@selector(setIgnoreLoadAndDisplayOnDemand)];
    }
    @catch (NSException *exception) {
        /* silently ignore the exception here */
    }
    
    return [returnObj autorelease];
}

@end
