#import "CrumbPath.h"
#import "CrumbPathView.h"
#import "BreadcrumbViewController.h"


@interface BreadcrumbViewController()

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) IBOutlet MKMapView *map;

@property (nonatomic, strong) UIBarButtonItem *flipButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) IBOutlet UIView *instructionsView;

@property (nonatomic, strong) CrumbPath *crumbs;
@property (nonatomic, strong) CrumbPathView *crumbView;

@property (nonatomic, strong) IBOutlet UISwitch *toggleBackgroundButton;
@property (nonatomic, strong) IBOutlet UISwitch *toggleNavigationAccuracyButton;
@property (nonatomic, strong) IBOutlet UISwitch *trackUserButton;
@property (nonatomic, strong) IBOutlet UILabel *trackUserLabel;

- (IBAction)toggleBestAccuracy:(id)sender;

@end


#pragma mark -

@implementation BreadcrumbViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Note: we are using Core Location directly to get the user location updates.
    // We could normally use MKMapView's user location update delegation but this does not work in
    // the background.  Plus we want "kCLLocationAccuracyBestForNavigation" which gives us a better accuracy.
    //
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self; // Tells the location manager to send updates to this object
    
    // By default use the best accuracy setting (kCLLocationAccuracyBest)
	//
	// You mau instead want to use kCLLocationAccuracyBestForNavigation, which is the highest possible
	// accuracy and combine it with additional sensor data.  Note that level of accuracy is intended
	// for use in navigation applications that require precise position information at all times and
	// are intended to be used only while the device is plugged in.
    //
    BOOL navigationAccuracy = [self.toggleNavigationAccuracyButton isOn];
	self.locationManager.desiredAccuracy =
        (navigationAccuracy ? kCLLocationAccuracyBestForNavigation : kCLLocationAccuracyBest);
    
    // hide the prefs UI for user tracking mode - if MKMapView is not capable of it
    if (![self.map respondsToSelector:@selector(setUserTrackingMode:animated:)])
    {
        self.trackUserButton.hidden = self.trackUserLabel.hidden = YES;
    }

    [self.locationManager startUpdatingLocation];
    
    // create the container view which we will use for flip animation (centered horizontally)
	_containerView = [[UIView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:self.containerView];
    
    [self.containerView addSubview:self.map];
    
    // add our custom flip button as the nav bar's custom right view
	UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    CGRect frame = infoButton.frame;
    frame.size.width = 40.0f;
    infoButton.frame = frame;
	[infoButton addTarget:self action:@selector(flipAction:) forControlEvents:UIControlEventTouchUpInside];
	_flipButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
	self.navigationItem.rightBarButtonItem = self.flipButton;
	
	// create our done button as the nav bar's custom right view for the flipped view (used later)
	_doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                               target:self
                                                               action:@selector(flipAction:)];
}

- (void)dealloc
{
    self.locationManager.delegate = nil;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Actions

// called when the app is moved to the background (user presses the home button) or to the foreground 
//
- (void)switchToBackgroundMode:(BOOL)background
{
    if (background)
    {
        if (!self.toggleBackgroundButton.isOn)
        {
            [self.locationManager stopUpdatingLocation];
            self.locationManager.delegate = nil;
        }
    }
    else
    {
        if (!self.toggleBackgroundButton.isOn)
        {
            self.locationManager.delegate = self;
            [self.locationManager startUpdatingLocation];
        }
    }
}

- (IBAction)toggleBestAccuracy:(id)sender
{
    UISwitch *accuracySwitch = (UISwitch *)sender;
    if (accuracySwitch.isOn)
    {
        // better accuracy
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    }
    else
    {
        // normal accuracy
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
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

// called when the user presses the 'i' icon to change the app settings
//
- (void)flipAction:(id)sender
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.75];
	
    // since the user can turn off user tracking by simply moving the map,
    // we want to make sure our UISwitch reflects that change.
    [self.trackUserButton setOn:([self.map userTrackingMode] == MKUserTrackingModeFollowWithHeading ? YES : NO)];
    
	[UIView setAnimationTransition:([self.map superview] ?
									UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight)
                           forView:self.containerView cache:YES];
	if ([self.instructionsView superview])
	{
		[self.instructionsView removeFromSuperview];
		[self.containerView addSubview:self.map];
	}
	else
	{
		[self.map removeFromSuperview];
		[self.containerView addSubview:self.instructionsView];
	}
	
	[UIView commitAnimations];
	
	// adjust our done/info buttons accordingly
	if ([self.instructionsView superview])
		self.navigationItem.rightBarButtonItem = self.doneButton;
	else
		self.navigationItem.rightBarButtonItem = self.flipButton;
}


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
    if (!self.crumbView)
    {
        _crumbView = [[CrumbPathView alloc] initWithOverlay:overlay];
    }
    return self.crumbView;
}

@end
