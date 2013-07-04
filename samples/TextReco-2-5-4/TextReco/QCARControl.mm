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


#import <QCAR/QCAR.h>
#import <QCAR/QCAR_iOS.h>
#import <QCAR/CameraDevice.h>
#import <QCAR/VideoBackgroundConfig.h>
#import <QCAR/Renderer.h>
#import <QCAR/TrackerManager.h>
#import <QCAR/TextTracker.h>
#import <QCAR/WordList.h>

#import "QCARControl.h"
#import "ShaderUtils.h"


namespace {
    // --- Data private to this unit ---

    // The one and only instance of QCARControl
    QCARControl* qcarControl = nil;
}


@interface QCARControl (PrivateMethods)

- (void)initQCARInBackground;
- (void)configureVideoBackgroundWithViewWidth:(float)viewWidth andHeight:(float)viewHeight;
- (void)initTracker:(QCAR::Tracker::TYPE)trackerType;
- (void)loadWordListInBackground:(id)obj;

@end


@implementation QCARControl

@synthesize viewport;
@synthesize ROICenterX,ROICenterY,ROIHeight,ROIWidth;


//------------------------------------------------------------------------------
#pragma mark - Lifecycle

// Return the one and only instance of QCARControl
+ (QCARControl*)getInstance
{
    if (nil == qcarControl) {
        qcarControl = [[QCARControl alloc] init];
    }

    return qcarControl;
}


- (void)dealloc
{
    [self setDelegate:nil];

    [super dealloc];
}


//------------------------------------------------------------------------------
#pragma mark - QCAR control

// Initialise QCAR
- (void)initQCAR
{
    NSLog(@"QCARControl initQCAR");

    // Initialising QCAR is a potentially lengthy operation, so perform it on a
    // background thread
    [self performSelectorInBackground:@selector(initQCARInBackground) withObject:nil];
}


// Deinitialise QCAR
- (void)deinitQCAR
{
    NSLog(@"QCARControl deinitQCAR");
    QCAR::deinit();
}


// Resume QCAR
- (void)resumeQCAR
{
    NSLog(@"QCARControl resumeQCAR");
    QCAR::onResume();
}


// Pause QCAR
- (void)pauseQCAR
{
    NSLog(@"QCARControl pauseQCAR");
    QCAR::onPause();
}


// Load the text tracker word list
- (BOOL)loadTextTrackerWordList:(NSString*)wordListFile
{
    NSLog(@"QCARControl loadAndActivateTextTrackerWordList");

    // Initialise the text tracker
    [self initTracker:QCAR::Tracker::TEXT_TRACKER];

    // Loading tracker data is a potentially lengthy operation, so perform it on
    // a background thread
    [self performSelectorInBackground:@selector(loadWordListInBackground:) withObject:wordListFile];

    return YES;
}


// Start QCAR camera with the specified view size
- (void)startCameraForViewWidth:(float)viewWidth andHeight:(float)viewHeight
{
    NSLog(@"QCARControl startCameraForViewWidth:andHeight:");

    if (QCAR::CameraDevice::getInstance().init(QCAR::CameraDevice::CAMERA_BACK)) {
        if (QCAR::CameraDevice::getInstance().start()) {
            NSLog(@"QCARControl camera started");

            // Configure QCAR video background
            [self configureVideoBackgroundWithViewWidth:viewWidth andHeight:viewHeight];

            // Cache the projection matrix
            const QCAR::CameraCalibration& cameraCalibration = QCAR::CameraDevice::getInstance().getCameraCalibration();
            _projectionMatrix = QCAR::Tool::getProjectionGL(cameraCalibration, 2.0f, 2500.0f);
        }
    }
}


// Stop QCAR camera
- (void)stopCamera
{
    NSLog(@"QCARControl stopCamera");

    // Stop and deinit the camera
    QCAR::CameraDevice::getInstance().stop();
    QCAR::CameraDevice::getInstance().deinit();
}


// Deinitialise the tracker
- (void)deinitTracker:(QCAR::Tracker::TYPE)trackerType
{
    NSLog(@"QCARControl deinitTracker type %d", trackerType);
    
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    trackerManager.deinitTracker(trackerType);
}


// Start the tracker
- (BOOL)startTracker:(QCAR::Tracker::TYPE)trackerType
{
    NSLog(@"QCARControl startTracker type %d", trackerType);

    // Start the tracker
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::Tracker* tracker = trackerManager.getTracker(trackerType);
    BOOL ret = NO;

    if (NULL != tracker) {
        if (true == tracker->start()) {
            NSLog(@"INFO: successfully started tracker");
            ret = YES;
        }
        else {
            NSLog(@"ERROR: failed to start tracker");
        }
    }
    else {
        NSLog(@"ERROR: failed to get the TextTracker from the tracker manager");
    }

    return ret;
}


// Stop the tracker
- (BOOL)stopTracker:(QCAR::Tracker::TYPE)trackerType
{
    NSLog(@"QCARControl stopTracker type %d", trackerType);

    // Stop the tracker
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::Tracker* tracker = trackerManager.getTracker(trackerType);
    BOOL ret = NO;

    if (NULL != tracker) {
        tracker->stop();
        NSLog(@"INFO: successfully stopped tracker");
        ret = YES;
    }
    else {
        NSLog(@"ERROR: failed to get the tracker from the tracker manager");
    }

    return ret;
}


// Set QCAR hint
- (void)setHint:(unsigned int)hint toValue:(int)value
{
    (void)QCAR::setHint(hint, value);
}


// Focus the camera
- (BOOL)cameraTriggerAutoFocus
{
    // Trigger an auto-focus to happen now, then switch back to continuous
    // auto-focus mode.  This allows the user to trigger an auto-focus if the
    // continuous mode fails to focus when required
    BOOL ret = NO;

    if (true == QCAR::CameraDevice::getInstance().setFocusMode(QCAR::CameraDevice::FOCUS_MODE_TRIGGERAUTO)) {
        ret = true == QCAR::CameraDevice::getInstance().setFocusMode(QCAR::CameraDevice::FOCUS_MODE_CONTINUOUSAUTO) ? YES : NO;
    }

    return ret;
}


//------------------------------------------------------------------------------
#pragma mark - Private methods

// Initialise QCAR
// *** Performed on a background thread ***
- (void)initQCARInBackground
{
    // Background thread must have its own autorelease pool
    @autoreleasepool {
        QCAR::setInitParameters(self.QCARInitFlags);

        // QCAR::init() will return positive numbers up to 100 as it progresses
        // towards success.  Negative numbers indicate error conditions
        NSInteger initSuccess = 0;
        do {
            initSuccess = QCAR::init();
        } while (0 <= initSuccess && 100 > initSuccess);

        ErrorReport* error = nil;

        if (100 == initSuccess) {
            NSLog(@"INFO: successfully initialised QCAR");
        }
        else {
            // Failed to initialise QCAR
            error = [[ErrorReport alloc] initWithMessage:"ERROR: failed to initialise QCAR"];
        }

        // Inform the delegate that QCAR initialisation has completed (on the
        // main thread)
        [self.delegate performSelectorOnMainThread:@selector(initQCARComplete:) withObject:error waitUntilDone:NO];
    }
}


// Configure QCAR with the video background size
- (void)configureVideoBackgroundWithViewWidth:(float)viewWidth andHeight:(float)viewHeight
{
    NSLog(@"Configuring video background (%fw x %fh)", viewWidth, viewHeight);

    // Get the default video mode
    QCAR::CameraDevice& cameraDevice = QCAR::CameraDevice::getInstance();
    QCAR::VideoMode videoMode = cameraDevice.getVideoMode(QCAR::CameraDevice::MODE_DEFAULT);

    // Configure the video background
    QCAR::VideoBackgroundConfig config;
    config.mEnabled = true;
    config.mSynchronous = true;
    config.mPosition.data[0] = 0.0f;
    config.mPosition.data[1] = 0.0f;

    // Determine the orientation of the view.  Note, this simple test assumes
    // that a view is portrait if its height is greater than its width.  This is
    // not always true: it is perfectly reasonable for a view with portrait
    // orientation to be wider than it is high.  The test is suitable for the
    // dimensions used in this sample
    if (viewWidth < viewHeight) {
        // --- View is portrait ---

        // Compare aspect ratios of video and screen.  If they are different we
        // use the full screen size while maintaining the video's aspect ratio,
        // which naturally entails some cropping of the video
        float aspectRatioVideo = (float)videoMode.mWidth / (float)videoMode.mHeight;
        float aspectRatioView = viewHeight / viewWidth;

        if (aspectRatioVideo < aspectRatioView) {
            // Video (when rotated) is wider than the view: crop left and right
            // (top and bottom of video)

            // --============--
            // - =          = _
            // - =          = _
            // - =          = _
            // - =          = _
            // - =          = _
            // - =          = _
            // - =          = _
            // - =          = _
            // --============--

            config.mSize.data[0] = (int)videoMode.mHeight * (viewHeight / (float)videoMode.mWidth);
            config.mSize.data[1] = (int)viewHeight;
        }
        else {
            // Video (when rotated) is narrower than the view: crop top and
            // bottom (left and right of video).  Also used when aspect ratios
            // match (no cropping)

            // ------------
            // -          -
            // -          -
            // ============
            // =          =
            // =          =
            // =          =
            // =          =
            // =          =
            // =          =
            // =          =
            // =          =
            // ============
            // -          -
            // -          -
            // ------------

            config.mSize.data[0] = (int)viewWidth;
            config.mSize.data[1] = (int)videoMode.mWidth * (viewWidth / (float)videoMode.mHeight);
        }
    }
    else {
        // --- View is landscape ---

        // Compare aspect ratios of video and screen.  If they are different we
        // use the full screen size while maintaining the video's aspect ratio,
        // which naturally entails some cropping of the video
        float aspectRatioVideo = (float)videoMode.mWidth / (float)videoMode.mHeight;
        float aspectRatioView = viewWidth / viewHeight;

        if (aspectRatioVideo < aspectRatioView) {
            // Video is taller than the view: crop top and bottom

            // --------------------
            // ====================
            // =                  =
            // =                  =
            // =                  =
            // =                  =
            // ====================
            // --------------------

            config.mSize.data[0] = (int)viewWidth;
            config.mSize.data[1] = (int)videoMode.mHeight * (viewWidth / (float)videoMode.mWidth);
        }
        else {
            // Video is wider than the view: crop left and right.  Also used
            // when aspect ratios match (no cropping)

            // ---====================---
            // -  =                  =  -
            // -  =                  =  -
            // -  =                  =  -
            // -  =                  =  -
            // ---====================---

            config.mSize.data[0] = (int)videoMode.mWidth * (viewHeight / (float)videoMode.mHeight);
            config.mSize.data[1] = (int)viewHeight;
        }
    }

    // Text tracking region of interest
    int width = (int)viewWidth;
    int height = (int)viewHeight;

    QCAR::Vec2I loupeCenter(0, 0);
    QCAR::Vec2I loupeSize(0, 0);

    bool isIPad = NO;

    if (UIUserInterfaceIdiomPad == [[UIDevice currentDevice] userInterfaceIdiom]) {
        isIPad = YES;
    }

    // width of margin is:
    // 5% of the width of the screen for a phone
    // 20% of the width of the screen for a tablet
    int marginWidth = isIPad ? (width * 20) / 100 : (width * 5) / 100;

    // loupe height is:
    // 16% of the screen height for a phone
    // 10% of the screen height for a tablet
    int loupeHeight = isIPad ? (height * 10) / 100 : (height * 16) / 100;

    // lopue width takes the width of the screen minus 2 margins
    int loupeWidth = width - (2 * marginWidth);

    // Region of interest geometry
    ROICenterX = width / 2;
    ROICenterY = marginWidth + (loupeHeight / 2);
    ROIWidth = loupeWidth;
    ROIHeight = loupeHeight;

    // conversion to camera coordinates
    ShaderUtils::screenCoordToCameraCoord(ROICenterX, ROICenterY, ROIWidth, ROIHeight,
                                          (int)viewWidth, (int)viewHeight, videoMode.mWidth, videoMode.mHeight,
                                          &loupeCenter.data[0], &loupeCenter.data[1], &loupeSize.data[0], &loupeSize.data[1]);

    NSLog(@"@>@ ROI center              = [%d, %d], S = [%d, %d]", ROICenterX, ROICenterY, ROIWidth, ROIHeight);
    NSLog(@"@>@ Setting loupe to center = [%d, %d], S = [%d, %d]", loupeCenter.data[0], loupeCenter.data[1], loupeSize.data[0], loupeSize.data[1]);

    QCAR::TextTracker* textTracker = (QCAR::TextTracker*)QCAR::TrackerManager::getInstance().getTracker(QCAR::Tracker::TEXT_TRACKER);

    if (textTracker != 0)
    {
        QCAR::RectangleInt roi(loupeCenter.data[0] - loupeSize.data[0] / 2, loupeCenter.data[1] - loupeSize.data[1] / 2, loupeCenter.data[0] + loupeSize.data[0] / 2, loupeCenter.data[1] + loupeSize.data[1] / 2);
        textTracker->setRegionOfInterest(roi, roi, QCAR::TextTracker::REGIONOFINTEREST_UP_IS_9_HRS);
    }

    NSLog(@"Configure Video Background: Video (%d, %d), Screen (%f, %f), mSize (%d, %d)", videoMode.mWidth, videoMode.mHeight, viewWidth, viewHeight, config.mSize.data[0], config.mSize.data[1]);

    // Calculate the viewport for the app to use when rendering
    viewport.posX = ((width - config.mSize.data[0]) / 2) + config.mPosition.data[0];
    viewport.posY = (((int)(height - config.mSize.data[1])) / (int) 2) + config.mPosition.data[1];
    viewport.sizeX = config.mSize.data[0];
    viewport.sizeY = config.mSize.data[1];
    NSLog(@"Configure Video Background: Viewport x %d, y %d, width %d, height %d", viewport.posX, viewport.posY, viewport.sizeX, viewport.sizeY);

    // Set the config
    QCAR::Renderer::getInstance().setVideoBackgroundConfig(config);
}


// Initialise the tracker
- (void)initTracker:(QCAR::Tracker::TYPE)trackerType
{
    NSLog(@"QCARControl initTracker type %d", trackerType);

    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::Tracker* tracker = trackerManager.initTracker(trackerType);

    if (NULL == tracker) {
        NSLog(@"INFO: failed to initialise the tracker (it may have been initialised already)");
    }
    else {
        NSLog(@"INFO: successfully initialised the tracker");
    }
}


// Load text tracker word list
// *** Performed on a background thread ***
- (void)loadWordListInBackground:(id)obj
{
    // Background thread must have its own autorelease pool
    @autoreleasepool {
        ErrorReport* error = nil;

        // Load the data set
        NSString* wordListFile = obj;

        // Get the QCAR tracker manager text tracker
        QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
        QCAR::TextTracker* textTracker = static_cast<QCAR::TextTracker*>(trackerManager.getTracker(QCAR::Tracker::TEXT_TRACKER));

        if (NULL != textTracker) {
            QCAR::WordList* wordList = textTracker->getWordList();

            // Load the word list
            if (false == wordList->loadWordList([wordListFile cStringUsingEncoding:NSASCIIStringEncoding], QCAR::WordList::STORAGE_APPRESOURCE)) {
                error = [[ErrorReport alloc] initWithMessage:"ERROR: failed to load word list"];
            }
        }
        else {
            error = [[ErrorReport alloc] initWithMessage:"ERROR: failed to load word list"];
        }

        // Inform the delegate that data set loading and activation has
        // completed (on the main thread)
        [self.delegate performSelectorOnMainThread:@selector(loadTextTrackerWordListComplete:) withObject:error waitUntilDone:NO];
    }
}

@end
