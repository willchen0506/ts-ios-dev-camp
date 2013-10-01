//
//  LocationManager.m
//  iPerv
//
//  Created by Will Chen on 9/27/13.
//  Copyright (c) 2013 TapSense. All rights reserved.
//

#import "LocationManager.h"
#import <QuartzCore/QuartzCore.h>

#define RadiansToDegrees(radians)(radians * 180.0/M_PI)
#define DegreesToRadians(degrees)(degrees * M_PI / 180.0)

@interface LocationManager() <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *myLocationManager;
@property (strong, nonatomic) CLLocation *targetLocation;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (nonatomic) double currentHeading;
@property (nonatomic) double GeoAngle;

@end


@implementation LocationManager

- (CLLocation *) getCurrentLocation {
    return self.currentLocation;
}

- (double) getCurrentAngle {
    return self.currentHeading;
}

- (CLLocationDistance) getDistanceFromLocation:(CLLocation *) location
{
    return [self.currentLocation distanceFromLocation:location];
}

-(float)setLatLonForDistanceAndAngle:(CLLocation *)userlocation targetLocation:(CLLocation *)targetLocation
{
    float lat1 = DegreesToRadians(userlocation.coordinate.latitude);
    float lon1 = DegreesToRadians(userlocation.coordinate.longitude);
    
    float lat2 = DegreesToRadians(targetLocation.coordinate.latitude);
    float lon2 = DegreesToRadians(targetLocation.coordinate.longitude);
    
    float dLon = lon2 - lon1;
    
    float y = sin(dLon) * cos(lat2);
    float x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    float radiansBearing = atan2(y, x);
    if(radiansBearing < 0.0)
    {
        radiansBearing += 2*M_PI;
    }
    
    return radiansBearing;
}

- (IBAction)updateLocationButton:(id)sender {
    self.targetLocation = self.currentLocation;
}

-(void) updateDirectionArrow
{
//    self.testLabel.text = [NSString stringWithFormat:@"LAT: %f, LON: %f, HEADING: %f", self.currentLocation.coordinate.latitude,
//                           self.currentLocation.coordinate.longitude, self.currentHeading];
//    self.setLocationLabel.text = [NSString stringWithFormat:@"LAT: %f, LON: %f", self.targetLocation.coordinate.latitude,
//                                  self.targetLocation.coordinate.longitude];
    //    self.targetHeading.text = [NSString stringWithFormat:@"%f", [self angleFromCoordinate:self.currentLocation.coordinate toCoordinate:self.targetLocation.coordinate]];
    //    self.stalkerTarget.transform = CGAffineTransformRotate(self.stalkerTarget.transform,
    //                                                           degreesToRadians(
    //                                                           [self getHeadingForDirectionFromCoordinate:self.currentLocation.coordinate toCoordinate:self.targetLocation.coordinate]
    //                                                                             ));
    
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = locations.lastObject;
    [self updateDirectionArrow];
}

-(void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    self.currentHeading = newHeading.magneticHeading;
    [self updateDirectionArrow];
    CLLocationDistance distance = [self.currentLocation distanceFromLocation:self.targetLocation];
//    self.targetHeading.text = [NSString stringWithFormat:@"%f", distance];
    //self.stalkerTarget.transform=CGAffineTransformMakeRotation((direction* M_PI / 180)+ self.GeoAngle);
}

- (id)init
{
    self = [super init];
    if (self){
                [self.myLocationManager stopUpdatingLocation];
        // Do any additional setup after loading the view, typically from a nib.
        // Creating location manager
        self.myLocationManager = [[CLLocationManager alloc] init];
        self.myLocationManager.delegate = self;
        self.myLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        // movement threshold for new event
        self.myLocationManager.distanceFilter = 1; // meters
        
        // set up anchor point for stalker target indicator
        //CGRect imageBounds = self.stalkerTarget.bounds;
        //[self.stalkerTarget.layer setAnchorPoint:CGPointMake(0.5, 0.0)];
        
        [self.myLocationManager startUpdatingLocation];
        [self.myLocationManager startUpdatingHeading];
    }
    return self;
}

@end
