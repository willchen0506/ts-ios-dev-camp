#import "SettingsWindowController.h"

@class MASShortcutView;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) IBOutlet NSMenu *statusMenu;
@property (nonatomic, strong) NSStatusItem * statusItem;
@property (nonatomic, strong) SettingsWindowController *settingsWC;

@end
