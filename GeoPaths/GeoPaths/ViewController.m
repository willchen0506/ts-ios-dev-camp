//
//  ViewController.m
//  GeoPaths
//
//  Created by Minh Luong on 7/13/13.
//  Copyright (c) 2013 Minh Luong. All rights reserved.
//

#import "ViewController.h"
#import <GPX/GPX.h>
#import <Parse/Parse.h>
#import "TestTableViewController.h"
#import "CrumbPath.h"
#import "CrumbPathView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UIButton *logButton;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) IBOutlet MKMapView *map;
@property (nonatomic, strong) CrumbPath *crumbs;
@property (nonatomic, strong) CrumbPathView *crumbView;

@end

@implementation ViewController {
    NSTimer *timer;
    NSMutableArray *locations;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    locations = [NSMutableArray array];
    
    
    //[self.locationManager startUpdatingLocation];
    [self.map setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:NO];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)buttonClicked:(id)sender {
    if ([self.logButton.titleLabel.text isEqualToString:@"Start"]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self; // Tells the location manager to send updates to this object
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest; // kCLLocationAccuracyBestForNavigation
        
        [self.logButton setTitle:@"Stop" forState:UIControlStateNormal];
        [self.locationManager startUpdatingLocation];
        //[self logLocation];
//        timer = [NSTimer scheduledTimerWithTimeInterval:5
//                                                 target:self
//                                               selector:@selector(logLocation)
//                                               userInfo:nil
//                                                repeats:YES];
    } else {
        [self.logButton setTitle:@"Start" forState:UIControlStateNormal];
        [self.locationManager stopUpdatingLocation];
        self.locationManager.delegate = nil;
        //[timer invalidate];
    }
}

- (void)logLocation
{
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        self.location.text = [NSString stringWithFormat:@"%f,%f",
                              [geoPoint latitude],
                              [geoPoint longitude]];
        [locations addObject:geoPoint];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"viewAllLocations"]) {
        TestTableViewController *destViewController = segue.destinationViewController;
        ((TestTableViewController *)destViewController).tableData = locations;
    }
}

- (IBAction)toggleTrackUserHeading:(id)sender
{
    UISwitch *trackHeaderSwitch = (UISwitch *)sender;
    if (trackHeaderSwitch.isOn)
    {
        // track the user (the map follows the user's location and heading)
        [self.map setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:NO];
    }
    else
    {
        [self.map setUserTrackingMode:MKUserTrackingModeNone animated:NO];
    }
}

// MapKit
#pragma mark - MapKit

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if (newLocation)
    {
		// make sure the old and new coordinates are different
        if ((oldLocation.coordinate.latitude != newLocation.coordinate.latitude) &&
            (oldLocation.coordinate.longitude != newLocation.coordinate.longitude))
        {
            if (!self.crumbs)
            {
                // This is the first time we're getting a location update, so create
                // the CrumbPath and add it to the map.
                //
                _crumbs = [[CrumbPath alloc] initWithCenterCoordinate:newLocation.coordinate];
                [self.map addOverlay:self.crumbs];
                [self.map setShowsUserLocation:YES];
                
                // On the first location update only, zoom map to user location
                MKCoordinateRegion region =
                MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 2000, 2000);
                [self.map setRegion:region animated:YES];
            }
            else
            {
                // This is a subsequent location update.
                // If the crumbs MKOverlay model object determines that the current location has moved
                // far enough from the previous location, use the returned updateRect to redraw just
                // the changed area.
                //
                // note: iPhone 3G will locate you using the triangulation of the cell towers.
                // so you may experience spikes in location data (in small time intervals)
                // due to 3G tower triangulation.
                //
                NSLog(@"%f, %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
                MKMapRect updateRect = [self.crumbs addCoordinate:newLocation.coordinate];
                
                if (!MKMapRectIsNull(updateRect))
                {
                    // There is a non null update rect.
                    // Compute the currently visible map zoom scale
                    MKZoomScale currentZoomScale = (CGFloat)(self.map.bounds.size.width / self.map.visibleMapRect.size.width);
                    // Find out the line width at this zoom scale and outset the updateRect by that amount
                    CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
                    updateRect = MKMapRectInset(updateRect, -lineWidth, -lineWidth);
                    // Ask the overlay view to update just the changed area.
                    [self.crumbView setNeedsDisplayInMapRect:updateRect];
                }
            }
        }
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    NSLog(@"CRUMB VIEW IS %@", self.crumbView);
    
    if (!self.crumbView)
    {
        _crumbView = [[CrumbPathView alloc] initWithOverlay:overlay];
    }
    return self.crumbView;
}


@end
