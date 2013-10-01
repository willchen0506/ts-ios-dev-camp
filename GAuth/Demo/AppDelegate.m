#import "AppDelegate.h"
#import "MASShortcutView.h"
#import "MASShortcutView+UserDefaults.h"
#import "MASShortcut+UserDefaults.h"
#import "MASShortcut+Monitoring.h"
#import "AGTotp.h"
#import "AGBase32.h"
#import "AGClock.h"


NSString *const MASPreferenceKeyShortcut = @"MASDemoShortcut";
NSString *const MASPreferenceKeyShortcutEnabled = @"MASDemoShortcutEnabled";
NSString *const MASPreferenceKeyConstantShortcutEnabled = @"MASDemoConstantShortcutEnabled";

static NSString *const kOTPAuthScheme = @"otpauth";
static NSString *const kTOTPAuthScheme = @"totp";
static NSString *const kOTPService = @"com.google.otp.authentication";
// These are keys in the otpauth:// query string.
static NSString *const kQueryAlgorithmKey = @"algorithm";
static NSString *const kQuerySecretKey = @"secret";
static NSString *const kQueryCounterKey = @"counter";
static NSString *const kQueryDigitsKey = @"digits";
static NSString *const kQueryPeriodKey = @"period";

static NSString *const kBase32Charset = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
static NSString *const kBase32Synonyms =
@"AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz";
static NSString *const kBase32Sep = @" -";

static const NSTimeInterval kTOTPDefaultSecondsBeforeChange = 5;
NSString *const OTPAuthURLWillGenerateNewOTPWarningNotification
= @"OTPAuthURLWillGenerateNewOTPWarningNotification";
NSString *const OTPAuthURLDidGenerateNewOTPNotification
= @"OTPAuthURLDidGenerateNewOTPNotification";
NSString *const OTPAuthURLSecondsBeforeNewOTPKey
= @"OTPAuthURLSecondsBeforeNewOTP";


@implementation AppDelegate {
    __weak id _constantShortcutMonitor;
}

@synthesize window = _window;
@synthesize shortcutView = _shortcutView;

#pragma mark -
- (IBAction)showMenu:(id)sender {
    NSLog(@"123");
}
- (IBAction)exitApp:(id)sender {
    exit(0);
}

- (void)awakeFromNib
{

    [super awakeFromNib];
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] ;
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setTitle:@"G"];
    [self.statusItem setHighlightMode:YES];
    
//    self.secretKeyString =[[NSUserDefaults standardUserDefaults] stringForKey:@"secret"];
//    if (self.secretKeyString == nil){
//        self.secretKeyString = @"";
//    }
//    [self.secretKey setStringValue:self.secretKeyString];
//    // Checkbox will enable and disable the shortcut view
//    [self.shortcutView bind:@"enabled" toObject:self withKeyPath:@"shortcutEnabled" options:nil];
}

- (void)dealloc
{
    // Cleanup
    [self.shortcutView unbind:@"enabled"];
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Uncomment the following lines to make Command-Shift-D the default shortcut
//    MASShortcut *defaultShortcut = [MASShortcut shortcutWithKeyCode:0x2 modifierFlags:NSCommandKeyMask|NSShiftKeyMask];
//    [MASShortcut setGlobalShortcut:defaultShortcut forUserDefaultsKey:MASPreferenceKeyShortcut];

    // Shortcut view will follow and modify user preferences automatically
    self.shortcutView.associatedUserDefaultsKey = MASPreferenceKeyShortcut;

    // Activate the global keyboard shortcut if it was enabled last time
    [self resetShortcutRegistration];

    // Activate the shortcut Command-F1 if it was enabled
    [self resetConstantShortcutRegistration];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

#pragma mark - Custom shortcut

- (BOOL)isShortcutEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:MASPreferenceKeyShortcutEnabled];
}

- (void)setShortcutEnabled:(BOOL)enabled
{
    if (self.shortcutEnabled != enabled) {
        [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:MASPreferenceKeyShortcutEnabled];
        [self resetShortcutRegistration];
    }
}

- (void)resetShortcutRegistration
{
    if (self.shortcutEnabled) {
        [MASShortcut registerGlobalShortcutWithUserDefaultsKey:MASPreferenceKeyShortcut handler:^{
            AGTotp *agtotp = [[AGTotp alloc] initWithSecret:[AGBase32 base32Decode:self.secretKeyString]];
            NSString *otp = [agtotp now];
            NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
            [pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
            [pasteBoard setString:otp forType:NSStringPboardType];
        }];
    }
    else {
        [MASShortcut unregisterGlobalShortcutWithUserDefaultsKey:MASPreferenceKeyShortcut];
    }
}
- (IBAction)enterSecretKey:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:self.secretKey.stringValue forKey:@"secret"];
    NSAlert *alert = [NSAlert alertWithMessageText:@"Secret Saved!" defaultButton:@"OK" alternateButton:nil       otherButton:nil informativeTextWithFormat:@""];
    [alert runModal];
}

#pragma mark - Constant shortcut

- (BOOL)isConstantShortcutEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:MASPreferenceKeyConstantShortcutEnabled];
}

- (void)setConstantShortcutEnabled:(BOOL)enabled
{
    if (self.constantShortcutEnabled != enabled) {
        [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:MASPreferenceKeyConstantShortcutEnabled];
        [self resetConstantShortcutRegistration];
    }
}

- (void)resetConstantShortcutRegistration

{
    if (self.constantShortcutEnabled) {
        MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:kVK_F2 modifierFlags:NSCommandKeyMask];
        _constantShortcutMonitor = [MASShortcut addGlobalHotkeyMonitorWithShortcut:shortcut handler:^{
            [[NSAlert alertWithMessageText:NSLocalizedString(@"⌘F2 has been pressed.", @"Alert message for constant shortcut")
                             defaultButton:NSLocalizedString(@"OK", @"Default button for the alert on constant shortcut")
                           alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
        }];
    }
    else {
        [MASShortcut removeGlobalHotkeyMonitor:_constantShortcutMonitor];
    }
}

@end
