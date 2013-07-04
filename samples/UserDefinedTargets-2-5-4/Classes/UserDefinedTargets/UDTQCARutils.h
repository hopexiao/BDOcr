/*==============================================================================
 Copyright (c) 2012-2013 QUALCOMM Austria Research Center GmbH.
 All Rights Reserved.
 Qualcomm Confidential and Proprietary
 ==============================================================================*/

#import <Foundation/Foundation.h>
#import "QCARutils.h"


#pragma mark --- Class interface ---

@interface UDTQCARutils : QCARutils
{
    BOOL hasSeenInstructions;
}

@property (assign) BOOL hasSeenInstructions;

#pragma mark --- Class Methods ---

+ (UDTQCARutils *) getInstance;

@end
