#import "AppDelegate.h"

@implementation AppDelegate

#pragma mark -
- (IBAction)showMenu:(id)sender {
    self.settingsWC = [[SettingsWindowController alloc] initWithWindowNibName:@"SettingsWindowController"];
    [self.settingsWC showWindow:self];
}
- (IBAction)exitApp:(id)sender {
    exit(0);
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] ;
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setImage:[NSImage imageNamed:@"ts.png"]];
    [self.statusItem setHighlightMode:YES];
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return NO;
}

@end
