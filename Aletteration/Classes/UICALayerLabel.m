//
//  UICALayerLabel.m
//  Aletteration
//
//  Created by David Nesbitt on 11-10-02.
//  Copyright 2011 David Nesbitt. All rights reserved.
//

#import "UICALayerLabel.h"


CTFontRef CTFontCreateFromUIFont(UIFont *font) {
	if (font == nil) {
		return CTFontCreateWithName((CFStringRef)@"System", 12.0, NULL);
	} else {
		return CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
	}
}

@implementation UICALayerLabel

+(Class)layerClass {
    return [CATextLayer class];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
		//NSLog(@"calabel:initWithCoder %@", self.text);
		CGFloat scale = [[UIScreen mainScreen] scale];
		self.textLayer.contentsScale = scale;
		
		switch (self.textAlignment) {
			case UITextAlignmentCenter: {
				self.textLayer.alignmentMode = kCAAlignmentCenter;
				break;
			}
			case UITextAlignmentRight: {
				self.textLayer.alignmentMode = kCAAlignmentRight;
				break;
			}
			default: {
				self.textLayer.alignmentMode = kCAAlignmentLeft;
			}
		}
		self.textLayer.wrapped = NO;
		self.textLayer.opaque = NO;
		
		fontRef = CTFontCreateFromUIFont(self.font);
		
		CGRect r = self.bounds;
		
		self.textLayer.bounds = CGRectMake(r.origin.x, r.origin.y-2.0, r.size.width, r.size.height+4.0);
	}
    return self;
}

-(void)setText:(NSString *)text {
	super.text = text;
	if (self.text != nil) {
		NSDictionary *baseAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
										(id)fontRef, (NSString *)kCTFontAttributeName, 
										(id)[[UIColor blackColor] CGColor], (NSString *)kCTForegroundColorAttributeName, nil];
		NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:self.text attributes:baseAttributes];
		
		BOOL attributesSet = NO;
		attributesSet |= [self setLinkAttributes:attrString];
		attributesSet |= [self setCheckAttributes:attrString];
		attributesSet |= [self setCrossAttributes:attrString];
		attributesSet |= [self setSpecialLetterAttributes:attrString];
		
		if (attributesSet == NO) {
			NSRange wholeRange = { 0, self.text.length };
			[attrString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[self.textColor CGColor] range:wholeRange];
		}
		self.textLayer.string = attrString;
	}
}

-(BOOL)setLinkAttributes:(NSMutableAttributedString *)attrString {
	//NSDataDetector is part of the new (in iOS 4) regular expression engine
	Class nsDataDetector = NSClassFromString(@"NSDataDetector");
	static BOOL linkFound;
	linkFound = NO;
	if(nsDataDetector) {
		NSError *error = nil;
		id linkDetector = [nsDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
		[linkDetector enumerateMatchesInString:[attrString string]
									   options:0 
										 range:NSMakeRange(0, [attrString length]) 
									usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) 
		 {
			 [attrString addAttribute:(NSString *)kCTForegroundColorAttributeName 
								value:(id)[[UIColor blueColor] CGColor] 
								range:[match range]];
			 
			 [attrString addAttribute:(NSString *)kCTUnderlineStyleAttributeName 
								value:[NSNumber numberWithInt:kCTUnderlineStyleSingle] 
								range:[match range]];
			 linkFound = YES;
		 }];
	}
	return linkFound;
}

-(BOOL)setCheckAttributes:(NSMutableAttributedString *)attrString {
	NSCharacterSet *checkCharSet = [NSCharacterSet characterSetWithCharactersInString:@"✔"];
	NSRange checkRange = [[attrString string] rangeOfCharacterFromSet:checkCharSet];
	if (checkRange.location != NSNotFound && checkRange.length > 0) {
		[attrString addAttribute:(NSString *)kCTForegroundColorAttributeName 
						   value:(id)[[UIColor greenColor] CGColor] 
						   range:checkRange];
		[attrString addAttribute:(NSString *)kCTStrokeWidthAttributeName 
						   value:(id)[NSNumber numberWithFloat:-3.0] 
						   range:checkRange];
		[attrString addAttribute:(NSString *)kCTStrokeColorAttributeName 
						   value:(id)[[UIColor blackColor] CGColor] 
						   range:checkRange];
		return YES;
	}
	return NO;
}

-(BOOL)setCrossAttributes:(NSMutableAttributedString *)attrString {
	NSCharacterSet *checkCharSet = [NSCharacterSet characterSetWithCharactersInString:@"✘"];
	NSRange checkRange = [[attrString string] rangeOfCharacterFromSet:checkCharSet];
	if (checkRange.location != NSNotFound && checkRange.length > 0) {
		[attrString addAttribute:(NSString *)kCTForegroundColorAttributeName 
						   value:(id)[[UIColor redColor] CGColor] 
						   range:checkRange];
		[attrString addAttribute:(NSString *)kCTStrokeWidthAttributeName 
						   value:(id)[NSNumber numberWithFloat:-3.0] 
						   range:checkRange];
		[attrString addAttribute:(NSString *)kCTStrokeColorAttributeName 
						   value:(id)[[UIColor blackColor] CGColor] 
						   range:checkRange];
		return YES;
	}
	return NO;
}

-(BOOL)setSpecialLetterAttributes:(NSMutableAttributedString *)attrString {
	NSCharacterSet *checkCharSet = [NSCharacterSet characterSetWithCharactersInString:@"jqxz"];
	NSRange checkRange = [[attrString string] rangeOfCharacterFromSet:checkCharSet];
	if (checkRange.location != NSNotFound && checkRange.length > 0) {
		[attrString addAttribute:(NSString *)kCTForegroundColorAttributeName 
						   value:(id)[[UIColor blackColor] CGColor] 
						   range:checkRange];
		[attrString addAttribute:(NSString *)kCTStrokeWidthAttributeName 
						   value:(id)[NSNumber numberWithFloat:-3.0] 
						   range:checkRange];
		[attrString addAttribute:(NSString *)kCTStrokeColorAttributeName 
						   value:(id)[[UIColor colorWithRed:197.0/255.0 green:158.0/255.0 blue:0.0 alpha:1.0] CGColor] 
						   range:checkRange];
		return YES;
	}
	return NO;
}

-(BOOL)setBonusAttributes:(NSMutableAttributedString *)attrString {
	NSCharacterSet *checkCharSet = [NSCharacterSet characterSetWithCharactersInString:@"+"];
	NSRange checkRange = [[attrString string] rangeOfCharacterFromSet:checkCharSet];
	if (checkRange.location != NSNotFound) {
		checkRange.location = 0;
		checkRange.length = [[attrString string] length];
		[attrString addAttribute:(NSString *)kCTForegroundColorAttributeName 
						   value:(id)[[UIColor blackColor] CGColor] 
						   range:checkRange];
		[attrString addAttribute:(NSString *)kCTStrokeWidthAttributeName 
						   value:(id)[NSNumber numberWithFloat:-3.0] 
						   range:checkRange];
		[attrString addAttribute:(NSString *)kCTStrokeColorAttributeName 
						   value:(id)[[UIColor whiteColor] CGColor] 
						   range:checkRange];
		return YES;
	}
	return NO;
}

-(CATextLayer*)getTextLayer {
	return (CATextLayer*)self.layer;
}

-(void)dealloc {
	if (fontRef != nil) {
		CFRelease(fontRef); 
	}
	[super dealloc];
}

@end
