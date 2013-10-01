@class MASShortcutView;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, assign) IBOutlet NSWindow *window;
@property (nonatomic, weak) IBOutlet MASShortcutView *shortcutView;
@property (nonatomic, getter = isShortcutEnabled) BOOL shortcutEnabled;
@property (nonatomic, getter = isConstantShortcutEnabled) BOOL constantShortcutEnabled;
@property (weak) IBOutlet NSSecureTextField *secretKey;
@property (nonatomic, strong) NSString *secretKeyString;

@end