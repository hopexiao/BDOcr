/*==============================================================================
 Copyright (c) 2012-2013 QUALCOMM Austria Research Center GmbH.
 All Rights Reserved.
 Qualcomm Confidential and Proprietary
 ==============================================================================*/

#import "ScannerOverlayView.h"

@implementation ScannerOverlayView

#pragma mark - Private

- (void)setup{
    for (ScannerOverlayBracket i = 0; i < kScannerOverlayBracketCount; i++) {
        brackets[i] = [[ScannerOverlayBracketView alloc] initWithBracket:i];
        [self addSubview:brackets[i]];
    }
    
    bracketInsets = UIEdgeInsetsMake(25, 25, 25, 25);
}

#pragma mark - Properties

-(void)setIsImageQualityOk:(BOOL)newValue
{
    if (isImageQualityOk != newValue)
    {
        isImageQualityOk = newValue;
        
        UIColor *aColor = nil;
        
        if (isImageQualityOk)
        {
            aColor = [UIColor greenColor];
            NSLog(@"#DEBUG goodFrameQuality");            
        }
        else
        {
            aColor = [UIColor whiteColor];
            NSLog(@"#DEBUG badFrameQuality");            
        }
        
        for (NSInteger i=0; i<kScannerOverlayBracketCount; i++)
        {
            ScannerOverlayBracketView *aBracket = brackets[i];
            aBracket.fillColor = aColor;
            [aBracket setNeedsDisplay];
        }
    }
}

-(BOOL)isImageQualityOk
{
    return isImageQualityOk;
}

#pragma mark - Public

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self setup];
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect bracketFrame = brackets[0].frame;
    CGRect viewRect = UIEdgeInsetsInsetRect(self.bounds, bracketInsets);
    
    bracketFrame.origin = viewRect.origin;
    brackets[kScannerOverlayBracketTopLeft].frame = bracketFrame;
    
    bracketFrame.origin.x = CGRectGetMaxX(viewRect) - CGRectGetWidth(bracketFrame);
    brackets[kScannerOverlayBracketTopRight].frame = bracketFrame;
    
    bracketFrame.origin.y = CGRectGetHeight(viewRect);
    brackets[kScannerOverlayBracketBottomRight].frame = bracketFrame;
    
    bracketFrame.origin.x = CGRectGetMinX(viewRect);
    brackets[kScannerOverlayBracketBottomLeft].frame = bracketFrame;
}

@end
