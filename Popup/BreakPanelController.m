//
//  BreakPanelController.m
//  Popup
//
//  Created by Adam Aviner on 8/31/14.
//
//

#import "BreakPanelController.h"

#define LONG_BREAK 601
#define SHORT_BREAK 301

@interface BreakPanelController ()

@end

@implementation BreakPanelController

NSTimer* timer;
int timeLeft;
BOOL isLongBreak;

- (instancetype)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (id)init;
{
    if ((self = [super initWithWindowNibName:@"BreakPanelController"]) != nil) {
        isLongBreak = NO;
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


-(void) showBreakPanel{
    if (isLongBreak) {
        isLongBreak = NO;
        timeLeft = LONG_BREAK;
    } else {
        isLongBreak = YES;
        timeLeft = SHORT_BREAK;
    }
    [self countDown];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1//0.016 //TODO don't let user start another timer when in break
                                             target:self
                                           selector:@selector(countDown)
                                           userInfo:nil
                                            repeats:YES];
    
    [self showWindow:self];
    [self.window setLevel:NSFloatingWindowLevel];

}

-(void) countDown{
    timeLeft -= 1;
    int minutesLeft = timeLeft / 60;
    int secondsLeft = timeLeft % 60;
    
    NSString* timeLeftString =[NSString stringWithFormat:@"%d:%02d",minutesLeft, secondsLeft];
    [self.timeLeftLabel setStringValue:timeLeftString];
    
    if (timeLeft <=0) [self hideBreakPanel];
}

-(void) hideBreakPanel{
    [self.window orderOut:self];
    timeLeft = 5*60 + 1;
    [timer invalidate];
    timer = nil;
    [self countDown];
}

@end
