/*==============================================================================
            Copyright (c) 2012-2013 QUALCOMM Austria Research Center GmbH.
            All Rights Reserved.
            Qualcomm Confidential and Proprietary
            
@file 
    RefFreeFrame.h

@brief
    A utility class for textures used in the samples.

==============================================================================*/
#ifndef _QCAR_REFFREEFRAME_GL_H_
#define _QCAR_REFFREEFRAME_GL_H_

// Include files
#import <QCAR/Tool.h>
#import <QCAR/DataSet.h>
#import <QCAR/ImageTarget.h>
#include <QCAR/QCAR.h>
#include <QCAR/CameraDevice.h>
#include <QCAR/Tool.h>
#include <QCAR/TrackerManager.h>
#include <QCAR/ImageTracker.h>
#include <QCAR/ImageTargetBuilder.h>
#include <QCAR/Renderer.h>
#include <QCAR/VideoBackgroundConfig.h>
#include <QCAR/Frame.h>
#include <QCAR/Image.h>


#import "QCARutils.h"

// Forward declarations

/// A utility class for the RefFree frame.
class RefFreeFrame
{
public:

    /// Constructor
    RefFreeFrame();

    /// Destructor.
    ~RefFreeFrame();

    /// Initializes the class (uses assets, need to be called from an Activity
    void init();

     /// Initializes (OpenGL-dependent and camera-dependent!!!) - Call when there's a valid GL context
    void initGL(int screenWidth, int screenHeight);

    /// Deinitilizes the class
    void deInit();

    /// Updates the states and renders the hints, depending on the current status of the tracker
    void render();

    /// Resets the curStatus to IDLE
    void reset();
    
    /// Sets the state to CREATING
    void setCreating();
    
    bool stopImageTargetBuilder();
    
    BOOL isImageTargetBuilderRunning();
    
    bool startImageTargetBuilder();
    
    void startBuild();
    
    QCARutils *qUtils;
    
    
    const QCAR::Image * targetImage;
    UIImage * image;
    /// Checks if a new trackable source is available
    BOOL hasNewTrackableSource();
    
    /// Retreives the available trackable source, returns NULL if the trackable has already been retreived
    QCAR::TrackableSource* getNewTrackableSource();
    
    void restartTracker();
    void renderFrameIntoImage();
    
     UIImage * createUIImage(const QCAR::Image * qcarImage);
    
    void releasePixels(void *info,const void *data, size_t size);
protected:
    /// Get the time in milliseconds
    unsigned int getTimeMS();
    
    /// The following methods rely on the internal state of this class
    /// when they are called.  Take care if extracting their functionality
    /// that you properly set up the enviroment.
    
    /// Updates the UI state in the render method
    void updateUIState(QCAR::ImageTargetBuilder * targetBuilder, QCAR::ImageTargetBuilder::FRAME_QUALITY frameQuality);
    
    /// Renders the scanning state view finder according to the result
    void renderScanningViewfinder(QCAR::ImageTargetBuilder::FRAME_QUALITY quality);
      
    /**
     * Enum to decribe the status of the UI showing the target 
     * creation state. 
     *  
     * IDLE - No target is currently being created 
     * SCANNING - Show the "Scanning UI", this uses frame quality info 
     *            from the SDK to give feedback to the user as to how
     *            good a target their current frame is.
     * CREATING - While in this state the SDK is creating the target 
     *            requested by the app layer.
     * SUCCESS - This state indicates that target creation was successful.
     */
    enum STATUS { STATUS_IDLE, STATUS_SCANNING, STATUS_CREATING, STATUS_SUCCESS };
    STATUS curStatus;
    
    /// Half of the screen size, used often in the rendering pipeline
    QCAR::Vec2F halfScreenSize;
    
    float elapsedBadFrame;
    
    /// Keep track of the time between frames for color transitions
    unsigned int lastFrameTime;
    unsigned int lastSuccessTime;
    
     /// The latest trackable source to be extracted from the Target Builder
    QCAR::TrackableSource* trackableSource;
   
};


#endif //_QCAR_REFFREEFRAME_H_
