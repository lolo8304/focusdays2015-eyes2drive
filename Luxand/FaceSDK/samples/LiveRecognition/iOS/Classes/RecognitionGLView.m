//
//  based on ColorTrackingGLView.m
//  from ColorTracking application
//  The source code for this application is available under a BSD license.
//  See ColorTrackingLicense.txt for details.
//  Created by Brad Larson on 10/7/2010.
//  Modified by Anton Malyshev on 6/21/2013.
//

#import "RecognitionGLView.h"
#import <OpenGLES/EAGLDrawable.h>
#import <QuartzCore/QuartzCore.h>

@implementation RecognitionGLView

#pragma mark -
#pragma mark Initialization and teardown

// Override the class method to return the OpenGL layer, as opposed to the normal CALayer
+ (Class) layerClass 
{
	return [CAEAGLLayer class];
}

- (void)dealloc 
{
    [context release];
    context = NULL;
    [self destroyFramebuffer];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) {
		// Do OpenGL Core Animation layer setup
		CAEAGLLayer * eaglLayer = (CAEAGLLayer *)self.layer;
		
		// Set scaling to account for Retina display	
        //if ([self respondsToSelector:@selector(setContentScaleFactor:)]) {
        //    self.contentScaleFactor = [[UIScreen mainScreen] scale];
        //}
		
		eaglLayer.opaque = YES;
		eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		if (!context || ![EAGLContext setCurrentContext:context] || ![self createFramebuffers]) {
			[self release];
			return nil;
		}
        
        //self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        //self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

#pragma mark -
#pragma mark OpenGL drawing

- (BOOL)createFramebuffers
{	
	glEnable(GL_TEXTURE_2D);
	glDisable(GL_DEPTH_TEST);

	// Onscreen framebuffer object
	glGenFramebuffers(1, &viewFramebuffer);
	glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
	
	glGenRenderbuffers(1, &viewRenderbuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
	
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
	
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
#if defined(DEBUG)
    NSLog(@"Backing width: %d, height: %d", backingWidth, backingHeight);
#endif
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, viewRenderbuffer);
	
	if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
#if defined(DEBUG)
        NSLog(@"Failure with framebuffer generation");
#endif
		return NO;
	}
		
	GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
#if defined(DEBUG)		
        NSLog(@"Incomplete FBO: %d", status);
#endif        
        exit(1);
    }
	
	return YES;
}

- (void)destroyFramebuffer;
{	
	if (viewFramebuffer) {
		glDeleteFramebuffers(1, &viewFramebuffer);
		viewFramebuffer = 0;
	}
	if (viewRenderbuffer) {
		glDeleteRenderbuffers(1, &viewRenderbuffer);
		viewRenderbuffer = 0;
	}
}

- (void)setDisplayFramebuffer;
{
    if (context) {
        //[EAGLContext setCurrentContext:context];
        if (!viewFramebuffer) {
            [self createFramebuffers];
		}
        glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
        glViewport(0, 0, backingWidth, backingHeight);
    }
}

- (BOOL)presentFramebuffer;
{
    BOOL success = FALSE;
    if (context) {
        //[EAGLContext setCurrentContext:context];        
        glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
        success = [context presentRenderbuffer:GL_RENDERBUFFER];
    }
    return success;
}

@end
