//
//  ViewController.m
//  MapboxLayer
//
//  Created by durgesh on 25/06/19.
//  Copyright © 2019 Mapbox. All rights reserved.
//

#import "ViewController.h"
#import "CustomStyleLayer.h"


@interface ViewController () <MGLMapViewDelegate> {
    MGLMapView * _mapView;
}
@end

@implementation ViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MGLMapView *mapView = [[MGLMapView alloc] initWithFrame:self.view.bounds styleURL:[MGLStyle satelliteStreetsStyleURL]];
    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [mapView setMinimumZoomLevel:2];
    
    [mapView setCenterCoordinate:CLLocationCoordinate2DMake(37.562984, -122.514426)
        zoomLevel:14
        animated:NO];
    
    [self.view addSubview:mapView];
    [mapView setDelegate:self];
    _mapView = mapView;
}

-(void)mapView:(MGLMapView *)mapView didFinishLoadingStyle:(MGLStyle *)style {
   

    MGLCoordinateQuad quad = {
        {37.56238816766053, -122.51596391201019},
        {37.56161849366671, -122.51423120498657},
        {37.563391708549425, -122.51309394836426},
        {37.56410183312965, -122.51467645168304}
    };

    CustomStyleLayer *layer = [[CustomStyleLayer alloc]
                                initWithIdentifier:@"custom_triangle"
                                coordinateQuad:quad];

    [mapView.style addLayer:layer];
}
@end
