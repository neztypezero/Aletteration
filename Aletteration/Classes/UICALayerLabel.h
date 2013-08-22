//
//  UICALayerLabel.h
//  Aletteration
//
//  Created by David Nesbitt on 11-10-02.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

@interface UICALayerLabel : UILabel {
	CTFontRef fontRef;
}

@property (nonatomic, readonly, getter = getTextLayer) CATextLayer *textLayer;

-(BOOL)setLinkAttributes:(NSMutableAttributedString *)attrString;
-(BOOL)setCheckAttributes:(NSMutableAttributedString *)attrString;
-(BOOL)setCrossAttributes:(NSMutableAttributedString *)attrString;
-(BOOL)setSpecialLetterAttributes:(NSMutableAttributedString *)attrString;

-(void)setText:(NSString *)text;

@end
