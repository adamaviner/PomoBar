#import "BackgroundView.h"
#import "StatusItemView.h"
#import "MenubarController.h"
#import "BreakPanelController.h"

@class PanelController;

@protocol PanelControllerDelegate <NSObject>

@optional

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller;

@end

#pragma mark -

@interface PanelController : NSWindowController <NSWindowDelegate>
{
    BOOL _hasActivePanel;
    __unsafe_unretained BackgroundView *_backgroundView;
    __unsafe_unretained id<PanelControllerDelegate> _delegate;
    StatusItemView *_statusItemView;
    BreakPanelController* breakPanelController;
}

@property (nonatomic, unsafe_unretained) IBOutlet BackgroundView *backgroundView;
@property (unsafe_unretained) IBOutlet NSTextField *setTimeTextField;
@property (unsafe_unretained) IBOutlet NSButton *goButton;
@property (retain) StatusItemView *statusItemView;
@property (unsafe_unretained) IBOutlet NSTextField *totalTimeLabel;
@property (unsafe_unretained) IBOutlet NSTextField *minsLabel;

- (IBAction)startTimer:(id)sender;

@property (nonatomic) BOOL hasActivePanel;
@property (nonatomic, unsafe_unretained, readonly) id<PanelControllerDelegate> delegate;

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate menubarController:(MenubarController*)menubarController;

- (void)openPanel;
- (void)closePanel;

@end
