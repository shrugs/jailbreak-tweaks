
@interface SBApplication
@end

@interface SBUIController
+(SBUIController *)sharedInstance;
-(void)activateApplication:(id)app;
@end

@interface SBApplicationController
+(SBApplicationController *)sharedInstance;
-(SBApplication *)applicationWithBundleIdentifier:(NSString *)id;
@end





@interface Growlith : NSObject
- (void)restartPokemonGo;
@end

@implementation Growlith

- (void)restartPokemonGo {
  HBLogDebug(@"Restarting pokemongo...");
  SBApplication *app = [(SBApplicationController *)[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:@"com.nianticlabs.pokemongo"];
  [[%c(SBUIController) sharedInstance] activateApplication:app];
}
@end



%ctor {
  // watch for the process

  // Growlith *g = [[Growlith alloc] init];

  // [NSTimer scheduledTimerWithTimeInterval:10.0
  //              target: g
  //              selector: @selector(restartPokemonGo)
  //              userInfo: nil
  //              repeats: YES];
}
