#import "PanelController.h"
#import "BackgroundView.h"
#import "StatusItemView.h"
#import "MenubarController.h"

#define OPEN_DURATION .10
#define CLOSE_DURATION .1

#define SEARCH_INSET 17

#define POPUP_HEIGHT 140
#define PANEL_WIDTH 120
#define MENU_ANIMATION_DURATION .1

#pragma mark -

@implementation PanelController

@synthesize backgroundView = _backgroundView;
@synthesize delegate = _delegate;
@synthesize setTimeTextField = _setTimeTextField;
@synthesize goButton = _goButton;

#pragma mark -

NSTimer* timer;
int timeLeft;
int totalTime;
BOOL countingDown;
BOOL isPaused;
MenubarController* menubarController;


- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate menubarController:(MenubarController*)menubarController_
{
    self = [super initWithWindowNibName:@"Panel"];
    if (self != nil)
    {
        _delegate = delegate;
        menubarController = menubarController_;
        countingDown = NO;
        isPaused = NO;
    }
    return self;
}

- (void)dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSControlTextDidChangeNotification object:self.searchField];
}

#pragma mark -

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Make a fully skinned panel
    NSPanel *panel = (id)[self window];
    [panel setAcceptsMouseMovedEvents:YES];
    [panel setLevel:NSPopUpMenuWindowLevel];
    [panel setOpaque:NO];
    [panel setBackgroundColor:[NSColor clearColor]];
    
    
    [self.setTimeTextField setTarget:self];
    [self.setTimeTextField setAction:@selector(startTimer:)];

//    wc = [[NSWindowController alloc] initWithWindowNibName:@"BreakPanel"];
    breakPanelController = [[BreakPanelController alloc] init];

    
    // Follow search string
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(runSearch) name:NSControlTextDidChangeNotification object:self.searchField];
}

#pragma mark - Public accessors

- (IBAction)startTimer:(id)sender {
    if (countingDown){
        [self pauseTimer];
        return;
    }
    
    int time = [self.setTimeTextField intValue];
    if (time == 0) time = 25;
    
    if (!isPaused){
        totalTime = time * 60;
        timeLeft = time * 60;
    }
    
    [self.totalTimeLabel setIntValue:totalTime / 60];
    [self.totalTimeLabel setHidden:NO];
    [self.minsLabel setHidden:NO];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1//0.016666667
                                     target:self
                                   selector:@selector(updateTime)
                                   userInfo:nil
                                    repeats:YES];
    
    [self.goButton setImage:[NSImage imageNamed:@"Pause"]];
    countingDown = YES;
    
    
}

- (void)updateTime{
    timeLeft -= 1;
    [self.setTimeTextField setStringValue:[NSString stringWithFormat:@"%d",timeLeft / 60]];
    int stepInCountDown = timeLeft * 60 / totalTime;
    [menubarController updateIconWithTimeLeft:stepInCountDown];
    if (timeLeft <= 0) [self stopTimer];
}

- (void)pauseTimer{
    [timer invalidate];
    timer = nil;
    [self.goButton setImage:[NSImage imageNamed:@"Play"]];
    countingDown = NO;
    isPaused = YES;
}

- (void)stopTimer{
    [self pauseTimer];
    [self.setTimeTextField setIntValue:totalTime/60];
    [self.totalTimeLabel setHidden:YES];
    [self.minsLabel setHidden:YES];
    isPaused = NO;
//    [self showBreakPanel];
    [breakPanelController showBreakPanel]; //TODO use the timer here to countdown the menubar icon as well, and block redoing timer, and remotly control breakPanel countdown.
    //TODO as a user I sometimes need a couple more minutes before the break, maybe limit to twice.
}

//-(void) hideBreakPanel {
//    [breakPanelController.window orderOut:self];
//}

- (BOOL)hasActivePanel
{
    return _hasActivePanel;
}

- (void)setHasActivePanel:(BOOL)flag
{
    if (_hasActivePanel != flag)
    {
        _hasActivePanel = flag;
        
        if (_hasActivePanel)
        {
            [self openPanel];
        }
        else
        {
            [self closePanel];
        }
    }
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    self.hasActivePanel = NO;
}

- (void)windowDidResignKey:(NSNotification *)notification;
{
    if ([[self window] isVisible])
    {
        self.hasActivePanel = NO;
    }
}

- (void)windowDidResize:(NSNotification *)notification
{
    NSWindow *panel = [self window];
    NSRect statusRect = [self statusRectForWindow:panel];
    NSRect panelRect = [panel frame];
    
    CGFloat statusX = roundf(NSMidX(statusRect));
    CGFloat panelX = statusX - NSMinX(panelRect);
    
    self.backgroundView.arrowX = panelX;
}

#pragma mark - Keyboard

- (void)cancelOperation:(id)sender
{
    self.hasActivePanel = NO;
}

#pragma mark - Public methods

- (NSRect)statusRectForWindow:(NSWindow *)window
{
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = NSZeroRect;
    
    StatusItemView *statusItemView = nil;
    if ([self.delegate respondsToSelector:@selector(statusItemViewForPanelController:)])
    {
        statusItemView = [self.delegate statusItemViewForPanelController:self];
    }
    
    if (statusItemView)
    {
        statusRect = statusItemView.globalRect;
        statusRect.origin.y = NSMinY(statusRect) - NSHeight(statusRect);
    }
    else
    {
        statusRect.size = NSMakeSize(STATUS_ITEM_VIEW_WIDTH, [[NSStatusBar systemStatusBar] thickness]);
        statusRect.origin.x = roundf((NSWidth(screenRect) - NSWidth(statusRect)) / 2);
        statusRect.origin.y = NSHeight(screenRect) - NSHeight(statusRect) * 2;
    }
    return statusRect;
}

- (void)openPanel
{
    NSWindow *panel = [self window];
    
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = [self statusRectForWindow:panel];

    NSRect panelRect = [panel frame];
    panelRect.size.width = PANEL_WIDTH;
    panelRect.size.height = POPUP_HEIGHT;
    panelRect.origin.x = roundf(NSMidX(statusRect) - NSWidth(panelRect) / 2);
    panelRect.origin.y = NSMaxY(statusRect) - NSHeight(panelRect);
    
    if (NSMaxX(panelRect) > (NSMaxX(screenRect) - ARROW_HEIGHT))
        panelRect.origin.x -= NSMaxX(panelRect) - (NSMaxX(screenRect) - ARROW_HEIGHT);
    
    [NSApp activateIgnoringOtherApps:NO];
    [panel setAlphaValue:0];
    [panel setFrame:statusRect display:YES];
    [panel makeKeyAndOrderFront:nil];
    
    NSTimeInterval openDuration = OPEN_DURATION;
    
    NSEvent *currentEvent = [NSApp currentEvent];
    if ([currentEvent type] == NSLeftMouseDown)
    {
        NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
        BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
        BOOL shiftOptionPressed = (clearFlags == (NSShiftKeyMask | NSAlternateKeyMask));
        if (shiftPressed || shiftOptionPressed)
        {
            openDuration *= 10;
            
            if (shiftOptionPressed)
                NSLog(@"Icon is at %@\n\tMenu is on screen %@\n\tWill be animated to %@",
                      NSStringFromRect(statusRect), NSStringFromRect(screenRect), NSStringFromRect(panelRect));
        }
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[panel animator] setFrame:panelRect display:YES];
    [[panel animator] setAlphaValue:1];
    [NSAnimationContext endGrouping];
    
    [panel performSelector:@selector(makeFirstResponder:) withObject:self.goButton];
    
    
}

- (void)closePanel
{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:CLOSE_DURATION];
    [[[self window] animator] setAlphaValue:0];
    [NSAnimationContext endGrouping];
    
    dispatch_after(dispatch_walltime(NULL, NSEC_PER_SEC * CLOSE_DURATION * 2), dispatch_get_main_queue(), ^{
        
        [self.window orderOut:nil];
    });
}

@end
