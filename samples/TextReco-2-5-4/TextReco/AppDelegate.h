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

#import <UIKit/UIKit.h>
#import "EAGLViewController.h"
#import "QCARControl.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, QCARControlDelegate> {
    EAGLViewController* eaglViewController;
    CGRect boundsEAGLView;
    BOOL qcarCameraIsActive;
}


// --- Properties ---
@property (strong, nonatomic) UIWindow *window;


// --- Public methods ---
// Present a view controller using the root view controller
- (void)rootViewControllerPresentViewController:(UIViewController*)viewController;
- (void)rootViewControllerDismissPresentedViewController;

@end
