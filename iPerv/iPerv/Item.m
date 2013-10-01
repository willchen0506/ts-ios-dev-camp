//
//  Item.m
//  BeamIt
//
//  Created by Will Chen on 9/3/13.
//
//

#import "Item.h"

@implementation Item

- (id)initWithLocation:(CLLocation *)location angle:(double)angle image:(UIImage *)image;
{
    self = [super init];
    if (self) {
        self.angle = angle;
        self.location = location;
        self.image = image;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.location forKey:@"location"];
    [coder encodeDouble:self.angle forKey:@"angle"];
    [coder encodeObject:self.image forKey:@"image"];
}


- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _location = [coder decodeObjectForKey:@"location"];
        _image = [coder decodeObjectForKey:@"image"];
        _angle = [coder decodeDoubleForKey:@"angle"];
    }
    return self;
}
@end
