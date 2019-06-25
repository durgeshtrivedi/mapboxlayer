//
//  MyView.m
//  MapboxLayer
//
//  Created by durgesh on 25/06/19.
//  Copyright © 2019 Mapbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "MyView.h"

#include "Loop.h"
#include "Constants.h"

/**************************************************************************************************************
 *    MARK:    Callbacks + Functions
 ***************************************************************************************************************/
int AllocateRenderbufferStorage(void *context, void *layer) {
    return [(EAGLContext*)context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(id<EAGLDrawable>)layer] ? T: F;
}

/**************************************************************************************************************
 *    MARK:    App
 ***************************************************************************************************************/
@implementation MyView
@synthesize link;

+ (Class) layerClass {
    return [CAEAGLLayer class];
}

-(id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    NSAssert(self, @"Unable to init AppView");

    /* Init EAGL */
    CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
    // Configure it so that it is opaque, does not retain the contents of the backbuffer when displayed, and uses RGBA8888 color.
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
                                    kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                    nil];
    
    /* Create context for rendering OpenGL ES 2*/
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    NSAssert(self.context, @"Creating context failed");
    
    BOOL status = [EAGLContext setCurrentContext:self.context];
    NSAssert(status, @"Setting current context failed");
    
    // Create framebuffer
    renderbuffer_storage_.callback = &AllocateRenderbufferStorage;
    renderbuffer_storage_.context =   self.context;
    renderbuffer_storage_.layer = self.layer;
    
    framebuffer_ = CreateFramebuffer(&renderbuffer_storage_);
    NSAssert(status, @"Creating framebuffer failed");
    
    // Set viewport
    glViewport(0, 0, (GLsizei)frame.size.width, (GLsizei)frame.size.height);
    
    // Load shader
    program_ = CompileShader("Shader.vsh", "Shader.fsh", &BindAttributes);
    
    // Set loop
    time_ = 0.0;
    self.link = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(loop)];
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    return self;
}

- (void)dealloc {
    [super dealloc];
    DestroyFramebuffer(&framebuffer_);
    
    if([EAGLContext currentContext] == self.context)    {
        [EAGLContext setCurrentContext:nil];
    }
    self.context = nil;
  
}

-(void)layoutSubviews {
    [EAGLContext setCurrentContext:self.context];
    DestroyFramebuffer(&framebuffer_);
    framebuffer_ = CreateFramebuffer(&renderbuffer_storage_);
    
    [self render];
}

- (void)render {
    //init if not already
    if(!setup_)    {
        Init();
        setup_ = YES;
    }
    
    //clear framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer_.buffer);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //update
    CFTimeInterval time = self.link.timestamp;
    CFTimeInterval dt = time - time_;
    Update(dt * 1000);
    time_ = time;
    
    // render
    Render(program_);
    
    //pass to EGL
    glBindRenderbuffer(GL_RENDERBUFFER, framebuffer_.renderbuffer[0]);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
    
    GLenum err = glGetError();
    if(err) {
        NSLog(@"%x error", err);
    }
}

-(void) loop {
    [self render];
}

@end
