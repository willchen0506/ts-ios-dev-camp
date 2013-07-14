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

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UIButton *logButton;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)buttonClicked:(id)sender {
    if ([self.logButton.titleLabel.text isEqualToString:@"Start logging"]) {
        [self.logButton setTitle:@"Stop logging" forState:UIControlStateNormal];
        [self logLocation];
        timer = [NSTimer scheduledTimerWithTimeInterval:5
                                                 target:self
                                               selector:@selector(logLocation)
                                               userInfo:nil
                                                repeats:YES];
    } else {
        [self.logButton setTitle:@"Start logging" forState:UIControlStateNormal];
        [timer invalidate];
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

@end
