//
//  SettingsWindowController.h
//  GAuth
//
//  Created by Will Chen on 10/1/13.
//  Copyright (c) 2013 Vadim Shpakovski. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASShortcutView+UserDefaults.h"

@interface SettingsWindowController : NSWindowController

@property (nonatomic, weak) IBOutlet MASShortcutView *shortcutView;
@property (nonatomic, getter = isShortcutEnabled) BOOL shortcutEnabled;
@property (nonatomic, getter = isConstantShortcutEnabled) BOOL constantShortcutEnabled;
@property (weak) IBOutlet NSSecureTextField *secretKey;
@property (nonatomic, strong) NSString *secretKeyString;

@end
