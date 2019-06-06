
#import <iOS/iOS7/PrivateFrameworks/ChatKit/CKTranscriptController.h>
#import <iOS/iOS7/PrivateFrameworks/ChatKit/CKTranscriptCollectionView.h>
#import <iOS/iOS7/PrivateFrameworks/ChatKit/CKTranscriptCollectionViewController.h>
#import <iOS/iOS7/PrivateFrameworks/ChatKit/CKGradientReferenceView.h>
#import <iOS/iOS7/PrivateFrameworks/ChatKit/CKConversationList.h>
#import <iOS/iOS7/PrivateFrameworks/ChatKit/CKConversationListController.h>
#import <iOS/iOS7/PrivateFrameworks/ChatKit/CKTranscriptData.h>
// PREFERENCES
#define PrefPath [[@"~" stringByExpandingTildeInPath] stringByAppendingPathComponent:@"Library/Preferences/com.shrugs.messageswiper7.plist"]

static BOOL globalEnable = YES;

static NSMutableArray *convos;
static NSMutableArray *transcriptControllers;
static UIScrollView *scrollView;
static int currentTranscript = 0;
static UINavigationController *theNavigationController;
static CKGradientReferenceView *theBackPlacard;





// Make sure the data source for the collectionView is being set correctly
// new plan is to create multiple CKTranscriptController and then have each of them take precedence after swiping.
// every time we create a CKTranscriptController, move it's collectionViewController 's view to the UIScrollView in its correct place


// @TODO(Shrugs) get base functionality of navigation bar initialization working.
// create a small tweak that replaces any instantiated CKTranscriptController with a custom one to see if it inits correctly.

// @TODO(Shrugs) fix indexes and shit















@interface CKTranscriptController (MessageSwiper7)

- (int)thisIndex;
- (void)setThisIndex:(int)i;
- (BOOL)isMS7;
- (void)setIsMS7:(BOOL)i;
+ (id)initWithIndex:(int)i;
@end

@implementation CKTranscriptController (MessageSwiper7)

static int thisIndex;
static BOOL isMS7 = NO;

+ (CKTranscriptController *)initWithIndex:(int)i
{
    CKTranscriptController *thing = [[[CKTranscriptController alloc] initWithNavigationController:theNavigationController] retain];
    if (thing) {
        // @TODO(Shrugs) do special stuff here
        [thing setThisIndex:i];
        [thing setIsMS7:YES];
    }
    return thing;
}

- (int)thisIndex
{
    return thisIndex;
}
- (void)setThisIndex:(int)i
{
    thisIndex = i;
}

- (BOOL)isMS7
{
    return isMS7;
}
- (void)setIsMS7:(BOOL)i
{
    isMS7 = i;
}

@end










// @TODO(Shrugs) amke this a subclass instead of a category
@interface UIScrollView (MessageSwiper7)
- (int)currentPage;
- (void)addTranscript:(CKTranscriptController *)vc;
- (void)jumpToIndex:(int)i;
@end
@implementation UIScrollView (MessageSwiper7)
- (int)currentPage {
    return round(self.contentOffset.x / self.frame.size.width);
}
- (void)addTranscript:(CKTranscriptController *)tc
{

    // get convo index
    int i = [tc thisIndex];
    // create frame based on that index
    CKTranscriptCollectionView *collectionView = tc.collectionViewController.collectionView;
    CGRect f = collectionView.frame;
    f.origin.x = collectionView.frame.size.width * i;
    collectionView.frame = f;
    [collectionView removeFromSuperview];
    [self addSubview: collectionView];
    NSLog(@"index: %i", i);
    NSLog(@"collectionView: %@", collectionView);
    NSLog(@"transcriptController: %@", tc);




}
- (void)jumpToIndex:(int)i
{
    CGRect f = self.frame;
    f.origin.x = self.frame.size.width * i;
    [self scrollRectToVisible:f animated:NO];
}
@end








@interface MS7ScrollViewDelegate : NSObject <UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;
- (CKConversation *)getLeftConvoWithIndex:(int)i;
- (CKConversation *)getRightConvoWithIndex:(int)i;
+ (MS7ScrollViewDelegate *)sharedScrollViewDelegate;
@end

@implementation MS7ScrollViewDelegate

static MS7ScrollViewDelegate *scrollViewDelegate;

+ (MS7ScrollViewDelegate *)sharedScrollViewDelegate
{
    if (scrollViewDelegate == nil) {
        scrollViewDelegate = [[MS7ScrollViewDelegate alloc] init];
    }
    return scrollViewDelegate;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    // http://stackoverflow.com/a/1857162/2922265
    //ensure that the end of scroll is fired.
    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:scrollView afterDelay:0.1];


    float fractionalPage = scrollView.contentOffset.x / scrollView.frame.size.width;
    int lowerNumber = floor(fractionalPage);
    if (lowerNumber <= -1) {
        lowerNumber = 0;
    }
    int upperNumber = lowerNumber + 1;
    if (upperNumber >= [convos count]) {
        upperNumber = [convos count] -1;
    }
    int thisPage = [scrollView currentPage];

    if ([[transcriptControllers objectAtIndex:lowerNumber] isEqual:[NSNull null]]) {
        // if we need one to the left
        CKConversation *nextConvo = [self getLeftConvoWithIndex:thisPage];
        if (nextConvo != nil) {
            NSLog(@"create LEFT: %i", lowerNumber);
            CKTranscriptController *tempController = [CKTranscriptController initWithIndex:lowerNumber];
            [transcriptControllers replaceObjectAtIndex:lowerNumber withObject: tempController];
            // CKTranscriptCollectionViewController *tempCVC = [[CKTranscriptCollectionViewController alloc] initWithConversation:nextConvo];
            // [tempCVC setTranscriptData:[[CKTranscriptData alloc] initWithConversation:nextConvo]];
            // [tempCVC setCurrentPage:lowerNumber];
            [scrollView addTranscript: tempController];
            // [transcriptControllers replaceObjectAtIndex:lowerNumber withObject: tempCVC];
        }
    }
    if ([[transcriptControllers objectAtIndex:upperNumber] isEqual:[NSNull null]]) {
        CKConversation *nextConvo = [self getRightConvoWithIndex:thisPage];
        if (nextConvo != nil) {
            NSLog(@"create RIGHT: %i", upperNumber);
            CKTranscriptController *tempController = [CKTranscriptController initWithIndex:upperNumber];
            [transcriptControllers replaceObjectAtIndex:upperNumber withObject: tempController];
            // CKTranscriptCollectionViewController *tempCVC = [[CKTranscriptCollectionViewController alloc] initWithConversation:nextConvo];
            // [tempCVC setTranscriptData:[[CKTranscriptData alloc] initWithConversation:nextConvo]];
            // [tempCVC setCurrentPage:upperNumber];
            [scrollView addTranscript: tempController];
            // [transcriptControllers replaceObjectAtIndex:upperNumber withObject: tempCVC];
        }
    }

}
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    currentTranscript = [scrollView currentPage];

    // [theNavigationController setViewControllers:[NSArray arrayWithObjects: [transcriptControllers objectAtIndex:[scrollView currentPage]], nil] animated: NO];
}

- (CKConversation *)getLeftConvoWithIndex:(int)i {
    if (i <= 0) {
        return nil;
    }

    return [convos objectAtIndex:i-1];
}
- (CKConversation *)getRightConvoWithIndex:(int)i {
    if (i >= [convos count] - 1) {
        return nil;
    }

    return [convos objectAtIndex:i+1];
}

@end
































%group MessagesiOS7


%hook CKTranscriptController

- (id)initWithNavigationController:(id)arg1 {
    self = %orig;
    theNavigationController = arg1;
    if (self) {
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    if (convos == nil) {
        convos = [[%c(CKConversationList) sharedConversationList] conversations];

        transcriptControllers = [[NSMutableArray alloc] initWithCapacity:[convos count]];
        for (int i = 0; i < [convos count]; ++i) {
            [transcriptControllers addObject:[NSNull null]];
        }
    }
    if (theBackPlacard == nil) {
        theBackPlacard = (CKGradientReferenceView *)self.view;
    }
    if (scrollView == nil) {
        // set up everything just once
        scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * [convos count], scrollView.frame.size.height);

        // @TODO(Shrugs) remove line below this one
        scrollView.backgroundColor = [UIColor redColor];

        scrollView.pagingEnabled = YES;
        scrollView.delegate = [MS7ScrollViewDelegate sharedScrollViewDelegate];
        scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;

        [theBackPlacard addSubview: scrollView];
        [theBackPlacard bringSubviewToFront: scrollView];

    }
    NSLog(@"%@", [self isMS7]?@"YES":@"NO");
    if (![self isMS7]) {
        int thisPage = [convos indexOfObject:[self conversation]];
        [self setThisIndex:thisPage];
        currentTranscript = thisPage;

        [scrollView addTranscript:self];
        // @TOOD(Shrugs) or if there's only one controller?
        [scrollView jumpToIndex:thisPage];
    }

    [scrollView addTranscript:self];
    NSLog(@"self.view: %@", self.view);



}


- (void)didRotateFromInterfaceOrientation:(long long)arg1
{
    %orig;
    // @TODO(Shrugs) handle rotation
    // scrollView.frame = [self gradientReferenceView].frame;
    // scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * [convos count], scrollView.frame.size.height);
    // for (int i = 0; i < [convos count]; i++) {
    //     if (![[transcriptControllers objectAtIndex:i] isEqual: [NSNull null]]) {
    //         UIView *v = ((CKTranscriptCollectionViewController *)[transcriptControllers objectAtIndex:i]).view;
    //         CGRect f = scrollView.frame;
    //         f.origin.x = scrollView.frame.size.width * i;
    //         v.frame = f;
    //     }
    // }
    // [scrollView jumpToIndex:currentTranscript];
}

// @TODO(Shrugs) handle resume and jumping to correct index

%end

// %hook CKTranscriptCollectionViewController

// - (void)viewDidAppear:(BOOL)animated
// {


// }

// - (void)performResumeDeferredSetup
// {
//     [scrollView jumpToIndex:[convos indexOfObject:[self conversation]]];
//     %orig;
// }

// %end

%hook CKConversationList

- (void)deleteConversationAtIndex:(int)arg1 {
    %orig;
    // update vcs
}

%end

%hook CKConversationListController

- (void)noteConversationListChanged
{
    %orig;
    // update vcs
}

%end

%end



































static void MS7UpdatePreferences() {
    NSLog(@"GOT NOTIFICATION");

    NSDictionary *preferences = [[NSDictionary alloc] initWithContentsOfFile:PrefPath];
    globalEnable = YES;
    if (preferences) {
        //if the option exists make it that, else default
        if ([preferences valueForKey:@"globalEnable"] != nil) {
            globalEnable = [[preferences valueForKey:@"globalEnable"] boolValue];
        } else {
            globalEnable = YES;
        }
    }
    [preferences release];
}

static void reloadPrefsNotification(CFNotificationCenterRef center,
                    void *observer,
                    CFStringRef name,
                    const void *object,
                    CFDictionaryRef userInfo) {
    MS7UpdatePreferences();
}

%ctor {

   //init prefs again
    MS7UpdatePreferences();
    CFNotificationCenterRef reload = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(reload, NULL, &reloadPrefsNotification,
                    CFSTR("com.mattcmultimedia.messageswiper7/reload"), NULL, 0);

    %init;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        %init(MessagesiOS7);
    } else {
        // %init(MessagesiOS6);
        // %init(WhatsAppiOS6);
    }



}