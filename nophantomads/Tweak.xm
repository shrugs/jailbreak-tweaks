@interface MPBannerAdManager

- (id)initWithDelegate:(id)delegate;

@end


%hook MPBannerAdManager

- (id)initWithDelegate:(id)delegate
{
    NSLog(@"YOYOYOYOYOYO");

    %log;
    return %orig;
}

%end