/*==============================================================================
            Copyright (c) 2012-2013 QUALCOMM Austria Research Center GmbH.
            All Rights Reserved.
            Qualcomm Confidential and Proprietary
            
@file 
    RefFreeFrame.cpp

@brief
    Implementation of class RefFreeFrame.

==============================================================================*/

// ** Include files
#include <math.h>
#include <string.h>
#include <sys/time.h>

#include <QCAR/QCAR.h>
#include <QCAR/CameraDevice.h>
#include <QCAR/Tool.h>

#include <QCAR/TrackerManager.h>
#include <QCAR/ImageTracker.h>
#include <QCAR/ImageTargetBuilder.h>

#include <QCAR/Renderer.h>
#include <QCAR/VideoBackgroundConfig.h>

#include "RefFreeFrame.h"
#import "ShaderUtils.h"
#import <UIKit/UIKit.h>


// ** Some helper functions

/// Function used to transition in the range [0, 1]
void transition(float &v0, float inc, float a=0.0f, float b=1.0f)
{
	float vOut = v0 + inc;
	v0 = (vOut < a ? a : (vOut > b ? b : vOut));
}

// ** Constants

bool targetBuilderActive                = false;
int targetBuilderCounter                = 1;
extern RefFreeFrame refFreeFrame;

// ** Methods

RefFreeFrame::RefFreeFrame() : 
    
    curStatus(STATUS_IDLE), 
    elapsedBadFrame(0.0f),
    lastSuccessTime(0),
    trackableSource(NULL)
  
{
    
}

RefFreeFrame::~RefFreeFrame()
{
    
}


void
RefFreeFrame::init()
{
    qUtils = [QCARutils getInstance];
    targetImage = NULL;
    trackableSource = NULL;
}

void 
RefFreeFrame::deInit()
{
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ImageTracker* imageTracker = static_cast<QCAR::ImageTracker*>(trackerManager.getTracker(QCAR::Tracker::IMAGE_TRACKER));
    if(imageTracker != 0)
    {
        QCAR::ImageTargetBuilder* targetBuilder = imageTracker->getImageTargetBuilder();
        if (targetBuilder && (targetBuilder->getFrameQuality() != QCAR::ImageTargetBuilder::FRAME_QUALITY_NONE))
        {
            targetBuilder->stopScan();
        }
    }
}

void
RefFreeFrame::renderFrameIntoImage()
{

    QCAR::setFrameFormat(QCAR::RGB888, true);
    QCAR::State state = QCAR::Renderer::getInstance().begin();
    static int canUseFrame = 0;
    QCAR::Frame frame = state.getFrame();
    if (canUseFrame > 10)
    {
        for (int i = 0; i < frame.getNumImages(); i++)
        {
            targetImage = frame.getImage(i);
            if (targetImage->getFormat()==QCAR::RGB888) {
                image = createUIImage(targetImage);
                canUseFrame=0;
                break;
            }
            
        }
    }
    else
        canUseFrame++;
    QCAR::Renderer::getInstance().end();
    
}

void
RefFreeFrame::releasePixels(void *info,const void *data, size_t size){
}

UIImage *
RefFreeFrame::createUIImage(const QCAR::Image *qcarImage)

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




void
RefFreeFrame::initGL(int screenWidth, int screenHeight)
{
    QCAR::Renderer &renderer = QCAR::Renderer::getInstance();
    const QCAR::VideoBackgroundConfig &vc = renderer.getVideoBackgroundConfig();
    halfScreenSize.data[0] = vc.mSize.data[0] * 0.5f; 
    halfScreenSize.data[1] = vc.mSize.data[1] * 0.5f;
 
    // sets last frame timer
    lastFrameTime = getTimeMS();
    elapsedBadFrame = 0.0f;
}

void
RefFreeFrame::reset()
{
    curStatus = STATUS_IDLE;
    elapsedBadFrame = 0.0f;
}

void
RefFreeFrame::setCreating()
{
    curStatus = STATUS_CREATING;
}

void RefFreeFrame::updateUIState(QCAR::ImageTargetBuilder * targetBuilder, QCAR::ImageTargetBuilder::FRAME_QUALITY frameQuality)
{
    // ** Elapsed time
    unsigned int elapsedTimeMS = getTimeMS() - lastFrameTime;
    lastFrameTime += elapsedTimeMS;
    
    // these are time-dependent values used for transitions in the range [0, 1]
    float transitionTenSecond = elapsedTimeMS * 0.0001f;
    
	STATUS newStatus(curStatus);
    
	switch (curStatus)
	{
        case STATUS_IDLE:
			if (frameQuality != QCAR::ImageTargetBuilder::FRAME_QUALITY_NONE)
				newStatus = STATUS_SCANNING;
            
            break;
            
		case STATUS_SCANNING:
			switch (frameQuality)
            {
                // bad target quality, render the frame white until a match is made, then go to green
                case QCAR::ImageTargetBuilder::FRAME_QUALITY_LOW:
                    
                    elapsedBadFrame += transitionTenSecond;
                    
                    if (elapsedBadFrame >= 1)
                    {
                        NSLog(@"Can't find a target for 10 seconds");
                        elapsedBadFrame=0;
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kBadFrameQuality" object:nil];                    
                    break;
                    
                // good target, switch to green
                case QCAR::ImageTargetBuilder::FRAME_QUALITY_MEDIUM:                    
                case QCAR::ImageTargetBuilder::FRAME_QUALITY_HIGH:
                    
                    
                    elapsedBadFrame=0;
                    if(targetImage==NULL)
                        renderFrameIntoImage();
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kGoodFrameQuality" object:nil];
                    break;
                
                case QCAR::ImageTargetBuilder::FRAME_QUALITY_NONE:
                default:
                    //  Do nothing
                    break;
            }
            break;
            
		case STATUS_CREATING:
        {
            // check for new result
            // if found, set to success, success time and:
            QCAR::TrackableSource* newTrackableSource = targetBuilder->getTrackableSource();
            if (newTrackableSource != NULL)
            {
                newStatus = STATUS_SUCCESS;
                lastSuccessTime = lastFrameTime;
                trackableSource = newTrackableSource;
                targetBuilder->stopScan();
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kTrackableCreated" object:nil];
            }
        }
            break;
        default:
            break;
	}
    
	curStatus = newStatus;
}

void
RefFreeFrame::render()
{
    // ** Get the image tracker
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ImageTracker* imageTracker = static_cast<QCAR::ImageTracker*>(
                                                                        trackerManager.getTracker(QCAR::Tracker::IMAGE_TRACKER));
    
    // Get the frame quality from the target builder
    QCAR::ImageTargetBuilder* targetBuilder = imageTracker->getImageTargetBuilder();
    QCAR::ImageTargetBuilder::FRAME_QUALITY frameQuality = targetBuilder->getFrameQuality();
    
    // Update the UI internal state variables
    updateUIState(targetBuilder, frameQuality);
    
	if (curStatus == STATUS_SUCCESS)
    {
        curStatus = STATUS_IDLE;
        
        NSLog(@"Built target, reactivating dataset with new target");
        // activate the dataset with the new target added
        //imageTracker->activateDataSet(activeDataSet);
        restartTracker();
    }
        
    ShaderUtils::checkGlError("RefFreeFrame render");
}

unsigned int
RefFreeFrame::getTimeMS()
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec * 1000 + tv.tv_usec / 1000;
}


bool 
RefFreeFrame::startImageTargetBuilder()
{
    NSLog(@"RefFreeFrame startImageTargetBuilder()");
        
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ImageTracker* imageTracker = static_cast<QCAR::ImageTracker*>(trackerManager.getTracker(QCAR::Tracker::IMAGE_TRACKER));
    if(imageTracker != 0)
    {
        QCAR::ImageTargetBuilder* targetBuilder = imageTracker->getImageTargetBuilder();
        
        if (targetBuilder)
        {
            // if needed, stop the target builder
            
            if (targetBuilder->getFrameQuality() != QCAR::ImageTargetBuilder::FRAME_QUALITY_NONE)
                targetBuilder->stopScan();
            
            imageTracker->stop();
            
            targetBuilder->startScan();
        }
    }
    else
        return false;
    
    return true;
}


bool 
RefFreeFrame::stopImageTargetBuilder()
{
    NSLog(@"RefFreeFrame stopImageTargetBuilder()");
    
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ImageTracker* imageTracker = static_cast<QCAR::ImageTracker*>(trackerManager.getTracker(QCAR::Tracker::IMAGE_TRACKER));
    
    if(imageTracker)
    {
        QCAR::ImageTargetBuilder* targetBuilder = imageTracker->getImageTargetBuilder();
        if (targetBuilder)
        {
            if (targetBuilder->getFrameQuality() != QCAR::ImageTargetBuilder::FRAME_QUALITY_NONE)
            {
                targetBuilder->stopScan();
                targetBuilder = NULL;
                
                refFreeFrame.reset();
               
                QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
                QCAR::ImageTracker* imageTracker = static_cast<QCAR::ImageTracker*>(trackerManager.getTracker(QCAR::Tracker::IMAGE_TRACKER));
                
                imageTracker->start();
            }
        }
        else
          return false;
    }
    
    return true;
}


BOOL
RefFreeFrame::isImageTargetBuilderRunning()
{
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ImageTracker* imageTracker = static_cast<QCAR::ImageTracker*>(trackerManager.getTracker(QCAR::Tracker::IMAGE_TRACKER));
    
    if(imageTracker)
    {
        QCAR::ImageTargetBuilder* targetBuilder = imageTracker->getImageTargetBuilder();
        if(targetBuilder)
        {
            return targetBuilder->getFrameQuality() != QCAR::ImageTargetBuilder::FRAME_QUALITY_NONE;

        }
    }
    return false;
}


void
RefFreeFrame::
startBuild()
{
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ImageTracker* imageTracker = static_cast<QCAR::ImageTracker*>(trackerManager.getTracker(QCAR::Tracker::IMAGE_TRACKER));
    
    if(imageTracker)
    {
        QCAR::ImageTargetBuilder* targetBuilder = imageTracker->getImageTargetBuilder();
        if(targetBuilder)
        {
            char name[128];
            do
            {
                snprintf(name, sizeof(name), "UserTarget-%d", targetBuilderCounter++);
                NSLog(@"TRYING %s", name);
            }
            while (!targetBuilder->build(name, 320.0));
            
            refFreeFrame.setCreating();
            
            //  Display an alertView if the quality is low
            QCAR::ImageTargetBuilder::FRAME_QUALITY frameQuality = targetBuilder->getFrameQuality();
            if (frameQuality == QCAR::ImageTargetBuilder::FRAME_QUALITY_LOW)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Low Quality Image"
                                                                        message:@"The image has very little detail, please try another."
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles: nil];
                    [alertView show];
                    [alertView release];                    
                });
            }
        }
    }
}


BOOL RefFreeFrame::hasNewTrackableSource()
{
    return (trackableSource != NULL);
}

QCAR::TrackableSource* RefFreeFrame::getNewTrackableSource()
{
    QCAR::TrackableSource * result = trackableSource;
    trackableSource = NULL;
    return result;
}


void RefFreeFrame::restartTracker()
{
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ImageTracker* imageTracker = static_cast<QCAR::ImageTracker*>(trackerManager.getTracker(QCAR::Tracker::IMAGE_TRACKER));
    
    imageTracker->start();    
}













