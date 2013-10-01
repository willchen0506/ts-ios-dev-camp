//
//  SettingsViewController.h
//  GAuth
//
//  Created by Will Chen on 10/1/13.
//  Copyright (c) 2013 Vadim Shpakovski. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASShortcutView.h"
#import "MASShortcutView+UserDefaults.h"
#import "MASShortcut+UserDefaults.h"
#import "MASShortcut+Monitoring.h"
#import "AGTotp.h"
#import "AGBase32.h"
#import "AGClock.h"

@interface SettingsViewController : NSViewController
@property (nonatomic, assign) IBOutlet NSWindow *window;
@property (nonatomic, weak) IBOutlet MASShortcutView *shortcutView;
@property (nonatomic, getter = isShortcutEnabled) BOOL shortcutEnabled;
@property (nonatomic, getter = isConstantShortcutEnabled) BOOL constantShortcutEnabled;
@property (weak) IBOutlet NSSecureTextField *secretKey;
@property (nonatomic, strong) NSString *secretKeyString;
@end
