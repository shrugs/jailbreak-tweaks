#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
// #import <Preferences/PSSwitchCell.h>
#import <UIKit/UIkit.h>
#import <AppList/AppList.h>

static CFNotificationCenterRef darwinNotifyCenter = CFNotificationCenterGetDarwinNotifyCenter();
#define StacksContentsPath @"/var/mobile/Library/Preferences/com.mattcmultimedia.stacks.stacksContents.plist"

@interface stacksSettingsListController: PSListController <UIAlertViewDelegate> {
}

- (NSString *)valueForSpecifier:(PSSpecifier *)specifier;
- (void)setPreferenceValue:(id)value specifier:(id)specifier;
- (void)donationButton:(id)arg;
- (void)reloadStacks:(id)arg;
- (void)resetToDefaults:(id)arg;
- (void)submitFeedback:(id)arg;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@implementation stacksSettingsListController



- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"stacksSettings" target:self] retain];
	}
	return _specifiers;
}

- (NSString *)valueForSpecifier:(PSSpecifier *)specifier
{
    //NSLog(@"SPECIFIER: %@", specifier);
    return @"0.3";
}

- (void)setPreferenceValue:(id)value specifier:(id)specifier {
    [super setPreferenceValue:value specifier:specifier];

    NSString *notification = [specifier propertyForKey:@"postNotification"];
    if(notification) {
        CFNotificationCenterPostNotification(darwinNotifyCenter, (CFStringRef)notification, NULL, NULL, true);
    }
}

- (void)donationButton:(id)arg {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=mattcmultimedia%40gmail%2ecom&lc=US&item_name=MattCMultimedia%20Development%20%3a%29&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted"]];
}

- (void)submitFeedback:(id)arg {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:mattcmultimedia@gmail.com?subject=stacks%20Beta%20testing%20feedback!&body=Bugs,%20Good%20Things,%20Feature%20Requests,%20and%20Would%20I%20pay%20$0.99%20for%20this?(Y/N)"]];
    // Bugs,%20Good%20Things,%20Feature%20Requests,%20and%20Would%20I%20pay%20$0.99%20for%20this?(Y/N)
}


- (void)reloadStacks:(id)arg
{
    CFNotificationCenterPostNotification(darwinNotifyCenter, (CFStringRef)@"com.mattcmultimedia.stacks/reloadStacks", NULL, NULL, true);
}

- (void)resetToDefaults:(id)arg
{
    //NSLog(@"WOULD RESET stacks DEFAULTS HERE");
    NSDictionary *resetDict = [[NSDictionary alloc] init];
    [resetDict writeToFile:StacksContentsPath atomically:YES];
    //NSLog(@"overwrite suceeded? %i", succeed);
    [resetDict writeToFile:@"/var/mobile/Library/Preferences/com.mattcmultimedia.stacks.plist" atomically:YES];
    //NSLog(@"overwrite suceeded? %i", succeed);
    [resetDict release];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"stacks"
        message:[NSString stringWithFormat:@"%@", @"stacks must respring to reset to Default. Respring Now?"]
        delegate:self
        cancelButtonTitle:@"Nahh."
        otherButtonTitles:@"Okie dokie!", nil];
    [alert show];
    [alert release];

    //create an NSDictionary with the objects as defaults
    //write to PrefPath file

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //Code for OK button
        //NSLog(@"NAHH BUTTON CLICKED");
    }
    if (buttonIndex == 1)
    {
        //Code for respring button
        //NSLog(@"SHOULD KILLALL");
        float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (sysVer > 6.0) {
            system("killall backboardd");
        } else {
            system("killall -9 SpringBoard");
        }
    }

}


@end


@interface stacksAestheticsListController: PSListController {
}



- (void)setPreferenceValue:(id)value specifier:(id)specifier;
// - (void)donationButton:(id)arg;
// - (void)reloadStacks:(id)arg;

@end

@implementation stacksAestheticsListController


- (void)setPreferenceValue:(id)value specifier:(id)specifier {
    [super setPreferenceValue:value specifier:specifier];

    NSString *notification = [specifier propertyForKey:@"postNotification"];
    if(notification) {
        CFNotificationCenterPostNotification(darwinNotifyCenter, (CFStringRef)notification, NULL, NULL, true);
    }
}

@end





@interface stacksExperienceListController: PSListController {
}



- (void)setPreferenceValue:(id)value specifier:(id)specifier;
// - (void)donationButton:(id)arg;
// - (void)reloadStacks:(id)arg;

@end

@implementation stacksExperienceListController


- (void)setPreferenceValue:(id)value specifier:(id)specifier {
    [super setPreferenceValue:value specifier:specifier];

    NSString *notification = [specifier propertyForKey:@"postNotification"];
    if(notification) {
        CFNotificationCenterPostNotification(darwinNotifyCenter, (CFStringRef)notification, NULL, NULL, true);
    }
}

@end






@interface stacksExperimentalListController: PSListController {
}



- (void)setPreferenceValue:(id)value specifier:(id)specifier;
// - (void)donationButton:(id)arg;
// - (void)reloadStacks:(id)arg;

@end

@implementation stacksExperimentalListController


- (void)setPreferenceValue:(id)value specifier:(id)specifier {
    [super setPreferenceValue:value specifier:specifier];

    NSString *notification = [specifier propertyForKey:@"postNotification"];
    if(notification) {
        CFNotificationCenterPostNotification(darwinNotifyCenter, (CFStringRef)notification, NULL, NULL, true);
    }
}

@end



//AESTHETICS


@interface stacksSpacingSettingsListController: PSListController {
}



- (void)setPreferenceValue:(id)value specifier:(id)specifier;
// - (void)donationButton:(id)arg;
// - (void)reloadStacks:(id)arg;

@end

@implementation stacksSpacingSettingsListController


- (void)setPreferenceValue:(id)value specifier:(id)specifier {
    [super setPreferenceValue:value specifier:specifier];

    NSString *notification = [specifier propertyForKey:@"postNotification"];
    if(notification) {
        CFNotificationCenterPostNotification(darwinNotifyCenter, (CFStringRef)notification, NULL, NULL, true);
    }
}

@end

@interface stacksDimSpringBoardListController: PSListController {
}



- (void)setPreferenceValue:(id)value specifier:(id)specifier;
// - (void)donationButton:(id)arg;
// - (void)reloadStacks:(id)arg;

@end

@implementation stacksDimSpringBoardListController


- (void)setPreferenceValue:(id)value specifier:(id)specifier {
    [super setPreferenceValue:value specifier:specifier];

    NSString *notification = [specifier propertyForKey:@"postNotification"];
    if(notification) {
        CFNotificationCenterPostNotification(darwinNotifyCenter, (CFStringRef)notification, NULL, NULL, true);
    }
}

@end


@interface stacksCurveSettingsListController: PSListController {
}



- (void)setPreferenceValue:(id)value specifier:(id)specifier;
// - (void)donationButton:(id)arg;
// - (void)reloadStacks:(id)arg;

@end

@implementation stacksCurveSettingsListController


- (void)setPreferenceValue:(id)value specifier:(id)specifier {
    [super setPreferenceValue:value specifier:specifier];

    NSString *notification = [specifier propertyForKey:@"postNotification"];
    if(notification) {
        CFNotificationCenterPostNotification(darwinNotifyCenter, (CFStringRef)notification, NULL, NULL, true);
    }
}

@end


@interface stacksBackgroundPropertiesListController: PSListController {
}



- (void)setPreferenceValue:(id)value specifier:(id)specifier;
// - (void)donationButton:(id)arg;
// - (void)reloadStacks:(id)arg;

@end

@implementation stacksBackgroundPropertiesListController


- (void)setPreferenceValue:(id)value specifier:(id)specifier {
    [super setPreferenceValue:value specifier:specifier];

    NSString *notification = [specifier propertyForKey:@"postNotification"];
    if(notification) {
        CFNotificationCenterPostNotification(darwinNotifyCenter, (CFStringRef)notification, NULL, NULL, true);
    }
}

@end


//Experience


@interface stacksAnimationSettingsListController: PSListController {
}



- (void)setPreferenceValue:(id)value specifier:(id)specifier;
// - (void)donationButton:(id)arg;
// - (void)reloadStacks:(id)arg;

@end

@implementation stacksAnimationSettingsListController


- (void)setPreferenceValue:(id)value specifier:(id)specifier {
    [super setPreferenceValue:value specifier:specifier];

    NSString *notification = [specifier propertyForKey:@"postNotification"];
    if(notification) {
        CFNotificationCenterPostNotification(darwinNotifyCenter, (CFStringRef)notification, NULL, NULL, true);
    }
}

@end

@interface stacksSelectedIconPropertiesListController: PSListController {
}



- (void)setPreferenceValue:(id)value specifier:(id)specifier;
// - (void)donationButton:(id)arg;
// - (void)reloadStacks:(id)arg;

@end

@implementation stacksSelectedIconPropertiesListController


- (void)setPreferenceValue:(id)value specifier:(id)specifier {
    [super setPreferenceValue:value specifier:specifier];

    NSString *notification = [specifier propertyForKey:@"postNotification"];
    if(notification) {
        CFNotificationCenterPostNotification(darwinNotifyCenter, (CFStringRef)notification, NULL, NULL, true);
    }
}

@end

@interface stacksResponsivenessListController: PSListController {
}



- (void)setPreferenceValue:(id)value specifier:(id)specifier;
// - (void)donationButton:(id)arg;
// - (void)reloadStacks:(id)arg;

@end

@implementation stacksResponsivenessListController


- (void)setPreferenceValue:(id)value specifier:(id)specifier {
    [super setPreferenceValue:value specifier:specifier];

    NSString *notification = [specifier propertyForKey:@"postNotification"];
    if(notification) {
        CFNotificationCenterPostNotification(darwinNotifyCenter, (CFStringRef)notification, NULL, NULL, true);
    }
}

@end