
#import "Slingshot/SHShot.h"

%hook SHShot
- (void)setLocked:(BOOL)fp8 {
    %orig(NO);
}
%end

// @TODO: import, test with logs

%hook SHPersonOrderController

- (id)sectionConfigurationForSection:(unsigned int)fp8 {
    %log;
    return %orig;
}
- (id)_sectionControllersForSectionType:(unsigned short)fp8 {
    %log;
    return %orig;
}
- (id)initWithDataService:(id)fp8 sectionTypes:(id)fp12 {
    %log;
    return %orig;
}

%end

// #import "Slingshot/SHRecipientsTableViewController.h"

// %hook SHRecipientsTableViewController

// - (void)setRepliesThumbnailVisible:(BOOL)fp8 {
//     %orig(YES);
// }
// - (void)setStashedShotsThumbnailVisible:(BOOL)fp8 {
//     %orig(YES);
// }

// %end

// #import "Slingshot/SHPersonRowConfiguration.h"

// %hook SHPersonRowConfiguration
// - (void)setIdentifier:(id)fp8 {
//     %log;
//     if (![fp8 isEqualToString:@"SHPersonRowConfigurationIdentifierStashedShots"]) {
//         %orig(@"SHPersonRowConfigurationIdentifierStashedShots");
//     } else {
//         %orig;
//     }
// }
// - (id)initForSectionType:(unsigned short)fp8 withIdentifier:(id)fp12 title:(id)fp16 subtitle:(id)fp20 unseenShotsCount:(unsigned int)fp24 previewImage:(id)fp28 {
//     %log;
//     return %orig(0, @"SHPersonRowConfigurationIdentifierStashedShots", fp16, fp20, fp24, fp28);

// }
// - (id)initForSectionType:(unsigned short)sectionType person:(id)person unseenShotsCount:(unsigned int)shotsCount firstUnseenShot:(id)firstUnseenShot {
//     if (sectionType == 1) {
//         return %orig(0, person, shotsCount, firstUnseenShot);
//     } else {
//         return %orig;
//     }
// }

// %end
