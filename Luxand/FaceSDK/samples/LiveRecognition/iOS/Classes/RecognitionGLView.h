//
//  based on ColorTrackingGLView.h
//  from ColorTracking application
//  The source code for this application is available under a BSD license.
//  See ColorTrackingLicense.txt for details.
//  Created by Brad Larson on 10/7/2010.
//  Modified by Anton Malyshev on 6/21/2013.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface RecognitionGLView : UIView
{
	/* The pixel dimensions of the backbuffer */
	GLint backingWidth, backingHeight;
	
	EAGLContext *context;
	
	/* OpenGL names for the renderbuffer and framebuffers used to render to this view */
	GLuint viewRenderbuffer, viewFramebuffer;	
}

// OpenGL drawing
- (BOOL)createFramebuffers;
- (void)destroyFramebuffer;
- (void)setDisplayFramebuffer;
- (BOOL)presentFramebuffer;

@end
