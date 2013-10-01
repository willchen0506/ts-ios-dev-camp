//
//  SettingsViewController.m
//  GAuth
//
//  Created by Will Chen on 10/1/13.
//  Copyright (c) 2013 Vadim Shpakovski. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController {
    __weak id _constantShortcutMonitor;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.secretKeyString =[[NSUserDefaults standardUserDefaults] stringForKey:@"secret"];
        if (self.secretKeyString == nil){
            self.secretKeyString = @"";
        }
        [self.secretKey setStringValue:self.secretKeyString];
        // Checkbox will enable and disable the shortcut view
        [self.shortcutView bind:@"enabled" toObject:self withKeyPath:@"shortcutEnabled" options:nil];
    }
    return self;
}

@end
