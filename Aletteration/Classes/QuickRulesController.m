//
//  QuickRulesController.m
//  Aletteration
//
//  Created by David Nesbitt on 2012-09-30.
//
//

#import "QuickRulesController.h"
#import "QuickRulesView.h"

@interface QuickRulesController ()

@end

@implementation QuickRulesController

@synthesize onCloseDelegate;
@synthesize onCloseSelector;
@synthesize onContinueSelector;

+(void)showView:(UIViewController*)parentViewController onCloseSelector:(SEL)onClose onContinueSelector:(SEL)onContinue {
	NSString *nibName = @"QuickRulesController";
	QuickRulesController *controller = [[QuickRulesController alloc] initWithNibName:nibName bundle:nil];
    
    CGSize size = controller.view.frame.size;
    CGRect r = CGRectMake(0, size.height, size.width, size.height);
    controller.view.frame = r;
    
	controller.onCloseDelegate = parentViewController;
	controller.onCloseSelector = onClose;
	controller.onContinueSelector = onContinue;

	[parentViewController.view addSubview:controller.view];

	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
        animations:^{
        	controller.view.frame = CGRectMake(0, 0, size.width, size.height);
        }
        completion:^(BOOL completed) {
        }
    ];
}

-(void)closeDialog:(id)sender {
    CGSize size = self.view.frame.size;
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseIn
        animations:^{
        	self.view.frame = CGRectMake(0, size.height, size.width, size.height);
        }
        completion:^(BOOL completed) {
            if (self.onCloseDelegate) {
                QuickRulesView *v = (QuickRulesView*)self.view;
                if (sender == v.closeButton) {
                    if (self.onCloseSelector) {
                        [self.onCloseDelegate performSelector:self.onCloseSelector withObject:nil];
                    }
                } else if (sender == v.nextButton) {
                    if (self.onContinueSelector) {
                        [self.onCloseDelegate performSelector:self.onContinueSelector withObject:nil];
                    }
                }
            }
    	    [self.view removeFromSuperview];
    	    [self release];
        }
    ];
}

-(void)dealloc {
	self.onCloseDelegate = nil;
	self.onCloseSelector = nil;
	self.onContinueSelector = nil;
	[super dealloc];
}

@end
