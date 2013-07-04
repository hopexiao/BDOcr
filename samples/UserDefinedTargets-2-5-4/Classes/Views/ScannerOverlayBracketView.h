/*==============================================================================
 Copyright (c) 2012-2013 QUALCOMM Austria Research Center GmbH.
 All Rights Reserved.
 Qualcomm Confidential and Proprietary
 ==============================================================================*/

#import <UIKit/UIKit.h>

typedef enum {
    kScannerOverlayBracketTopLeft = 0,
    kScannerOverlayBracketTopRight,
    kScannerOverlayBracketBottomLeft,
    kScannerOverlayBracketBottomRight,
    kScannerOverlayBracketCount
} ScannerOverlayBracket;

//  This class renders the brackets
@interface ScannerOverlayBracketView : UIView{
    UIColor *fillColor;
}

@property (nonatomic, assign) ScannerOverlayBracket bracket;
@property (retain) UIColor *fillColor;

- (id)initWithBracket:(ScannerOverlayBracket)bracket;

@end
