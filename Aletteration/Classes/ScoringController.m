//
//  ScoringController.m
//  Aletteration
//
//  Created by David Nesbitt on 2012-09-30.
//
//

#import "ScoringController.h"

@interface ScoringController ()

@end

@implementation ScoringController

+(void)showView:(UIViewController*)parentViewController {
	NSString *nibName = @"ScoringController";
	ScoringController *controller = [[ScoringController alloc] initWithNibName:nibName bundle:nil];
    
    CGSize size = controller.view.frame.size;
    CGRect r = CGRectMake(0, size.height, size.width, size.height);
    controller.view.frame = r;
    
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
    	    [self.view removeFromSuperview];
    	    [self release];
        }
    ];
}

@end
