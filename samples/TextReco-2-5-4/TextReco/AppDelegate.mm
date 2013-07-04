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

#import "AppDelegate.h"
#import "QCARControl.h"
#import "EAGLViewController.h"
#import "SplashViewController.h"
#import "AboutViewController.h"
#import <QCAR/QCAR.h>
#import <QCAR/QCAR_iOS.h>


// Flag to show if the device has a retina display
BOOL displayIsRetina = NO;


@interface AppDelegate (PrivateMethods)

- (void)determineDeviceDisplayType;
- (void)splashTimerFired:(NSTimer*)timer;

@end


@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    
    [super dealloc];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Determine the device display type (is it retina?)
    [self determineDeviceDisplayType];

    // Create the EAGLView with the screen dimensions
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    boundsEAGLView = screenBounds;

    // Create app window
    self.window = [[[UIWindow alloc] initWithFrame:screenBounds] autorelease];
    
    // Create the EAGLViewController (the view controller of the EAGLView, which
    // is used to render the augmented scene)
    eaglViewController = [[EAGLViewController alloc] initWithFrame:boundsEAGLView];
    
    // If this device has a retina display, scale the EAGLView bounds that will
    // be passed to QCAR; this allows it to calculate the size and position of
    // the viewport correctly when rendering the video background
    if (YES == displayIsRetina) {
        boundsEAGLView.size.width *= 2.0;
        boundsEAGLView.size.height *= 2.0;
    }
    
    // Set ourselves as the QCARControl delegate, so it can inform us of
    // significant events, such as the completion of QCAR initialisation, which
    // is performed asynchronously
    [[QCARControl getInstance] setDelegate:self];
    
    // Set the root view controller
    [self.window setRootViewController:eaglViewController];
    
    [self.window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    return YES;
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Initialise QCAR.  As we are QCARControl's delegate, it will call our
    // initQCARComplete method when initialisation has completed
    [[QCARControl getInstance] initQCAR];
    qcarCameraIsActive = NO;
    
    // Present the splash screen
    SplashViewController* splashViewController = [[[SplashViewController alloc] init] autorelease];
    [self rootViewControllerPresentViewController:splashViewController];
    
    // Start a timer to dismiss the splash screen
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(splashTimerFired:) userInfo:nil repeats:NO];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Remove any presented view controller that may be on display
    [self rootViewControllerDismissPresentedViewController];
    
    // Stop the camera
    QCARControl* control = [QCARControl getInstance];
    [control stopCamera];
    qcarCameraIsActive = NO;

    // Stop and deinitialise the tracker
    (void)[control stopTracker:QCAR::Tracker::TEXT_TRACKER];
    [control deinitTracker:QCAR::Tracker::TEXT_TRACKER];
    
    // Pause and deinitialise QCAR
    [control pauseQCAR];
    [control deinitQCAR];
    
    // Be a good OpenGL ES citizen: now that QCAR is paused and the render
    // thread is not executing, inform the root view controller that the
    // EAGLView should finish any OpenGL ES commands
    [eaglViewController finishOpenGLESCommands];
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Be a good OpenGL ES citizen: inform the root view controller that the
    // EAGLView should free any easily recreated OpenGL ES resources
    [eaglViewController freeOpenGLESResources];
}


//------------------------------------------------------------------------------
#pragma mark - Public methods

// Present a view controller using the root view controller (eaglViewController)
- (void)rootViewControllerPresentViewController:(UIViewController*)viewController
{
    // Use UIModalPresentationFullScreen so the presented view controller covers
    // the screen
    [eaglViewController setModalPresentationStyle:UIModalPresentationFullScreen];

    if ([eaglViewController respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        // iOS > 4
        [eaglViewController presentViewController:viewController animated:NO completion:nil];
    }
    else {
        // iOS 4
        [eaglViewController presentModalViewController:viewController animated:NO];
    }
}


// Dismiss a view controller presented by the root view controller
// (eaglViewController)
- (void)rootViewControllerDismissPresentedViewController
{
    // Dismiss the presented view controller (return to the root view
    // controller)
    if ([eaglViewController respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        // iOS > 4
        [eaglViewController dismissViewControllerAnimated:NO completion:nil];
    }
    else {
        // iOS 4
        [eaglViewController dismissModalViewControllerAnimated:NO];
    }
}


//------------------------------------------------------------------------------
#pragma mark - QCARControlDelegate methods

- (void)initQCARComplete:(ErrorReport*)error
{
    // QCARControl is informing us that QCAR initialisation has completed
    
    if (nil != error) {
        [error log];
        [error release];
        return;
    }
    
    // Frames from the camera are always landscape, no matter what the
    // orientation of the device.  Tell QCAR to rotate the video background (and
    // the projection matrix it provides to us for rendering our augmentation)
    // appropriately
    QCAR::setRotation(QCAR::ROTATE_IOS_90);

    // Tell QCAR we've created a drawing surface
    QCAR::onSurfaceCreated();
    
    // Tell QCAR the size of the drawing surface
    QCAR::onSurfaceChanged(boundsEAGLView.size.width, boundsEAGLView.size.height);
    
    // We need n text tracker, which will track our target, so initialise it and
    // load its data now.  As we are QCARControl's delegate, it will call our
    // loadAndActivateTextTrackerDataSetComplete method when tracker
    // initialisation, loading and activation has completed
    [[QCARControl getInstance] loadTextTrackerWordList:@"Vuforia-English-word.vwl"];
}


- (void)loadTextTrackerWordListComplete:(ErrorReport *)error
{
    // QCARControl is informing us that text tracker data loading has completed
    
    if (nil != error) {
        [error log];
        [error release];
        return;
    }
    
    // Resume QCAR
    [[QCARControl getInstance] resumeQCAR];
    
    // Start the camera.  This causes QCAR to locate our EAGLView in the view
    // hierarchy, start a render thread, and then call renderFrameQCAR on the
    // view periodically
    [[QCARControl getInstance] startCameraForViewWidth:boundsEAGLView.size.width andHeight:boundsEAGLView.size.height];
    qcarCameraIsActive = YES;
}


//------------------------------------------------------------------------------
#pragma mark - Private methods

// Determine whether the device has a retina display
- (void)determineDeviceDisplayType
{
    // If UIScreen mainScreen responds to selector
    // displayLinkWithTarget:selector: and the scale property is 2.0, then this
    // is a retina display
    displayIsRetina = ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && 2.0 == [UIScreen mainScreen].scale);
}


- (void)splashTimerFired:(NSTimer*)timer
{
    // If the QCAR camera is active
    if (YES == qcarCameraIsActive) {
        // Dismiss the splash screen, which is the view controller currently
        // presented by the root view controller
        [self rootViewControllerDismissPresentedViewController];
        
        // Now display the About screen
        AboutViewController* aboutViewController = [[[AboutViewController alloc] init] autorelease];
        [aboutViewController setModalPresentationStyle:UIModalPresentationFormSheet];
        [self rootViewControllerPresentViewController:aboutViewController];
    }
    else {
        // QCAR camera is not yet active, schedule another timer
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(splashTimerFired:) userInfo:nil repeats:NO];
    }
}

@end
