//
//  ViewController.m
//  iPerv
//
//  Created by Will Chen on 9/26/13.
//  Copyright (c) 2013 TapSense. All rights reserved.
//

#import "ViewController.h"
#import "SessionContainer.h"
#import "LocationManager.h"
#import "Item.h"


@interface ViewController () <SessionContainerDelegate, MCBrowserViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *myLabel;
@property (strong, nonatomic) IBOutlet UILabel *connectionStatusLabel;
@property (strong, nonatomic) IBOutlet UIImageView *targetImage;
@property (retain, nonatomic) SessionContainer *sessionContainer;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (retain, nonatomic) LocationManager  *locationManager;
@end

@implementation ViewController

- (IBAction)TakePhotoAction:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void) statusChanged:(NSString *)status{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.connectionStatusLabel.text = status;
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        [self presentViewController:picker animated:YES completion:NULL];
    });
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info

{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    Item *item = [[Item alloc] initWithLocation:[self.locationManager getCurrentLocation] angle:[self.locationManager getCurrentAngle] image:chosenImage
                  ];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:item];
    [self.sessionContainer sendData:data];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.locationManager = [[LocationManager alloc] init];
    [self createSession];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createSession
{
    // Create the SessionContainer for managing session related functionality.
    self.sessionContainer = [[SessionContainer alloc] initWithDisplayName:@"WillName" serviceType:@"tapsenseService"];
    _sessionContainer.delegate = self;
    // Set this view controller as the SessionContainer delegate so we can display incoming Transcripts and session state changes in our table view.
}

#pragma mark - MCBrowserViewControllerDelegate methods

// Override this method to filter out peers based on application specific needs
- (BOOL)browserViewController:(MCBrowserViewController *)browserViewController shouldPresentNearbyPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    return YES;
}

// Override this to know when the user has pressed the "done" button in the MCBrowserViewController
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

// Override this to know when the user has pressed the "cancel" button in the MCBrowserViewController
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void) receivedData:(NSData *)data
{
    NSLog(@"Received something");
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSString *receivedMessage = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
        Item *item = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSLog(@"here: %@", item);
        self.targetImage.image = item.image;
        self.distanceLabel.text = [NSString stringWithFormat:@"Your target is %f meters away (%f)...",
        [self.locationManager getDistanceFromLocation:item.location], item.angle];
    });

}

- (IBAction)browseForPeers:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Instantiate and present the MCBrowserViewController
    MCBrowserViewController *browserViewController = [[MCBrowserViewController alloc] initWithServiceType:@"tapsenseService" session:self.sessionContainer.session];
    
	browserViewController.delegate = self;
    browserViewController.minimumNumberOfPeers = kMCSessionMinimumNumberOfPeers;
    browserViewController.maximumNumberOfPeers = kMCSessionMaximumNumberOfPeers;
    
    [self presentViewController:browserViewController animated:YES completion:nil];
}

@end
