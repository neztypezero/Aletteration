//
//  ToolboxView.h
//  Aletteration
//
//  Created by David Nesbitt on 11-09-27.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "AletterationGameView.h"

@interface ToolboxView : AletterationGameView {
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *exitButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *optionsButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *resumeButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *scoringButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *quickRulesButton;

@end
