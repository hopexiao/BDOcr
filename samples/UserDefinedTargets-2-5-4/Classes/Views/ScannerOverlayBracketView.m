/*==============================================================================
 Copyright (c) 2012-2013 QUALCOMM Austria Research Center GmbH.
 All Rights Reserved.
 Qualcomm Confidential and Proprietary
 ==============================================================================*/

#import "ScannerOverlayBracketView.h"

@implementation ScannerOverlayBracketView
@synthesize bracket, fillColor;

#pragma mark - Public

- (id)initWithBracket:(ScannerOverlayBracket)aBracket{
    CGRect frame = CGRectMake(0, 0, 20, 20);
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        frame = CGRectMake(0, 0, 32, 32);
    }
    
    self = [self initWithFrame:frame];
    if (self){
        self.backgroundColor = [UIColor clearColor];
        bracket = aBracket;        
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    
    CGFloat offset_horizontal = 6.0, offset_vertical = 6.0;
    switch (bracket) {
        case kScannerOverlayBracketTopLeft:
            break;
        case kScannerOverlayBracketBottomRight:
            offset_horizontal = -offset_horizontal;
            // Fall through to offset vertical
        case kScannerOverlayBracketBottomLeft:
            offset_vertical = -offset_vertical;
            break;
        case kScannerOverlayBracketTopRight:
            offset_horizontal = -offset_horizontal;
            break;
        default:
            break;
    }
    
    UIBezierPath *innerPath = [UIBezierPath bezierPathWithRect:CGRectOffset(self.bounds,
                                                                            offset_horizontal,
                                                                            offset_vertical)];
    
    [path appendPath:innerPath];
    path.usesEvenOddFillRule = YES;

    //  Render the brackets on white if there isn't any color set
    if (!self.fillColor)
    {
        self.fillColor = [UIColor whiteColor];
    }
    
    [self.fillColor setFill];
    [path fill];
}

-(void)dealloc
{
    [fillColor release];
    [super dealloc];
}

@end
