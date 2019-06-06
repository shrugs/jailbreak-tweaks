
/*
    IMPORTS and DECLARATIONS
*/
#import <iOS/iOS8/PrivateFrameworks/BiometricKit.framework/SBUIBiometricEventMonitorDelegate.h>
#import <iOS/iOS8/PrivateFrameworks/SpringBoardUIServices.framework/SBUIBiometricEventMonitor.h>
#import <Foundation/Foundation.h>
#import <iOS/iOS8/Frameworks/Foundation.framework/NSConcreteNotification.h>
@interface SBUserAgent : NSObject
+ (id)sharedUserAgent;
- (void)undimScreen;
- (void)lockAndDimDevice;
- (bool)deviceIsLocked;
@end
#import <libactivator/libactivator.h>

/*
    DEFINES
*/
#define log(z) NSLog(@"[GLIMPSE] %@", z)

#define TouchIDFingerUp 0
#define TouchIDFingerDown 1
#define TouchIDFingerHeld 2
#define TouchIDMatched 3
#define TouchIDUnlocked 4
#define TouchIDPasscodeRequired 5
#define TouchIDPasscodeRequiredLockout 6
#define TouchIDPasscodeRequiredFingerprint 7
#define TouchIDPasscodeRequiredReboot 8
// Look into this
#define TouchIDMatchFailed 9
// #define TouchIDMatchFailed 10

typedef enum {
    GlimpseStateDimmed,
    GlimpseStateGlimpsing,
    GlimpseStateAwake
} GlimpseState;


#define GLIMPSE_ACTIVATOR_LISTENER_NAME @"com.shrugs.glimpselistener"
#define GLIMPSE_UNHOVER_DELAY 0.35
#define GLIMPSE_UNHOVER_LISTENER_DELAY 0.15


/*
    OPTIONS and GLOBALS
*/

/*
    GlimpseTouchIDController
*/

// Implementation via http://iphonedevwiki.net/index.php/BiometricKit.framework
@interface GlimpseTouchIDController : NSObject <SBUIBiometricEventMonitorDelegate, LAListener>
{
    NSTimer *unloadTimer;
    NSTimer *glimpseTimer;

    GlimpseState state;

    BOOL isMonitoring;
    BOOL previousMatchingSetting;
}

+ (id)sharedInstance;
- (void)startMonitoring;
- (void)stopMonitoring;
- (void)didUnlock;
- (void)noteReset;

@end
@implementation GlimpseTouchIDController

- (id)init
{
    self = [super init];
    if (self) {
        [self noteReset];
        [NSTimer scheduledTimerWithTimeInterval:60.0f
                                         target:self
                                       selector:@selector(logShit)
                                       userInfo:nil
                                        repeats:YES];
    }
    return self;
}

- (void)logShit
{
    log(@"Just glimpse things.");
}

// via https://github.com/Sassoty/BioTesting

+ (id)sharedInstance {
    // Setup instance for current class once
    static id sharedInstance = nil;
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        sharedInstance = [[self alloc] init];
    });
    // Provide instance
    return sharedInstance;
}


- (void)startMonitoring {
    // If already monitoring, don't start again
    if(isMonitoring) {
        return;
    }
    isMonitoring = YES;

    // Get current monitor instance so observer can be added
    SBUIBiometricEventMonitor* monitor = [%c(SBUIBiometricEventMonitor) sharedInstance];
    // Save current device matching state
    previousMatchingSetting = [monitor isMatchingEnabled];

    // Begin listening :D
    [monitor addObserver:self];
    [monitor _setMatchingEnabled:YES];
    [monitor _startMatching];

    log(@"Started monitoring");
}

- (void)stopMonitoring {
    // If already stopped, don't stop again
    if(!isMonitoring) {
        return;
    }
    isMonitoring = NO;

    // Get current monitor instance so observer can be removed
    SBUIBiometricEventMonitor* monitor = [%c(SBUIBiometricEventMonitor) sharedInstance];

    // Stop listening
    [monitor removeObserver:self];
    [monitor _setMatchingEnabled:previousMatchingSetting];

    log(@"Stopped Monitoring");
}

- (void)biometricEventMonitor:(id)monitor handleBiometricEvent:(int)event
{
    // for now, just check if the screen is locked
    // but for production, use the observer thing
    if ([[%c(SBUserAgent) sharedUserAgent] deviceIsLocked]) {
        NSLog(@"Biometric Event: %i", event);
        NSLog(@"GlimpseState: %i", state);

        switch(event) {
            case TouchIDFingerDown:

                switch (state) {
                    case GlimpseStateDimmed:
                        // if the screen is dimmed, show it and transition to glimpsing state
                        [self undimAndLoad];
                        glimpseTimer = [[NSTimer scheduledTimerWithTimeInterval:GLIMPSE_UNHOVER_DELAY
                                               target:self
                                               selector:@selector(startGlimpsing)
                                               userInfo:nil
                                               repeats:NO] retain];

                        break;
                    case GlimpseStateAwake:
                        // if the screen is in the standard awake state, just transistion to glimpsing and not looking for fingers
                        state = GlimpseStateGlimpsing;
                        break;

                    default:
                        // make compiler happy
                        break;
                }

                break;
            case TouchIDFingerUp:
                switch (state) {
                    case GlimpseStateDimmed:
                        // if we haven't undimmed, they just quickly tapped touch sensor, so call it a home button press
                        // also transistion to awake state and cancel glimpse timer
                        if (glimpseTimer && glimpseTimer != nil && [glimpseTimer respondsToSelector:@selector(invalidate)]) {
                            log(@"glimpseTimer is valid");
                            [glimpseTimer invalidate];
                            log(@"invalidated glimpseTimer");
                            glimpseTimer = nil;
                            log(@"set glimpseTimer to nil");
                        }
                        state = GlimpseStateAwake;
                        break;
                    case GlimpseStateGlimpsing:
                        // if we are glimpsing (and haven't clicked)
                        // dim the screen after waiting for the click, just in case
                        unloadTimer = [[NSTimer scheduledTimerWithTimeInterval:GLIMPSE_UNHOVER_DELAY
                                               target:self
                                               selector:@selector(dimAndUnload)
                                               userInfo:nil
                                               repeats:NO] retain];
                        break;
                    case GlimpseStateAwake:
                        // if we clicked and unhover, don't do anything
                        break;

                    default:
                        // make compiler happy
                        break;
                }
                break;
        }

    }

}

- (void)undimAndLoad
{
    [[%c(SBUserAgent) sharedUserAgent] undimScreen];
    [self loadListener];
}

- (void)startGlimpsing
{
    state = GlimpseStateGlimpsing;
}

- (void)didUnlock
{
    // if they used the sleep button or got a notification, move to awake state
    // otherwise, they used the home button, so it should be handled
    log(@"DID UNLOCK ------------");
}

- (void)dimAndUnload
{
    [[%c(SBUserAgent) sharedUserAgent] lockAndDimDevice];
    [self unloadListener];
    state = GlimpseStateDimmed;
}

- (void)noteReset
{
    // reset to initial state
    state = GlimpseStateDimmed;
    SBUIBiometricEventMonitor* monitor = [%c(SBUIBiometricEventMonitor) sharedInstance];
   [monitor _setMatchingEnabled:YES];
   [monitor _startMatching];
    log(@"DID RESET -------------");
}


- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {

    if ([[event name] isEqualToString:@"libactivator.menu.press.single"] ||
        [[event name] isEqualToString:@"libactivator.menu.press.double"]) {

        log(@"Did Click");

        switch (state) {
            case GlimpseStateGlimpsing:
                // if we are glimpsing and click the button, transfer to awake and cancel any unhover timers
                NSLog(@"unloadTimer: %@", unloadTimer);
                if (unloadTimer && unloadTimer != nil && [unloadTimer respondsToSelector:@selector(invalidate)]) {
                    log(@"unloadTimer not nil");
                    [unloadTimer invalidate];
                    log(@"invalidated timer");
                    unloadTimer = nil;
                    log(@"set timer to nil");
                }

                // log(@"about to call start matching...");
                // [monitor _startMatching];
                // log(@"called start matching");

                state = GlimpseStateAwake;
                break;

            case GlimpseStateDimmed:
                // they clicked immediately, like the normal UX
                state = GlimpseStateAwake;
                break;

            default:
                // make compiler happy
                break;
        }
    }

}


- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {
    // @TODO(Shrugs) figure out the correct way to do this
    // do we even need to worry about this?
    NSLog(@"[GLIMPSE] Should dismiss listener");
}

- (void)loadListener
{
    if ([[LAActivator sharedInstance] isRunningInsideSpringBoard]) {
        // assign listener
        [[LAActivator sharedInstance] registerListener:self forName:GLIMPSE_ACTIVATOR_LISTENER_NAME];
        // bind to events
        [LASharedActivator assignEvent:[LAEvent eventWithName:@"libactivator.menu.press.single"] toListenerWithName:GLIMPSE_ACTIVATOR_LISTENER_NAME];
        [LASharedActivator assignEvent:[LAEvent eventWithName:@"libactivator.menu.press.double"] toListenerWithName:GLIMPSE_ACTIVATOR_LISTENER_NAME];
    }
}

- (void)unloadListener
{
    // - (void)removeListenerAssignment:(NSString *)listenerName fromEvent:(LAEvent *)event;
    if ([[LAActivator sharedInstance] isRunningInsideSpringBoard]) {
        // unbind from events
        [[LAActivator sharedInstance] removeListenerAssignment:GLIMPSE_ACTIVATOR_LISTENER_NAME fromEvent:[LAEvent eventWithName:@"libactivator.menu.press.single"]];
        [[LAActivator sharedInstance] removeListenerAssignment:GLIMPSE_ACTIVATOR_LISTENER_NAME fromEvent:[LAEvent eventWithName:@"libactivator.menu.press.double"]];
        // hide listener
        [[LAActivator sharedInstance] unregisterListenerWithName:GLIMPSE_ACTIVATOR_LISTENER_NAME];
    }
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
    return @"Glimpse";
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
    return @"Glimpse Stuff";
}
- (NSArray *)activator:(LAActivator *)activator requiresCompatibleEventModesForListenerWithName:(NSString *)listenerName {
    return [NSArray arrayWithObjects:@"lockscreen", nil];
}

@end


%hook SBUIBiometricEventMonitor
- (void)noteScreenWillTurnOn
{
    %orig;

    // init glimpse
    [[GlimpseTouchIDController sharedInstance] startMonitoring];
}

- (void)noteScreenWillTurnOff
{
    %log;
    [[GlimpseTouchIDController sharedInstance] noteReset];
    %orig;
}

- (void)setMatchingDisabled:(bool)arg1 requester:(id)arg2
{
    // %log;
    %orig;
}
- (void)_setMatchingEnabled:(bool)arg1
{
    %log;
    %orig;
}
- (void)_stopMatching
{
    %log;
    if (![[%c(SBUserAgent) sharedUserAgent] deviceIsLocked]) {
        // if device isn't locked, do whatever
        %orig;
    }
}

- (void)_stopFingerDetection
{
    %log;
    if (![[%c(SBUserAgent) sharedUserAgent] deviceIsLocked]) {
        // if device isn't locked, do whatever
        %orig;
    }
}

- (void)_startMatching{
    %log;
    %orig;
}

- (void)_startFingerDetection
{
    %log;
    %orig;
}
- (void)disableMatchingForPasscodeView:(id)arg1{%log(); %orig;}
- (void)enableMatchingForPasscodeView:(id)arg1{%log(); %orig;}

%end

%hook SBUIController
- (void)_deviceLockStateChanged:(NSConcreteNotification *)notification
{
    if ([[[notification userInfo] valueForKey:@"kSBNotificationKeyState"] boolValue]) {
        // is now locked
        [[GlimpseTouchIDController sharedInstance] noteReset];
    } else {
        [[GlimpseTouchIDController sharedInstance] didUnlock];
    }
    %orig;
}
%end

/*
    PREFERENCES
*/

static void glimpseUpdatePreferences() {
    log(@"Would update preferences here.");
}

static void reloadPrefsNotification(CFNotificationCenterRef center,
                    void *observer,
                    CFStringRef name,
                    const void *object,
                    CFDictionaryRef userInfo) {
    glimpseUpdatePreferences();
}


%ctor {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    %init;

    CFNotificationCenterRef reload = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(reload, NULL, &reloadPrefsNotification, CFSTR("com.shrugs.glimpse/reload"), NULL, 0);
    glimpseUpdatePreferences();
    [pool release];
}