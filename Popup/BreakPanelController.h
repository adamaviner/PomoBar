//
//  BreakPanelController.h
//  Popup
//
//  Created by Adam Aviner on 8/31/14.
//
//

#import <Cocoa/Cocoa.h>

@interface BreakPanelController : NSWindowController

@property (weak) IBOutlet NSTextField *timeLeftLabel;
-(void) showBreakPanel;

@end
