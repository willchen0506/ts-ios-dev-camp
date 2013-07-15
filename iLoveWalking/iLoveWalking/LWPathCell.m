//
//  LWPathCell.m
//  iLoveWalking
//
//  Created by Will Chen on 7/14/13.
//  Copyright (c) 2013 TapSense. All rights reserved.
//

#import "LWPathCell.h"

@implementation LWPathCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (NSString *)reuseIdentifier
{
    return @"LWPathCell";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
