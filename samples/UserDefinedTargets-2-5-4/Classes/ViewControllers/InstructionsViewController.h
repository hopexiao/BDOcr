/*==============================================================================
 Copyright (c) 2012-2013 QUALCOMM Austria Research Center GmbH.
 All Rights Reserved.
 Qualcomm Confidential and Proprietary
 ==============================================================================*/

#import <UIKit/UIKit.h>
#import "InstructionStepView.h"

@interface InstructionsViewController : UIViewController
{
    IBOutlet InstructionStepView *firstView;
    IBOutlet InstructionStepView *secondView;
    IBOutlet InstructionStepView *thirdView;
    IBOutlet UINavigationBar *navBar;
}

- (IBAction)doneButtonTapped:(id)sender;
- (IBAction)cancelButtonTapped:(id)sender;

@end
