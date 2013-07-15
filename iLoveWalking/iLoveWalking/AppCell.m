//
//  AppCell128.m
//  BackgroundProcessDemo
//
//  Created by Will Chen on 1/11/13.
//  Copyright (c) 2013 Will Chen. All rights reserved.
//

#import "AppCell.h"

@implementation AppCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (NSString *)reuseIdentifier
{
    return @"AppCell";
}

- (void)dealloc {
    [super dealloc];
}
@end
