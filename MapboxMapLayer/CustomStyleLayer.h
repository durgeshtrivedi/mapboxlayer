//
//  CustomStyleLayer.h
//  MapboxLayer
//
//  Created by durgesh on 25/06/19.
//  Copyright © 2019 Mapbox. All rights reserved.
//


#ifndef CustomStyleLayer_h
#define CustomStyleLayer_h

#import <Mapbox/Mapbox.h>

@interface CustomStyleLayer : MGLOpenGLStyleLayer
- (instancetype)initWithIdentifier:(NSString *)identifier coordinateQuad:(MGLCoordinateQuad)coords;
//Defaults to true

@end

#endif /* CustomStyleLayer_h */

