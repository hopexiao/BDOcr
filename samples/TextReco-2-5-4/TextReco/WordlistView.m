/*==============================================================================
            Copyright (c) 2013 QUALCOMM Austria Research Center GmbH.
            All Rights Reserved.
            Qualcomm Confidential and Proprietary
 
This Vuforia(TM) sample application in source code form ("Sample Code") for the
Vuforia Software Development Kit and/or Vuforia Extension for Unity
(collectively, the "Vuforia SDK") may in all cases only be used in conjunction
with use of the Vuforia SDK, and is subject in all respects to all of the terms
and conditions of the Vuforia SDK License Agreement, which may be found at
https://developer.vuforia.com/legal/license.
 
By retaining or using the Sample Code in any manner, you confirm your agreement
to all the terms and conditions of the Vuforia SDK License Agreement.  If you do
not agree to all the terms and conditions of the Vuforia SDK License Agreement,
then you may not retain or use any of the Sample Code in any manner.
==============================================================================*/


#import "WordlistView.h"


@implementation DisplayWords

- (id)init
{
    self = [super init];
    
    if (nil != self) {
        words = [[NSMutableString alloc] init];
        
    }
    
    return self;
}


- (void)dealloc
{
    [words release];
    
    [super dealloc];
}

@end


@implementation WordlistView

//------------------------------------------------------------------------------
#pragma mark - Lifecycle

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (nil != self) {
        BOOL isIPad = UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM();
        
        // ----- View -----
       
        // Do not respond to user interaction
        [self setUserInteractionEnabled:NO];

        // View is not opaque
        [self setOpaque:NO];

        CGFloat screenHeight = frame.size.height;
        CGFloat screenWidth = frame.size.width;

        CGRect r;
        r.origin.x = 0.0f;
        r.origin.y = 0.0f;
        r.size.width = screenWidth;
        r.size.height  = screenHeight;

        [self setFrame:r];
        
        // width of margin is:
		// 5% of the width of the screen for a phone
		// 20% of the width of the screen for a tablet
        marginWidth = isIPad ? (screenWidth * 20) / 100 : (screenWidth * 5) / 100;
        
		// loupe height is:
		// 16% of the screen height for a phone
		// 10% of the screen height for a tablet
        loupeHeight = isIPad ? (screenHeight * 10) / 100 : (screenHeight * 16) / 100;
        
        // loupe width takes the width of the screen minus 2 margins
        loupeWidth = screenWidth - (2 * marginWidth);
        
        nonSearchableAreaHeight = screenHeight - (loupeHeight + marginWidth);

        // ----- Text view (subview) -----
        r.origin.x = marginWidth;
        r.origin.y = loupeHeight + marginWidth + ((nonSearchableAreaHeight * 7.5) / 100);
        r.size.width = screenWidth - (2 * marginWidth);
        r.size.height = (nonSearchableAreaHeight * 85) / 100;
        
        textView = [[UITextView alloc]initWithFrame:r];
        [textView setTextAlignment:NSTextAlignmentCenter];
        [textView setBackgroundColor:[UIColor clearColor]];
        [textView setTextColor:[UIColor whiteColor]];

        [self addSubview:textView];
        
        // Font size limits
        if (YES == isIPad) {
            minFontSize = 20;
            maxFontSize = 32;
        }
        else {
            minFontSize = 10;
            maxFontSize = 32;
        }
        
        
    }
    
    return self;
}


- (void)dealloc
{
    [textView release];

    [super dealloc];
}


//------------------------------------------------------------------------------
#pragma mark - Public methods

- (void)setWordsToDisplay:(DisplayWords*)displayWords
{
    if (self.parser==nil) {
        self.parser = [[WDParseOperation alloc]init];
    }
    [self.parser parse:displayWords->words from:@"en" to:@"cn"];
    NSMutableString * result = [[[_parser.jsonObjects valueForKey:@"trans_result"] objectAtIndex:0] valueForKey:@"dst"];
    NSLog(@"%@",result);
  //  self.translateResult.text = result;
    
    displayWords->words = result;

    // Update the UITextView on the main thread
    [self performSelectorOnMainThread:@selector(setText:) withObject:displayWords waitUntilDone:NO];
}


//------------------------------------------------------------------------------
#pragma mark - Private methods

- (void)setText:(DisplayWords*)displayWords
{
    
    
    
    textView.text = displayWords->words;
    static NSUInteger previousCount = 0;
    
    if (0 < displayWords->count && displayWords->count != previousCount) {
        // If the number of words has changed, update the font size
        int requiredLineHeight = [textView bounds].size.height / displayWords->count;
        CGFloat fontSize = (CGFloat)requiredLineHeight;

        // Create the font to use when drawing the text
        UIFont* font = [UIFont fontWithName:@"Arial" size:fontSize];

        // Reduce the font size until the line height is suitable
      
        while ((fontSize > minFontSize) && ([font lineHeight] > requiredLineHeight)) {
            --fontSize;

            if ((maxFontSize < fontSize))
                fontSize = maxFontSize;
            else if (minFontSize > fontSize)
                fontSize = minFontSize;

            font = [UIFont fontWithName:@"Arial" size:fontSize];
        }
        font = [UIFont fontWithName:@"Arial" size:fontSize];
        [textView setFont:font];
        previousCount = displayWords->count;
    }
}


// Overridden so we can draw the view's background
- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    UIColor* colorBackground = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75];
    CGContextSetFillColorWithColor(c, colorBackground.CGColor);
    
    // Draw top rectangle above ROI
    CGRect r;
    r.origin.x = 0.0;
    r.origin.y = 0.0;
    r.size.width = rect.size.width;
    r.size.height = marginWidth;
    CGContextFillRect(c, r);
    
    // Draw left side rectangle
    r.origin.y = marginWidth;
    r.size.width = marginWidth;
    r.size.height = loupeHeight;
    CGContextFillRect(c, r);
    
    // Draw right side rectangle
    r.origin.x = loupeWidth + marginWidth;
    CGContextFillRect(c, r);
    
    // Draw lower rectangle
    r.origin.x = 0.0;
    r.origin.y = loupeHeight + marginWidth;
    r.size.width = rect.size.width;
    r.size.height = nonSearchableAreaHeight;
    CGContextFillRect(c, r);
}

@end
