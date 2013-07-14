//
//  TestTableViewController.h
//  GeoPaths
//
//  Created by Minh Luong on 7/13/13.
//  Copyright (c) 2013 Minh Luong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, copy) NSArray *tableData;

@end
