
// #import <iOS/iOS8/PrivateFrameworks/SpringBoardUIServices.framework/SBUIBiometricEventMonitor.h>

@interface SBUIBiometricEventMonitor : NSObject  {
    // BiometricKit *_biometricKit;
    // <SBUIBiometricEventMonitorDelegate> *_delegate;
    // NSHashTable *_observers;
    // unsigned long long _lastEvent;
    // NSCountedSet *_matchingDisabledRequesters;
    // NSCountedSet *_fingerDetectRequesters;
    // NSCountedSet *_activePasscodeViews;
    // bool_matchingEnabled;
    // bool_fingerDetectionEnabled;
    // bool_screenIsOff;
    // bool_deviceLocked;
    // bool_lockScreenTopmost;
    // bool_shouldSendFingerOffNotification;
}

+ (id)sharedInstance;

- (void)_updateHandlersForEvent:(unsigned long long)arg1;
- (void)noteScreenWillTurnOn;
- (void)noteScreenDidTurnOff;
- (void)noteScreenWillTurnOff;
- (void)_setDeviceLocked:(bool)arg1;
- (void)setLockScreenTopmost:(bool)arg1;
- (void)setFingerDetectEnabled:(bool)arg1 requester:(id)arg2;
- (void)setMatchingDisabled:(bool)arg1 requester:(id)arg2;
- (id)stringForEvent:(unsigned long long)arg1;
- (void)_setMatchingEnabled:(bool)arg1;
- (void)_stopMatching;
- (void)_startMatching;
- (void)_stopFingerDetection;
- (void)_startFingerDetection;
- (void)_reevaluateMatching;
- (void)_profileSettingsChanged:(id)arg1;
- (bool)hasEnrolledIdentities;
- (bool)isMatchingEnabled;
- (unsigned long long)lockoutState;
- (void)disableMatchingForPasscodeView:(id)arg1;
- (void)enableMatchingForPasscodeView:(id)arg1;
- (id)init;
- (void)setDelegate:(id)arg1;
- (void)addObserver:(id)arg1;
- (void)removeObserver:(id)arg1;
- (id)delegate;
- (void)dealloc;

@end

%hook SBUIBiometricEventMonitor
- (bool)isMatchingEnabled { %log; bool  r = %orig; NSLog(@" = %d", r); return r; }
- (unsigned long long )lockoutState { %log; unsigned long long  r = %orig; NSLog(@" = %llu", r); return r; }
+ (id)sharedInstance { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (void)_updateHandlersForEvent:(unsigned long long)arg1 { %log; %orig; }
- (void)noteScreenWillTurnOn { %log; %orig; }
- (void)noteScreenDidTurnOff { %log; %orig; }
- (void)noteScreenWillTurnOff { %log; %orig; }
- (void)_setDeviceLocked:(bool)arg1 { %log; %orig; }
- (void)setLockScreenTopmost:(bool)arg1 { %log; %orig; }
- (void)setFingerDetectEnabled:(bool)arg1 requester:(id)arg2 { %log; %orig; }
- (void)setMatchingDisabled:(bool)arg1 requester:(id)arg2 { %log; %orig; }
- (id)stringForEvent:(unsigned long long)arg1 { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (void)_setMatchingEnabled:(bool)arg1 { %log; %orig; }
- (void)_stopMatching { %log; %orig; }
- (void)_startMatching { %log; %orig; }
- (void)_stopFingerDetection { %log; %orig; }
- (void)_startFingerDetection { %log; %orig; }
- (void)_reevaluateMatching { %log; %orig; }
- (void)_profileSettingsChanged:(id)arg1 { %log; %orig; }
- (bool)hasEnrolledIdentities { %log; bool r = %orig; NSLog(@" = %d", r); return r; }
- (void)disableMatchingForPasscodeView:(id)arg1 { %log; %orig; }
- (void)enableMatchingForPasscodeView:(id)arg1 { %log; %orig; }
- (id)init { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (void)dealloc { %log; %orig; }
%end