//
//  CreditsController.m
//  Aletteration
//
//  Created by David Nesbitt on 2012-10-22.
//
//

#import "CreditsController.h"
#import "CreditsView.h"

@interface CreditsController ()

@end

@implementation CreditsController

+(void)showView:(UIViewController*)parentViewController {
	NSString *nibName = @"CreditsController";
	CreditsController *controller = [[CreditsController alloc] initWithNibName:nibName bundle:nil];
	
	controller.view.alpha = 0.0;
	[parentViewController.view addSubview:controller.view];
	
	[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 controller.view.alpha = 1.0;
					 }
					 completion:^(BOOL completed) {
					 }
	 ];
}

-(void)closeDialog:(id)sender {
	[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 self.view.alpha = 0.0;
					 }
					 completion:^(BOOL completed) {
						 [self.view removeFromSuperview];
						 [self release];
					 }
	 ];
}


-(void)linkTap:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.aletteration.com"]];
}

-(void)viewDidLayoutSubviews {
	CreditsView *v = (CreditsView*)self.view;
	v.scrollView.contentSize = v.creditsTextView.frame.size;
	scrollingCredits = NO;
	[self performSelector:@selector(scrollCredits) withObject:nil afterDelay:0.1];
}

-(void)scrollCredits {
	CreditsView *v = (CreditsView*)self.view;
	scrollingCredits = YES;
	v.scrollView.contentOffset = CGPointMake(0.0, -v.scrollView.bounds.size.height);
	v.creditsTextView.hidden = NO;
	CGPoint bottomOffset = CGPointMake(0, v.scrollView.contentSize.height - v.scrollView.bounds.size.height);
	[UIView animateWithDuration:20.0
						  delay:0.0
						options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 v.scrollView.contentOffset = bottomOffset;
					 }
					 completion:^(BOOL finished) {
						 if (!finished) {
							 v.scrollView.contentOffset = scrolledToPoint;
						 }
					 }
	 ];
}

-(void)scrollViewWillBeginDragging:(UIScrollView*)scrollView {
	if (scrollingCredits == YES) {
		scrollingCredits = NO;
		CreditsView *v = (CreditsView*)self.view;
		CALayer *presentationLayer = v.scrollView.layer.presentationLayer;
		scrolledToPoint = presentationLayer.bounds.origin;
		[v.scrollView.layer removeAllAnimations];
	}
}

@end
