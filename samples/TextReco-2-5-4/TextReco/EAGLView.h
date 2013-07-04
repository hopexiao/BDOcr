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


#import <UIKit/UIKit.h>

#import <QCAR/UIGLViewProtocol.h>

#import "WordlistView.h"


// EAGLView is a subclass of UIView and conforms to the informal protocol
// UIGLViewProtocol
@interface EAGLView : UIView <UIGLViewProtocol> {
@public
    // Shader handles
    unsigned int lineShaderProgramID;
    GLint mvpMatrixHandle;
    GLint lineOpacityHandle;
    GLint lineColorHandle;
    GLint vertexHandle;

@private
    // OpenGL ES context
    EAGLContext *context;
    
    // The OpenGL ES names for the framebuffer and renderbuffers used to render
    // to this view
    GLuint defaultFramebuffer;
    GLuint colorRenderbuffer;
    GLuint depthRenderbuffer;

    // View containing the list of detected words
    WordlistView *wordlistView;
}


// --- Public methods ---
- (void)finishOpenGLESCommands;
- (void)freeOpenGLESResources;

@end
