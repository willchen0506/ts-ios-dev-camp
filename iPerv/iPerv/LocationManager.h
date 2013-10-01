//
//  LocationManager.h
//  iPerv
//
//  Created by Will Chen on 9/27/13.
//  Copyright (c) 2013 TapSense. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject

- (CLLocation *) getCurrentLocation;
- (double) getCurrentAngle;
- (CLLocationDistance) getDistanceFromLocation:(CLLocation *) location;

@end
