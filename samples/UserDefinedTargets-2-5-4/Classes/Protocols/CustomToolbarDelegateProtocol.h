/*==============================================================================
 Copyright (c) 2012-2013 QUALCOMM Austria Research Center GmbH.
 All Rights Reserved.
 Qualcomm Confidential and Proprietary
 ==============================================================================*/

#import <Foundation/Foundation.h>

@protocol CustomToolbarDelegateProtocol <NSObject>

-(void)cancelButtonWasPressed;
-(void)actionButtonWasPressed;

@end
