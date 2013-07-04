/*==============================================================================
 Copyright (c) 2012-2013 QUALCOMM Austria Research Center GmbH.
 All Rights Reserved.
 Qualcomm Confidential and Proprietary
 ==============================================================================*/


#import <UIKit/UIKit.h>
@class ARParentViewController;


@interface UserDefinedTargetsAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow* window;
    ARParentViewController* arParentViewController;
    UIImageView *splashV;
    
    // The views to handle restarting the image target builder:
    UIImageView *mNewView;
    
    
    // The views to handle starting/stopping the image target builder:
    UIImageView *mStopView;
  
    
    // The view to handle camera focus for the image target builder:
    UIImageView *mFocusView;
    
    UIButton *stopimageButton;
    
    UIButton *newimageButton;

}

@end
