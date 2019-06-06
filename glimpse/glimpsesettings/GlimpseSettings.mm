#import <iOS/iOS8/PrivateFrameworks/Preferences.framework/PSListController.h>

@interface GlimpseSettingsListController: PSListController {
}
@end

@implementation GlimpseSettingsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"GlimpseSettings" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc
