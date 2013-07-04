/*==============================================================================
 Copyright (c) 2012-2013 QUALCOMM Austria Research Center GmbH.
 All Rights Reserved.
 Qualcomm Confidential and Proprietary
 ==============================================================================*/

#import <UIKit/UIKit.h>

//  This view represents each Instruction Step in InstructionsViewController
@interface InstructionStepView : UIView{
    UIImageView *thumbnail;
    UILabel *titleLabel;
    UILabel *detailLabel;
}

@property (readonly) UIImageView *thumbnail;
@property (readonly) UILabel *titleLabel;
@property (readonly) UILabel *detailLabel;

@end
