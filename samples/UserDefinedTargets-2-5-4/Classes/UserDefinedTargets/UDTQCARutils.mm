/*==============================================================================
 Copyright (c) 2012-2013 QUALCOMM Austria Research Center GmbH.
 All Rights Reserved.
 Qualcomm Confidential and Proprietary
 ==============================================================================*/

#import "UDTQCARutils.h"
#import <QCAR/QCAR.h>
#import <QCAR/QCAR_iOS.h>
#import <QCAR/CameraDevice.h>
#import <QCAR/Renderer.h>
#import <QCAR/Tracker.h>
#import <QCAR/TrackerManager.h>
#import <QCAR/ImageTracker.h>
#import <QCAR/MarkerTracker.h>
#import <QCAR/VideoBackgroundConfig.h>
#import <QCAR/TargetFinder.h>
#import <QCAR/TargetSearchResult.h>

extern QCAR::DataSet* dataSetUserDef;

#pragma mark --- Class implementation ---

@implementation UDTQCARutils
@synthesize hasSeenInstructions;

// initialise QCARutils
- (id) init
{
    if ((self = [super init]) != nil)
    {
        isVisualSearchOn= NO;
    }
    return self;
}


// Return the UDTQCARutils singleton, initing if necessary.  We instantiate this
// as soon as the app starts (in the app delegate), so it replaces the standard
// QCARutils object
+ (UDTQCARutils *) getInstance
{
    if (qUtils == nil)
    {
        qUtils = [[UDTQCARutils alloc] init];
    }
        
    return (UDTQCARutils *)qUtils;
}


// discard resources
- (void)dealloc {
    targetsList = nil;
    [super dealloc];
}

- (void)loadTracker
{
    [self initUserDefinedTargets];
}


////////////////////////////////////////////////////////////////////////////////
// Load the tracker data [performed on a background thread]
- (void)initUserDefinedTargets
{
    // Background thread must have its own autorelease pool
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    NSLog(@"UDTQCARutils: LoadTrackerData");
    
    // Get the image tracker:
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ImageTracker* imageTracker = static_cast<QCAR::ImageTracker*>(
                                                                        trackerManager.getTracker(QCAR::Tracker::IMAGE_TRACKER));
    if (imageTracker != nil)
    {
        // Create the data set:
        dataSetUserDef = imageTracker->createDataSet();
        if (dataSetUserDef != nil)
        {
            if (!imageTracker->activateDataSet(dataSetUserDef))
            {
                NSLog(@"Failed to activate data set.");
                appStatus = APPSTATUS_ERROR;
                errorCode = QCAR_ERRCODE_LOAD_TARGET;
            }
        }
    }
    
    NSLog(@"Successfully loaded and activated data set.");
    
    
    // Continue execution on the main thread
    if (appStatus != APPSTATUS_ERROR)
        [self performSelectorOnMainThread:@selector(bumpAppStatus) withObject:nil waitUntilDone:NO];
    
    [pool release];
}


#pragma mark --- configuration methods ---
////////////////////////////////////////////////////////////////////////////////
// Load and Unload Data Set

- (BOOL)unloadDataSet:(QCAR::DataSet *)theDataSet
{
    BOOL success = NO;
    // Get the image tracker:
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ImageTracker* imageTracker = static_cast<QCAR::ImageTracker*>(trackerManager.getTracker(QCAR::Tracker::IMAGE_TRACKER));
    if (imageTracker == NULL)
    {
        NSLog(@"Failed to destroy the tracking data set because the ImageTracker has not been initialized.");
        errorCode = QCAR_ERRCODE_INIT_TRACKER;  
    }
    
    if (dataSetUserDef != 0)
    {
        if (imageTracker->getActiveDataSet() && !imageTracker->deactivateDataSet(dataSetUserDef))
        {
            NSLog(@"Failed to destroy the tracking data set because the data set could not be deactivated.");
            errorCode = QCAR_ERRCODE_DEACTIVATE_DATASET;
        }        
        else 
        {
            if (!imageTracker->destroyDataSet(dataSetUserDef))
            {
                NSLog(@"Failed to destroy the tracking data set.");
                
            }
            else
            {        
                NSLog(@"Successfully destroyed the data set.");
                
                success = YES;
            }
        }
    }
    
    dataSetUserDef = nil;
    return success;

}

@end
