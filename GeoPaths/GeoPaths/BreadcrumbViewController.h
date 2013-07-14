#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MapKit/MapKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface BreadcrumbViewController : UIViewController
            <MKMapViewDelegate, CLLocationManagerDelegate>

- (void)switchToBackgroundMode:(BOOL)background;

@end

