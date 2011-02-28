//
//  Plex_SMFBookcaseController.h
//  SMFramework
//
//  Created by Chris Jensen on 2/26/11.
//

#import "Plex_SMFBookcaseController.h"
#import <Backrow/BRThemeInfo.h>

@interface Plex_SMFBookcaseController (private)
- (void)selectEventOccured;
@end

@implementation Plex_SMFBookcaseController
@synthesize delegate;
@synthesize datasource;

-(id)init {
	if (self = [super init]) {
		_shelfControls = [[NSMutableArray alloc] init];
		_shelfTitles = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void)dealloc {
    self.datasource = nil;
    self.delegate = nil;
    [_shelfControls release];
	[_shelfTitles release];
	[_panelControl release];
	
    [super dealloc];
}

-(void)controlWasActivated {
	//only reload if we need to, ie empty shelf
    if ([_shelfControls count] == 0) 
		[self reload];
    [super controlWasActivated];
}

- (void)reload {
	[self _removeAllControls];
	[_shelfControls removeAllObjects];
	[_shelfTitles removeAllObjects];
	
	numberOfShelfControls = [self.datasource numberOfShelfsInBookcaseController:self];
	if (numberOfShelfControls < 1) {
		return; //empty bookcase, our work here is done
	}
	
	/* View layout:
	 *
	 * Scroller
	 * - Panel
	 *  - Top Spacer (44px)
	 *  - Header
	 *    - title    image (optional)
	 *  - Title Spacer (18px)
	 *  - Box_n
	 *    - divider + title (optional)
	 *    - shelf
	 *  - Box_n+1 (divider + title ; shelf)
	 *  - ...
	 *  - Box_n+(numberOfShelfControls-1) (divider + title ; shelf)
	 *  - Bottom Spacer (44px)
	 */
	
	CGRect masterFrame = [BRWindow interfaceFrame];
	
	if (_panelControl) {
		[_panelControl release];
		_panelControl = nil;
	}
	_panelControl = [[BRPanelControl alloc] init];
	[_panelControl setFrame:masterFrame];
	[_panelControl setPanelMode:1];
	
	//============================ TOP SPACER ============================
	BRSpacerControl *spacerTop = [BRSpacerControl spacerWithPixels:44.0f];
	[_panelControl addControl:spacerTop];	
	
	//============================ HEADER TITLE ============================
	BRHeaderControl *headerControl = [[BRHeaderControl alloc] init];
	[headerControl setTitle:[self.datasource headerTitleForBookcaseController:self] withAttributes:[[BRThemeInfo sharedTheme] menuTitleTextAttributes]];
	
	//============================ HEADER ICON ============================	
	if ([self.datasource respondsToSelector:@selector(headerIconForBookcaseController:)]) {
		BRImage *headerIcon = [self.datasource headerIconForBookcaseController:self];
		[headerControl setIcon:headerIcon position:2 edgeSpace:64];
	}
	[_panelControl addControl:headerControl];
	[headerControl release];
	
	//============================ HEADER SPACER ============================
	BRSpacerControl *spacerHeader = [BRSpacerControl spacerWithPixels:19.0f];
	[_panelControl addControl:spacerHeader];	
	
	//start adding shelves
	for (int i = 0; i < numberOfShelfControls; i++) {		
		//=============== SHELF DIVIDER WITH OPTIONAL TITLE ===============
		NSString *title = nil;
		if ([self.datasource respondsToSelector:@selector(bookcaseController:titleForShelfAtIndex:)]) {
			title = [self.datasource bookcaseController:self titleForShelfAtIndex:i];
		}
		BRDividerControl *dividerLine = [[BRDividerControl alloc] init];
		dividerLine.drawsLine = YES;
		[dividerLine setStartOffsetText:0];
		[dividerLine setAlignmentFactor:0.5f];
		[dividerLine setLineThickness:1.0f];
		[dividerLine setBrightness:0.10000000149011612f];
		if (title) [dividerLine setLabel:title withAttributes:[[BRThemeInfo sharedTheme] boxTitleAttributesForRelated:NO]];
		
		//============================ SHELF ============================
		BRMediaShelfControl *shelfControl = [[BRMediaShelfControl alloc] init];
		[shelfControl setProvider:[self.datasource bookcaseController:self datastoreProviderForShelfAtIndex:i]];
		CGRect shelfFrame = shelfControl.frame;
		shelfFrame.size.height = 215.0f;
		[shelfControl setColumnCount:7];
		[shelfControl setCentered:NO];
		[shelfControl setHorizontalGap:23];
		[shelfControl setCoverflowMargin:0.05000000074505806f];
		[_shelfControls addObject:shelfControl];
		
		
		//============================ SHELF BOX ============================
		BRBoxControl *shelfBox = [[BRBoxControl alloc] init];
		[shelfBox setAcceptsFocus:YES];
		[shelfBox setDividerSuggestedHeight:46.0f];
		[shelfBox setDividerMargin:0.05000000074505806f];
		[shelfBox setSpace:0.0f];
		[shelfBox setContent:shelfControl];
		[shelfBox setDivider:dividerLine];
		[shelfBox layoutSubcontrols];
		CGRect boxFrame = shelfBox.frame;
		boxFrame.size.height = 260.0f;
		[shelfBox setFrame:boxFrame];
		[_panelControl addControl:shelfBox];
		
		[shelfBox release];
		[shelfControl release];
		[dividerLine release];
	}
	
	//============================ BOTTOM SPACER ============================
	BRSpacerControl *spacerBottom = [BRSpacerControl spacerWithPixels:44.0f];
	[_panelControl addControl:spacerBottom];
	
	[_panelControl layoutSubcontrols];
	
	//============================ CURSOR ============================
	BRCursorControl *cursorControl = [[BRCursorControl alloc] init];
	[self addControl:cursorControl];
	[cursorControl release];
	
	//============================ SCROLL ============================
	BRScrollControl *_scrollControl = [[BRScrollControl alloc] init];
	[_scrollControl setFrame:masterFrame];
	[_scrollControl setFollowsFocus:YES];
	[_scrollControl setAcceptsFocus:YES];
	[_scrollControl setContent:_panelControl];
	
	[self addControl:_scrollControl];
	[_scrollControl release];
	
	[self layoutSubcontrols];
}

- (void)reloadDataForAllShelfControls {
	for (int i = 0; i<[_shelfControls count]; i++) {
		[self reloadDataForShelfAtIndex:i];
	}
}

- (void)reloadDataForShelfAtIndex:(NSInteger)index {
	if (index < [_shelfControls count] && index >= 0) {
		BRMediaShelfControl *shelfControl = [_shelfControls objectAtIndex:index];
		[shelfControl reloadData];
	}
}

-(BOOL)brEventAction:(BREvent *)action {
	if ([[self stack] peekController] != self)
		return [super brEventAction:action];
	int remoteAction = [action remoteAction];	
	if (remoteAction == kBREventRemoteActionPlay && action.value == 1) {
		[self selectEventOccured];
		return YES;
	}
	return [super brEventAction:action];
}

//private
- (void)selectEventOccured {
	if (self.delegate) {
		BRMediaShelfControl *focusedShelf = nil;
		id focusedBox = [_panelControl focusedControl];
		id currentFocusedControl = [focusedBox focusedControl];
		if (currentFocusedControl && [currentFocusedControl isKindOfClass:[BRMediaShelfControl class]]) {
			focusedShelf = (BRMediaShelfControl *)currentFocusedControl;
		}
		if (focusedShelf) {
			int index = [focusedShelf focusedIndex];
			if ([self.delegate bookcaseController:self allowSelectionForShelf:focusedShelf atIndex:index]) {
				if ([self.delegate respondsToSelector:@selector(bookcaseController:selectionWillOccurInShelf:atIndex:)]) {
					[self.delegate bookcaseController:self selectionWillOccurInShelf:focusedShelf atIndex:index];
				}
				[[SMFThemeInfo sharedTheme] playSelectSound];
				if ([self.delegate respondsToSelector:@selector(bookcaseController:selectionDidOccurInShelf:atIndex:)]) {
					[self.delegate bookcaseController:self selectionDidOccurInShelf:focusedShelf atIndex:index];
				}
			} else {
				//selection not handled for this item in this shelf
				[[SMFThemeInfo sharedTheme] playErrorSound];
			}
		}	
	}
}

@end
