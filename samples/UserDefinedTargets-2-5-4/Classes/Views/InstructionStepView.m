/*==============================================================================
 Copyright (c) 2012-2013 QUALCOMM Austria Research Center GmbH.
 All Rights Reserved.
 Qualcomm Confidential and Proprietary
 ==============================================================================*/

#import "InstructionStepView.h"

@implementation InstructionStepView
@synthesize thumbnail, titleLabel, detailLabel;

#pragma mark - Private

- (void) setup{
    titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = UITextAlignmentRight;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        titleLabel.font = [UIFont boldSystemFontOfSize:40];
    } else {
        titleLabel.font = [UIFont boldSystemFontOfSize:26];
    }
    [self addSubview:titleLabel];
    
    detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    detailLabel.backgroundColor = [UIColor clearColor];
    detailLabel.textColor = [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:1.0];
    detailLabel.numberOfLines = 0;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        detailLabel.font = [UIFont systemFontOfSize:24];
    } else {
        detailLabel.font = [UIFont systemFontOfSize:12];
    }
    [self addSubview:detailLabel];
    
    thumbnail = [[UIImageView alloc] initWithFrame:CGRectZero];
    thumbnail.contentMode = UIViewContentModeCenter;
    [self addSubview:thumbnail];
}

#pragma mark - Public

- (id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setup];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self setup];
    }
    return self;
}

- (void) awakeFromNib{
    
}

- (void) layoutSubviews{
    [super layoutSubviews];
    
    CGRect imageRect = CGRectMake(0, 0,
                                  thumbnail.image.size.width,
                                  thumbnail.image.size.height);
    thumbnail.frame = imageRect;
    
    CGRect stepRect;
    CGRect instructionRect;
    
    if (CGRectGetHeight(self.bounds) > CGRectGetWidth(self.bounds)) {
        // landscape layout
        stepRect = CGRectMake(0, CGRectGetMaxY(imageRect) + 5,
                              titleLabel.font.pointSize, titleLabel.font.pointSize);
        
        instructionRect = CGRectMake(CGRectGetMaxX(stepRect), CGRectGetMinY(stepRect),
                                     CGRectGetWidth(imageRect) - CGRectGetMaxX(stepRect),
                                     CGFLOAT_MAX);
        instructionRect = UIEdgeInsetsInsetRect(instructionRect, UIEdgeInsetsMake(0, 2, 0, 5));
        instructionRect.size = [detailLabel.text sizeWithFont:detailLabel.font
                                                       constrainedToSize:instructionRect.size];
    } else {
        // portrait
        stepRect = CGRectMake(CGRectGetMaxX(imageRect), 0,
                              titleLabel.font.pointSize, CGRectGetHeight(imageRect));
        
        instructionRect = CGRectMake(CGRectGetMaxX(stepRect), 0,
                                     CGRectGetWidth(self.bounds) - CGRectGetMaxX(stepRect),
                                     CGRectGetHeight(stepRect));
        instructionRect = UIEdgeInsetsInsetRect(instructionRect, UIEdgeInsetsMake(4, 5, 0, 0));
    }
    
    titleLabel.frame = stepRect;
    detailLabel.frame = instructionRect;
}

- (void)dealloc {
    [thumbnail release];
    [titleLabel release];
    [detailLabel release];
    [super dealloc];
}
@end
