//
//  CreditView.h
//  Aletteration
//
//  Created by David Nesbitt on 2012-10-22.
//
//

#import "NezBaseSceneView.h"
#import "AletterationGameState.h"

@interface CreditsView : NezBaseSceneView {
}

@property (nonatomic, retain) IBOutlet UITextView *creditsTextView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@end
