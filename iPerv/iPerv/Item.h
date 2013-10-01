//
//  Item.h
//  BeamIt
//
//  Created by Will Chen on 9/3/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Item : NSObject

@property (nonatomic, retain) CLLocation *location;
@property (nonatomic) double angle;
@property (nonatomic, retain) UIImage *image;

- (id)initWithLocation:(CLLocation *)location angle:(double)angle image:(UIImage *)image;

@end
