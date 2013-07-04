/*==============================================================================
 Copyright (c) 2012-2013 QUALCOMM Austria Research Center GmbH.
 All Rights Reserved.
 Qualcomm Confidential and Proprietary
 ==============================================================================*/

#import "InstructionsViewController.h"
#import "UDTQCARutils.h"

@implementation InstructionsViewController

#pragma mark - Private

- (void)layoutStepViewsForOrientation:(UIInterfaceOrientation)orientation{
    CGRect viewRect = self.view.bounds;
    viewRect.origin.y += navBar.frame.size.height;
    viewRect.size.height -= navBar.frame.size.height;
    CGFloat offset_horizontal = 0.0, offset_vertical = 0.0;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        viewRect = CGRectInset(viewRect, 60, 40);
    } else {
        viewRect = CGRectInset(viewRect, 20, 20);
    }
    
    offset_vertical = roundf(viewRect.size.height / 3);
    viewRect.size.height = offset_vertical;
    
    firstView.frame = viewRect;
    viewRect.origin.y += offset_vertical;
    viewRect.origin.x += offset_horizontal;
    
    secondView.frame = viewRect;
    viewRect.origin.y += offset_vertical;
    viewRect.origin.x += offset_horizontal;
    
    thirdView.frame = viewRect;
}

#pragma mark - Public

- (void)viewDidLoad{
    [super viewDidLoad];
    
    //  Set up all 3 steps
    firstView.thumbnail.image = [UIImage imageNamed:@"instruction_icons_01.png"];
    firstView.titleLabel.text = @"1.";
    firstView.detailLabel.text = @"Hold the device parallel to the target";
    
    secondView.thumbnail.image = [UIImage imageNamed:@"instruction_icons_02.png"];
    secondView.titleLabel.text = @"2.";
    secondView.detailLabel.text = @"Fill the viewfinder with the target";
    
    thirdView.thumbnail.image = [UIImage imageNamed:@"instruction_icons_03_portrait.png"];
    thirdView.titleLabel.text = @"3.";
    thirdView.detailLabel.text = @"Take Picture";
}

- (void)viewDidUnload{
    [firstView release];
    firstView = nil;
    [secondView release];
    secondView = nil;
    [thirdView release];
    thirdView = nil;
    [navBar release];
    navBar = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self layoutStepViewsForOrientation:self.interfaceOrientation];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)dealloc {
    [firstView release];
    [secondView release];
    [thirdView release];
    [navBar release];
    [super dealloc];
}

- (IBAction)doneButtonTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kInstructionsViewControllerDismissed" object:nil];

    [UDTQCARutils getInstance].hasSeenInstructions = YES;
}

- (IBAction)cancelButtonTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
@end
