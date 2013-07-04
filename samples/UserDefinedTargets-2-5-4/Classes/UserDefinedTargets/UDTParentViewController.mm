/*==============================================================================
 Copyright (c) 2012-2013 QUALCOMM Austria Research Center GmbH.
 All Rights Reserved.
 Qualcomm Confidential and Proprietary
 ==============================================================================*/

#include "RefFreeFrame.h"
#import "UDTParentViewController.h"
#import "ARViewController.h"
#import "UDTOverlayViewController.h"
#import "EAGLView.h"

#import "InstructionsViewController.h"
#import "UDTQCARutils.h"
#import "AboutViewController.h"

#define TOOLBAR_HEIGHT 53
#define TOP_LABEL_HEIGHT 24

@implementation UDTParentViewController

extern RefFreeFrame refFreeFrame;

#pragma mark - Private

-(void) addToolbar
{
    //  Init Toolbar
    CGRect toolbarFrame = CGRectMake(0,
                                     self.view.frame.size.height - TOOLBAR_HEIGHT,
                                     self.view.frame.size.width,
                                     TOOLBAR_HEIGHT);
    
    toolbar = [[CustomToolbar alloc] initWithFrame:toolbarFrame];
    toolbar.delegate = self;
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        
    //  Finally, add toolbar to ViewController's view
    [self.view addSubview:toolbar];
}

-(void) addOverlayView
{
    //  Add brackets
    CGRect overlayFrame = CGRectMake(self.view.frame.origin.x,
                                     self.view.frame.origin.y + TOP_LABEL_HEIGHT,
                                     self.view.frame.size.width,
                                     self.view.frame.size.height - toolbar.frame.size.height - TOP_LABEL_HEIGHT);
    
    overlayView = [[ScannerOverlayView alloc] initWithFrame:overlayFrame];
    overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    overlayView.backgroundColor = [UIColor clearColor];
    overlayView.userInteractionEnabled = NO;
    [self.view addSubview:overlayView];
    
    //  Add top label
    CGRect aLabelRect = CGRectMake(0, 0, self.view.frame.size.width, TOP_LABEL_HEIGHT);
    topLabel = [[UILabel alloc] initWithFrame:aLabelRect];
    topLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    topLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    topLabel.text = @"Hold the device parallel to the target";
    topLabel.textAlignment = UITextAlignmentCenter;
    topLabel.textColor = [UIColor whiteColor];
    [self.view insertSubview:topLabel belowSubview:toolbar];
}

// Although this is a portrait app, we rotate the top label to stay at the top
// of the screen in landscape orientations
- (void)rotateTopLabelWithOrientation:(UIDeviceOrientation)anOrientation
{
    //  Rotate Label
    float rotation = 0;
    CGRect newFrame = CGRectZero;
    BOOL rotate = YES;
    
    switch (anOrientation) {
        case UIDeviceOrientationLandscapeRight:
            rotation = -M_PI_2;
            newFrame = CGRectMake(0,
                                  0,
                                  TOP_LABEL_HEIGHT,
                                  self.view.frame.size.height);
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            rotation = M_PI_2;
            newFrame = CGRectMake(self.view.frame.size.width - TOP_LABEL_HEIGHT,
                                  0,
                                  TOP_LABEL_HEIGHT,
                                  self.view.frame.size.height);
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
        case UIDeviceOrientationPortrait:
            newFrame = CGRectMake(0,
                                  0,
                                  self.view.frame.size.width,
                                  TOP_LABEL_HEIGHT);
            break;
            
        default:
            // Leave the rotation as it is
            rotate = NO;
            break;
    }
    
    if (YES == rotate) {
        CGAffineTransform transform = CGAffineTransformMakeRotation(rotation);
        topLabel.transform = transform;
        topLabel.frame = newFrame;
    }
}

#pragma mark - Notifications
- (void)goodFrameQuality:(NSNotification *)aNotification
{
    NSLog(@"-------------Good Q----------");
    dispatch_async( dispatch_get_main_queue(), ^{
        overlayView.isImageQualityOk = YES;
    });
}

- (void)badFrameQuality:(NSNotification *)aNotification
{
    NSLog(@"-------------Bad Q----------");
    dispatch_async( dispatch_get_main_queue(), ^{
        overlayView.isImageQualityOk = NO;
    });
}

- (void)trackableCreated:(NSNotification *)aNotification
{
    NSLog(@"-------------The trackable created----------");
   // UIImageWriteToSavedPhotosAlbum(refFreeFrame.image,nil,nil,NULL);
    
    dispatch_async( dispatch_get_main_queue(), ^{
        [self setCameraMode:NO];
    });
}

- (void)orientationDidChange:(NSNotification *)aNotification
{
    UIDeviceOrientation anOrientation = [[UIDevice currentDevice] orientation];
    
    [self rotateTopLabelWithOrientation:anOrientation];
}

- (void)instructionsViewControllerDismissed:(NSNotification *)aNotification
{
    dispatch_async( dispatch_get_main_queue(), ^{
        [self setCameraMode:YES];
    });
}

#pragma mark - Public

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    NSLog(@"UDTParentViewController: creating");
    [self createParentViewAndSplashContinuation];
    
    // Add the EAGLView and the overlay view to the window
    arViewController = [[ARViewController alloc] init];
    
    // need to set size here to setup camera image size for AR
    arViewController.arViewSize = arViewRect.size;
    [parentView addSubview:arViewController.view];
    
    // Hide the AR view so the parent view can be seen during start-up (the
    // parent view contains the splash continuation image on iPad and is empty
    // on iPhone and iPod)
    [arViewController.view setHidden:YES];
    
    // Create an auto-rotating overlay view and its view controller (used for
    // displaying UI objects, such as the camera control menu)
    overlayViewController = [[UDTOverlayViewController alloc] init];
    [parentView addSubview: overlayViewController.view];
        
    self.view = parentView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(goodFrameQuality:)
                                                 name:@"kGoodFrameQuality"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(badFrameQuality:)
                                                 name:@"kBadFrameQuality"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(trackableCreated:)
                                                 name:@"kTrackableCreated"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(instructionsViewControllerDismissed:)
                                                 name:@"kInstructionsViewControllerDismissed"
                                               object:nil];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void) dealloc
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [toolbar release];
    [overlayView release];
    [super dealloc];
}

-(void)setCameraMode:(BOOL)isEnabled
{    
    UIImage *imageToDisplay = nil;
    
    if (isEnabled)
    {
        refFreeFrame.startImageTargetBuilder();
        imageToDisplay = [UIImage imageNamed:@"icon_camera.png"];
    }
    else
    {
        refFreeFrame.stopImageTargetBuilder();
        imageToDisplay = [UIImage imageNamed:@"icon_add.png"];
    }
    
    overlayView.hidden = !isEnabled;
    topLabel.hidden = !isEnabled;
    toolbar.isCancelButtonHidden = !isEnabled;
    toolbar.shouldRotateActionButton = isEnabled;
    toolbar.actionImage = imageToDisplay;
    
    isCameraModeEnabled = isEnabled;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // Portrait only
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

// Not using iOS6 specific enums in order to compile on iOS5 and lower versions
-(NSUInteger)supportedInterfaceOrientations
{
    // Portrait only
    return (1 << UIInterfaceOrientationPortrait);
}

#pragma mark - CustomToolbarDelegateProtocol

-(void)actionButtonWasPressed
{
    if (isCameraModeEnabled)
    {
        //  Camera button was pressed
        
        if (refFreeFrame.isImageTargetBuilderRunning() == YES)
        {
            refFreeFrame.startBuild();
        }
        NSLog(@"#DEBUG camera button tapped");
    }
    else
    {
        //  Add button was pressed
        
        //  If the user hasn't seen instructions yet, show them (just once)
        if (![UDTQCARutils getInstance].hasSeenInstructions)
        {
            InstructionsViewController *aViewController = [[[InstructionsViewController alloc] init] autorelease];
            aViewController.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentModalViewController:aViewController animated:YES];
            
            //  The camera mode will be set after the user dismisses the InstructionsView
            //  see "kInstructionsViewControllerDismissed" notification
        }
        else
        {
            [self setCameraMode:YES];
        }
        NSLog(@"#DEBUG add button tapped");
    }
}

-(void)cancelButtonWasPressed
{
    [self setCameraMode:NO];
    NSLog(@"#DEBUG cancel button tapped");    
}

#pragma mark -
#pragma mark Splash screen control
- (void)endSplash:(NSTimer*)theTimer
{
    // Poll to see if the camera video stream has started and if so remove the
    // splash screen
    [super endSplash:theTimer];
    
    if ([QCARutils getInstance].videoStreamStarted == YES)
    {
        dispatch_async( dispatch_get_main_queue(), ^{
            //  Add bottom toolbar
            [self addToolbar];
            [self setCameraMode:NO];
            
            //  Add overlay brackets
            [self addOverlayView];
            overlayView.hidden = YES;
            topLabel.hidden = YES;
        });
        
        AboutViewController *aboutViewController = [[[AboutViewController alloc] init] autorelease];
        aboutViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        
        //  Animates the modal only if it's an iPad
        BOOL shouldAnimateTransition = NO;
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        {
            shouldAnimateTransition = YES;
        }
        
        dispatch_async( dispatch_get_main_queue(), ^{
            [self presentModalViewController:aboutViewController animated:shouldAnimateTransition];
        });
    }
}

- (UIImage *)createUIImage:(const QCAR::Image *)qcarImage

{
    
    int width = qcarImage->getWidth();
    
    int height = qcarImage->getHeight();
    
    int bitsPerComponent = 8;
    
    int bitsPerPixel = QCAR::getBitsPerPixel(QCAR::RGB888);
    
    int bytesPerRow = qcarImage->getBufferWidth() * bitsPerPixel / bitsPerComponent;
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaNone;
    
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, qcarImage->getPixels(), QCAR::getBufferSize(width, height, QCAR::RGB888), NULL);
    
    
    
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    UIImage *image = [[UIImage imageWithCGImage:imageRef] retain];
    
    
    
    CGDataProviderRelease(provider);
    
    CGColorSpaceRelease(colorSpaceRef);
    
    CGImageRelease(imageRef);
    
    
    
    return image;
    
}



@end
