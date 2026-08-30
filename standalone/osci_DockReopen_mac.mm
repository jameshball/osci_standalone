#include <AppKit/AppKit.h>

// Handle the Dock's reopen event without changing JUCE's application delegate or
// taking focus away from a popout when the user activates it directly.
@interface OsciStandaloneDockReopenTarget : NSObject {
@public
    juce::Component::SafePointer<juce::ResizableWindow> mainWindow;
}
- (void)handleReopen:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)reply;
- (void)applicationDidFinishLaunching:(NSNotification*)notification;
@end

@implementation OsciStandaloneDockReopenTarget
- (void)applicationDidFinishLaunching:(NSNotification*)notification {
    juce::ignoreUnused(notification);
    // AppKit installs its default Apple-event handlers during launch.
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
                                                     andSelector:@selector(handleReopen:withReplyEvent:)
                                                   forEventClass:kCoreEventClass
                                                      andEventID:kAEReopenApplication];
}

- (void)handleReopen:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)reply {
    juce::ignoreUnused(event, reply);
    if (mainWindow != nullptr) {
        [NSApp unhide:nil];
        mainWindow->setVisible(true);
        mainWindow->setMinimised(false);
        mainWindow->toFront(true);
    }
}
@end

namespace osci {

class DockReopenHandler {
public:
    explicit DockReopenHandler(juce::ResizableWindow& window) {
        target = [[OsciStandaloneDockReopenTarget alloc] init];
        target->mainWindow = &window;
        [[NSNotificationCenter defaultCenter] addObserver:target selector:@selector(applicationDidFinishLaunching:)
                                                    name:NSApplicationDidFinishLaunchingNotification object:NSApp];
    }

    ~DockReopenHandler() {
        [[NSNotificationCenter defaultCenter] removeObserver:target];
        [[NSAppleEventManager sharedAppleEventManager] removeEventHandlerForEventClass:kCoreEventClass
                                                                          andEventID:kAEReopenApplication];
        [target release];
    }

private:
    OsciStandaloneDockReopenTarget* target = nil;

    JUCE_DECLARE_NON_COPYABLE(DockReopenHandler)
};

}
