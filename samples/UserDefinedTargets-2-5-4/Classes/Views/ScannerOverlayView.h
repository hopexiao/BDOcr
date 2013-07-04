/*==============================================================================
 Copyright (c) 2012-2013 QUALCOMM Austria Research Center GmbH.
 All Rights Reserved.
 Qualcomm Confidential and Proprietary
 ==============================================================================*/

#import <UIKit/UIKit.h>
#import "ScannerOverlayBracketView.h"

//  This view contains the 4 brackets that are rendered on the camera mode
@interface ScannerOverlayView : UIView{
    ScannerOverlayBracketView *brackets[kScannerOverlayBracketCount];
    UIEdgeInsets bracketInsets;
    BOOL isImageQualityOk;
}

@property (assign) BOOL isImageQualityOk;

@end
