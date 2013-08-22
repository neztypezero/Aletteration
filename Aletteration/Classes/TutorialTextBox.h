//
//  TutorialTextBox.h
//  Aletteration
//
//  Created by David Nesbitt on 12-06-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define kTutorialRootObject @"TTBARRAY"

#define kTutorialActionNone @"TA_NONE"
#define kTutorialActionSlideDefault @"TA_SLIDE_DEFAULT"
#define kTutorialActionSlideWordList @"TA_SLIDE_WORD_LIST"
#define kTutorialActionSlideJunk @"TA_SLIDE_JUNK"
#define kTutorialActionPause @"TA_PAUSE"
#define kTutorialActionResume @"TA_RESUME"
#define kTutorialActionScoring @"TA_SCORING"

#define kTutorialActionLineX @"TA_LINE"
#define kTutorialActionLineXSubX @"TA_LINEX_SUBX"

#define kTutorialActionLine1Sub1 @"TA_LINE1_SUB1"
#define kTutorialActionLine1Sub2 @"TA_LINE1_SUB2"
#define kTutorialActionLine1Sub3 @"TA_LINE1_SUB3"
#define kTutorialActionLine1Sub4 @"TA_LINE1_SUB4"
#define kTutorialActionLine1Sub5 @"TA_LINE1_SUB5"
#define kTutorialActionLine1Sub6 @"TA_LINE1_SUB6"
#define kTutorialActionLine1Sub7 @"TA_LINE1_SUB7"
#define kTutorialActionLine1Sub8 @"TA_LINE1_SUB8"
#define kTutorialActionLine1Sub9 @"TA_LINE1_SUB9"

#define kTutorialActionLine2Sub1 @"TA_LINE2_SUB1"
#define kTutorialActionLine2Sub2 @"TA_LINE2_SUB2"
#define kTutorialActionLine2Sub3 @"TA_LINE2_SUB3"
#define kTutorialActionLine2Sub4 @"TA_LINE2_SUB4"
#define kTutorialActionLine2Sub5 @"TA_LINE2_SUB5"
#define kTutorialActionLine2Sub6 @"TA_LINE2_SUB6"
#define kTutorialActionLine2Sub7 @"TA_LINE2_SUB7"
#define kTutorialActionLine2Sub8 @"TA_LINE2_SUB8"
#define kTutorialActionLine2Sub9 @"TA_LINE2_SUB9"

#define kTutorialActionLine3Sub1 @"TA_LINE3_SUB1"
#define kTutorialActionLine3Sub2 @"TA_LINE3_SUB2"
#define kTutorialActionLine3Sub3 @"TA_LINE3_SUB3"
#define kTutorialActionLine3Sub4 @"TA_LINE3_SUB4"
#define kTutorialActionLine3Sub5 @"TA_LINE3_SUB5"
#define kTutorialActionLine3Sub6 @"TA_LINE3_SUB6"
#define kTutorialActionLine3Sub7 @"TA_LINE3_SUB7"
#define kTutorialActionLine3Sub8 @"TA_LINE3_SUB8"
#define kTutorialActionLine3Sub9 @"TA_LINE3_SUB9"

#define kTutorialActionLine4Sub1 @"TA_LINE4_SUB1"
#define kTutorialActionLine4Sub2 @"TA_LINE4_SUB2"
#define kTutorialActionLine4Sub3 @"TA_LINE4_SUB3"
#define kTutorialActionLine4Sub4 @"TA_LINE4_SUB4"
#define kTutorialActionLine4Sub5 @"TA_LINE4_SUB5"
#define kTutorialActionLine4Sub6 @"TA_LINE4_SUB6"
#define kTutorialActionLine4Sub7 @"TA_LINE4_SUB7"
#define kTutorialActionLine4Sub8 @"TA_LINE4_SUB8"
#define kTutorialActionLine4Sub9 @"TA_LINE4_SUB9"

#define kTutorialActionLine5Sub1 @"TA_LINE5_SUB1"
#define kTutorialActionLine5Sub2 @"TA_LINE5_SUB2"
#define kTutorialActionLine5Sub3 @"TA_LINE5_SUB3"
#define kTutorialActionLine5Sub4 @"TA_LINE5_SUB4"
#define kTutorialActionLine5Sub5 @"TA_LINE5_SUB5"
#define kTutorialActionLine5Sub6 @"TA_LINE5_SUB6"
#define kTutorialActionLine5Sub7 @"TA_LINE5_SUB7"
#define kTutorialActionLine5Sub8 @"TA_LINE5_SUB8"
#define kTutorialActionLine5Sub9 @"TA_LINE5_SUB9"

#define kTutorialActionLine6Sub1 @"TA_LINE6_SUB1"
#define kTutorialActionLine6Sub2 @"TA_LINE6_SUB2"
#define kTutorialActionLine6Sub3 @"TA_LINE6_SUB3"
#define kTutorialActionLine6Sub4 @"TA_LINE6_SUB4"
#define kTutorialActionLine6Sub5 @"TA_LINE6_SUB5"
#define kTutorialActionLine6Sub6 @"TA_LINE6_SUB6"
#define kTutorialActionLine6Sub7 @"TA_LINE6_SUB7"
#define kTutorialActionLine6Sub8 @"TA_LINE6_SUB8"
#define kTutorialActionLine6Sub9 @"TA_LINE6_SUB9"

@interface TutorialTextBox : NSObject<NSCoding> {
}

@property(nonatomic,copy) NSString *text;
@property(nonatomic,retain) NSMutableArray *autoLetterList;
@property(nonatomic,assign) CGRect frame;
@property(nonatomic,assign) BOOL autoNextLastLetter;
@property (nonatomic, copy) NSString *actionString;

+(TutorialTextBox*)textBoxWithText:(NSString*)t AutoLetterList:(NSArray*)all andFrame:(CGRect)f;
-(id)initWithText:(NSString*)t AutoLetterList:(NSArray*)all andFrame:(CGRect)f;

@end


@interface TutorialAutoLetter : NSObject<NSCoding> {
}

@property(nonatomic,assign) char letter;
@property(nonatomic,assign) int lineIndex;
@property(nonatomic,assign) int autoDblTapLineIndex;

+(TutorialAutoLetter*)autoLetter:(char)l LineIndex:(int)li AutoDblTapLineIndex:(int)atli;
-(id)initLetter:(char)l LineIndex:(int)li AutoDblTapLineIndex:(int)atli;

@end
