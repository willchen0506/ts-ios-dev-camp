// Copyright (c) 2013 Mutual Mobile (http://mutualmobile.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "LWSimpleTableViewController.h"
#import "MMExampleDrawerVisualStateManager.h"
#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import "MMCenterTableViewCell.h"
#import "MMExampleSideDrawerViewController.h"
#import "LWMapViewController.h"
#import "LWPathCell.h"

#import <QuartzCore/QuartzCore.h>

@interface LWSimpleTableViewController ()

@end

@implementation LWSimpleTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer * doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer * twoFingerDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerDoubleTap:)];
    [twoFingerDoubleTap setNumberOfTapsRequired:2];
    [twoFingerDoubleTap setNumberOfTouchesRequired:2];
    [self.view addGestureRecognizer:twoFingerDoubleTap];
    

    [self setupLeftMenuButton];
    
    [self.navigationController.navigationBar setTintColor:[UIColor
                                                           colorWithRed:78.0/255.0
                                                           green:156.0/255.0
                                                           blue:206.0/255.0
                                                           alpha:1.0]];
    
    
    [self.navigationController.view.layer setCornerRadius:10.0f];
    
    
    UIView *backView = [[UIView alloc] init];
//    [backView setBackgroundColor:[UIColor blackColor]];
    [backView setBackgroundColor:[UIColor colorWithRed:208.0/255.0
                                                 green:208.0/255.0
                                                  blue:208.0/255.0
                                                 alpha:1.0]];
    [self.tableView setBackgroundView:backView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"Center will appear");
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"Center did appear");
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"Center will disappear");
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    NSLog(@"Center did disappear");
}

-(void)setupLeftMenuButton{
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* customCellIdentifier = @"LWPathCell";
    LWPathCell* cell = (LWPathCell *) [tableView dequeueReusableCellWithIdentifier:customCellIdentifier];
    if (cell == nil)// tableview not associated (registered) with nib file.
    {
        UINib* customCellNib = [UINib nibWithNibName:@"LWPathCell" bundle:nil];
        // Register this nib file with cell identifier.
        
        [tableView registerNib: customCellNib forCellReuseIdentifier:customCellIdentifier];
        cell = (LWPathCell *) [tableView dequeueReusableCellWithIdentifier:customCellIdentifier];
    }
    
//    [cell.icon setImage:[UIImage imageNamed:@"sampleMapImage.png"]];
//    cell.ratingLabel.text = @"";
//    cell.priceLabel.text = @"";
//    cell.lastUserName.text = @"";
//    cell.appName.text = @"Path 1";
//    cell.allUsersLabel.text = @"Test";
//    cell.appName.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.55];
//    cell.lastUserName.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.55];
//    cell.priceLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.55];
//    cell.ratingLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.55];
//    cell.allUsersLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.55];
//    
//    cell.icon.layer.cornerRadius = 15.0;
//    cell.icon.layer.masksToBounds = YES;
//    cell.icon.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    cell.icon.layer.borderWidth = 5.5;

    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return self.title;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 30)];
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectInset(containerView.bounds, 14, 0)];
    
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setText:[tableView.dataSource tableView:tableView titleForHeaderInSection:section]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
    [titleLabel setTextColor:[UIColor colorWithRed:3.0/255.0
                                             green:48.0/255.0
                                              blue:77.0/255.0
                                             alpha:1.0]];
    [titleLabel setShadowColor:[[UIColor whiteColor] colorWithAlphaComponent:.5]];
    [titleLabel setShadowOffset:CGSizeMake(0, 1)];
    
    [containerView addSubview:titleLabel];
    
    return containerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    LWMapViewController * center = [[LWMapViewController alloc] init];
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:center];
    
    [self.mm_drawerController
     setCenterViewController:nav
     withCloseAnimation:YES
     completion:nil];
    
    
    
    
    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

#pragma mark - Button Handlers
-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)rightDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

-(void)doubleTap:(UITapGestureRecognizer*)gesture{
    [self.mm_drawerController bouncePreviewForDrawerSide:MMDrawerSideLeft completion:nil];
}

-(void)twoFingerDoubleTap:(UITapGestureRecognizer*)gesture{
    [self.mm_drawerController bouncePreviewForDrawerSide:MMDrawerSideRight completion:nil];
}

@end
