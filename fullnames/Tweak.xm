
#import <iOS7/PrivateFrameworks/IMCore/IMPerson.h>

%hook IMPerson

-(NSString *)displayName {
    NSString *r = %orig;
    self.firstName = r;
    return r;
}

// -(NSString *)firstName {
//     return self.displayName;
// }

%end

