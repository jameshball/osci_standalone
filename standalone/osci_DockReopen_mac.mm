#include <AppKit/AppKit.h>

// Clicking the Dock icon can otherwise bring forward only the visualiser popout,
// leaving the main standalone window hidden, minimised or behind other windows.
// Handle the reopen event to restore and focus the main window instead. Unlike
// handling every app activation, this leaves direct clicks on the popout alone
// and does not require replacing JUCE's application delegate.
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
