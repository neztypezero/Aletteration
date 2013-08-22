//
//  PhotoChoiceView.h
//  Aletteration
//
//  Created by David Nesbitt on 11-10-11.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "NezBaseSceneView.h"

@interface PhotoChoiceView : NezBaseSceneView {
}

@property (nonatomic, retain) IBOutlet UIImageView *mainImageView;
@property (nonatomic, retain) IBOutlet UIScrollView *thumbnailScrollView;
@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, retain) IBOutlet UINavigationItem *albumNavigationItem;
@property (nonatomic, retain) IBOutlet UINavigationItem *photoNavigationItem;
@property (nonatomic, retain) IBOutlet UINavigationItem *editNavigationItem;
@property (nonatomic, retain) IBOutlet UIView *editOutlineView;

@end
