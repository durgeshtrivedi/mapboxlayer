
//
//  CustomStyleLayer.m
//  MapboxLayer
//
//  Created by durgesh on 25/06/19.
//  Copyright © 2019 Mapbox. All rights reserved.
//

#import "CustomStyleLayer.h"

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import <AVFoundation/AVFoundation.h>
#import "MyView.h"
#if defined SAVE_DEBUG_FRAMES
#import <UIKit/UIKit.h>
#endif

NS_INLINE MGLCoordinateBounds MGLCoordinateBoundsForQuad(MGLCoordinateQuad quad) {
    CLLocationDegrees s = fmin(
        fmin(quad.topLeft.latitude, quad.topRight.latitude),
        fmin(quad.bottomLeft.latitude, quad.bottomRight.latitude));
    CLLocationDegrees w = fmin(
        fmin(quad.topLeft.longitude, quad.topRight.longitude),
        fmin(quad.bottomLeft.longitude, quad.bottomRight.longitude));
    CLLocationDegrees n = fmax(
        fmax(quad.topLeft.latitude, quad.topRight.latitude),
        fmax(quad.bottomLeft.latitude, quad.bottomRight.latitude));
    CLLocationDegrees e = fmax(
        fmax(quad.topLeft.longitude, quad.topRight.longitude),
        fmax(quad.bottomLeft.longitude, quad.bottomRight.longitude));
    return MGLCoordinateBoundsMake(CLLocationCoordinate2DMake(s, w),
        CLLocationCoordinate2DMake( n, e ));
}

@implementation CustomStyleLayer {
    GLuint _program;
    GLuint _vertexShader;
    GLuint _fragmentShader;
    GLuint _buffer;
    GLuint _aPos, _aTexPos;
    GLuint _image0;
    GLuint _videoFrameTexture;
    GLuint _vertexBuffer;
    GLuint _textureBuffer;

    AVAssetReader *_movieReader;
    GLuint _umatrix, _uZoom;

    NSURL * _videoUrl;
    MGLCoordinateBounds _bounds;
    MGLCoordinateQuad _quad;
    NSTimer * videoFrameTimer;
    MyView *myView;

}

- (instancetype)initWithIdentifier:(NSString *)identifier coordinateQuad:(MGLCoordinateQuad)coords {
    self = [self initWithIdentifier:identifier];
    _quad = coords;
    _bounds = MGLCoordinateBoundsForQuad(_quad);

    return self;
}

- (void)didMoveToMapView:(MGLMapView *)mapView {
    
    CGRect frame = CGRectMake(0, 0, mapView.frame.size.width, mapView.frame.size.height/1.5);
    myView = [[MyView alloc] initWithFrame:frame];
    [myView setBackgroundColor:[UIColor clearColor]];
    [mapView addSubview:myView];
}

- (void)willMoveFromMapView:(MGLMapView *)mapView {
    // Add code here
}

- (void)drawInMapView:(MGLMapView *)mapView withContext:(MGLStyleLayerDrawingContext)context {
    if (MGLCoordinateBoundsIntersectsCoordinateBounds(_bounds,
            mapView.visibleCoordinateBounds)) {
      // Add code here
    }
}

- (void)clearShaders {
    if (!_program) {
        return;
    }

    glDeleteBuffers(1, &_buffer);
    glDetachShader(_program, _vertexShader);
    glDetachShader(_program, _fragmentShader);
    glDeleteShader(_vertexShader);
    glDeleteShader(_fragmentShader);
    glDeleteProgram(_program);
}

-(void)update:(NSTimer *)timer {
    [self setNeedsDisplay];
}

@end
