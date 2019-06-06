


#import <ChatKit/CKTranscriptController.h>
#import <ChatKit/CKConversationList.h>
#import <ChatKit/CKConversation.h>
#import <MobileSMS/CKMessagesController.h>
#import <UIKit/UIGestureRecognizer.h>
#import <UIKit/UIKit.h>

#import <substrate.h>


#import <WhatsApp/ChatManager.h>
#import <WhatsApp/WAChatSession.h>
#import <WhatsAppNew/ChatViewController.h>
#import <WhatsApp/ChatListViewController.h>
#import <WhatsAppNew/WAChatStorage.h>
#import <WhatsApp/ChatNavigationController.h>
#import <WhatsApp/WAScrollView.h>

//static NSString *test;
static NSMutableArray *convos = [[NSMutableArray alloc] init];
static CKMessagesController *ckMessagesController;
static unsigned int currentConvoIndex = 0;
static UIView *backPlacard;
static BOOL isFirstLaunch = YES;

//settings
static BOOL customSwipeSettings = NO;
static BOOL globalEnable = YES;
static BOOL switchShortSwipeDirections = NO;
static BOOL longSwipesEnabled = YES;
static BOOL wrapAroundEnabled = NO;
static BOOL enableAnimations = YES;
static BOOL hideBackButton = NO;
static BOOL updateFrequently = YES;
static float previewSwipeSensitivity = 50.0f;

//values
static int longSwipeDistance = 200;
static int shortSwipeDistance = 50;


// preview image stuff
static UILabel *leftContactNameLabel;
static UILabel *rightContactNameLabel;
static UILabel *leftMostRecentMessageLabel;
static UILabel *rightMostRecentMessageLabel;
static UIImage *previewImage;
static UIImage *flippedPreviewImage;

static CGPoint originalLocation;

#define PrefPath [@"/var/mobile" stringByAppendingPathComponent:@"Library/Preferences/com.mattcmultimedia.messageswiper.plist"]


static NSString *getsuffix() {

    if ([[UIScreen mainScreen] scale] < 2.0f)
        return @"";

    return @"@2x";

}



//animation UIView interfaces and stuff
@interface MSNextMessagePreviewView : UIImageView
@property (assign) NSString *contactName;
@property (assign) NSString *mostRecentMessage;

- (void) setConversation:(CKConversation *)convo;

@end
@implementation MSNextMessagePreviewView
@synthesize contactName = _contactName;
@synthesize mostRecentMessage = _mostRecentMessage;

- (void) setConversation:(CKConversation *)convo
{
    self.contactName = [convo name];
    //would set mostRecentMessage here
    self.mostRecentMessage = [[convo latestMessage] previewText]; //returns CKIMMessage => NSString


}


- (void)baseInit {
    _contactName = NULL;
    _contactName = @"Unknown - Error";
    _mostRecentMessage = @"Error Retrieving Message.";
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
    }
    return self;
}

@end

static MSNextMessagePreviewView *leftPreviewView = [[MSNextMessagePreviewView alloc] initWithFrame:CGRectMake(-60,10,120,160)];
static MSNextMessagePreviewView *rightPreviewView = [[MSNextMessagePreviewView alloc] initWithFrame:CGRectMake(backPlacard.frame.size.width+60,10,120,160)];




@interface MSSwipeDelegate : NSObject <UIGestureRecognizerDelegate>

-(void)messageSwiper_handlePan:(UIPanGestureRecognizer *)recognizer;
-(void)createPreviewImages;
@end
@implementation MSSwipeDelegate

-(void)createPreviewImages {
    NSBundle *bundle = [[NSBundle alloc] initWithPath:@"/Library/Application Support/MessageSwiper/"];
    NSString *imagePath = [bundle pathForResource:[NSString stringWithFormat:@"/previewImage%@", getsuffix()] ofType:@"png"];
    previewImage = [UIImage imageWithContentsOfFile:imagePath];
    flippedPreviewImage = [UIImage imageWithCGImage:previewImage.CGImage scale:previewImage.scale orientation:UIImageOrientationUpMirrored];

    leftPreviewView.image = previewImage;
    rightPreviewView.image = flippedPreviewImage;

    [bundle release];
    [imagePath release];
}

-(void)messageSwiper_handlePan:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        //if new touch
        originalLocation = [recognizer locationInView:recognizer.view];

    }
    //if convos are empty and stuff, just don't do anything, also if global enable off
    if (!globalEnable) {
        return;
    }
    if ((convos == NULL) || ([convos count] == 0)) {
        return;
    }
    CGPoint tempLoc = [recognizer locationInView:recognizer.view];
    CGPoint translation;//[recognizer translationInView:recognizer.view];
    if (tempLoc.x >= originalLocation.x) {
        translation = CGPointMake(tempLoc.x - originalLocation.x, originalLocation.y);
    } else {
        translation = CGPointMake(-1* (originalLocation.x - tempLoc.x), originalLocation.y);
    }
    unsigned int nextConvoIndex;

    //positive == right
    //negative == left
    if (switchShortSwipeDirections) {
        translation.x = -1 * translation.x;
    }
    if (translation.x > 0) {
        //is an ongoing swipe to the right
        rightPreviewView.center = CGPointMake(recognizer.view.frame.size.width+60, leftPreviewView.center.y);
        rightPreviewView.hidden = YES;

        nextConvoIndex = currentConvoIndex - 1;
        if (currentConvoIndex == 0) {
            if (wrapAroundEnabled) {
                nextConvoIndex = [convos count] - 1 ;
            } else {
                nextConvoIndex = 0;
                //maybe show bounce animation here
            }
        }
        if (enableAnimations) {
            //show animations here

            if (![leftPreviewView isDescendantOfView:recognizer.view]) {
                //if not added to view, go ahead and grab the image and add it to the view
                if (previewImage == NULL) {
                    [self createPreviewImages];
                }
                [recognizer.view addSubview:leftPreviewView];

                leftContactNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(9, 15, 75, 50)];
                [leftContactNameLabel setTextColor:[UIColor blackColor]];
                [leftContactNameLabel setBackgroundColor:[UIColor clearColor]];
                [leftContactNameLabel setFont:[UIFont systemFontOfSize: 14.0f]];
                [leftContactNameLabel setNumberOfLines:4];
                [leftContactNameLabel setLineBreakMode:NSLineBreakByWordWrapping];
                [leftPreviewView addSubview:leftContactNameLabel];

                //add message label here
                leftMostRecentMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(9,69,75, 79)];
                [leftMostRecentMessageLabel setTextColor:[UIColor blackColor]];
                [leftMostRecentMessageLabel setBackgroundColor:[UIColor clearColor]];
                [leftMostRecentMessageLabel setFont:[UIFont systemFontOfSize: 12.0f]];
                [leftMostRecentMessageLabel setNumberOfLines:10];
                [leftMostRecentMessageLabel setLineBreakMode:NSLineBreakByWordWrapping];
                [leftPreviewView addSubview:leftMostRecentMessageLabel];
            }
            [leftPreviewView setConversation:[convos objectAtIndex:nextConvoIndex]];
            leftContactNameLabel.text = leftPreviewView.contactName;
            leftMostRecentMessageLabel.text = leftPreviewView.mostRecentMessage;
            //update message label here
            [recognizer.view bringSubviewToFront:leftPreviewView];
            leftPreviewView.hidden = NO;
            if ((translation.x > longSwipeDistance) && longSwipesEnabled) {
                leftContactNameLabel.text = @"Convo List";
                leftMostRecentMessageLabel.text = @"Release to Return to List.";
            }

            //actual animations

            int scalar;
            if (shortSwipeDistance > 120) {
                scalar = 1;
            } else {
                scalar = (120/shortSwipeDistance);
            }
            //float slideFactor = 0.1 * slideMult; // Increase for more of a slide
            CGPoint finalPoint = CGPointMake(-60 + (translation.x * scalar),
                                             leftPreviewView.center.y);
            finalPoint.x = MIN(finalPoint.x, 60);
            //finalPoint.y = MIN(MAX(finalPoint.y, 0), recognizer.view.bounds.size.height);
            if (translation.x > shortSwipeDistance+8) {
                leftPreviewView.alpha = 1.0f;
            } else {
                leftPreviewView.alpha = 0.75f;
            }

            leftPreviewView.center = finalPoint;

        }

    } else {
        //is an ongoing swipe left
        leftPreviewView.hidden = YES;
        leftPreviewView.center = CGPointMake(-60, leftPreviewView.center.y);
        nextConvoIndex = currentConvoIndex + 1;
        if (nextConvoIndex >= [convos count]) {
            if (wrapAroundEnabled) {
                nextConvoIndex = 0;
            } else {
                nextConvoIndex = currentConvoIndex;
                //maybe display bounce animation here
            }
        }
        if (enableAnimations) {
            //show animations here

            //previewImage.imageOrientation = UIImageOrientationUpMirrored;
            if (![rightPreviewView isDescendantOfView:recognizer.view]) {
                if (flippedPreviewImage == NULL) {
                    [self createPreviewImages];
                }

                [recognizer.view addSubview:rightPreviewView];

                rightContactNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(39, 15, 75, 50)];
                [rightContactNameLabel setTextColor:[UIColor blackColor]];
                [rightContactNameLabel setBackgroundColor:[UIColor clearColor]];
                [rightContactNameLabel setFont:[UIFont systemFontOfSize: 14.0f]];
                [rightContactNameLabel setNumberOfLines:4];
                [rightContactNameLabel setLineBreakMode:NSLineBreakByWordWrapping];
                [rightPreviewView addSubview:rightContactNameLabel];

                rightMostRecentMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(39,69,75, 79)];
                [rightMostRecentMessageLabel setTextColor:[UIColor blackColor]];
                [rightMostRecentMessageLabel setBackgroundColor:[UIColor clearColor]];
                [rightMostRecentMessageLabel setFont:[UIFont systemFontOfSize: 12.0f]];
                [rightMostRecentMessageLabel setNumberOfLines:10];
                [rightMostRecentMessageLabel setLineBreakMode:NSLineBreakByWordWrapping];
                [rightPreviewView addSubview:rightMostRecentMessageLabel];
            }

            [rightPreviewView setConversation:[convos objectAtIndex:nextConvoIndex]];
            rightContactNameLabel.text = rightPreviewView.contactName;
            rightMostRecentMessageLabel.text = rightPreviewView.mostRecentMessage;
            [recognizer.view bringSubviewToFront:rightPreviewView];
            rightPreviewView.hidden = NO;

            if ((-1*translation.x > longSwipeDistance) && longSwipesEnabled) {
                //set to first convo
                [rightPreviewView setConversation:[convos objectAtIndex:0]];
                rightContactNameLabel.text = rightPreviewView.contactName;
                rightMostRecentMessageLabel.text = rightPreviewView.mostRecentMessage;
            }

            //actually animate ImageView here
            int scalar;
            if (shortSwipeDistance > 120) {
                scalar = 1;
            } else {
                scalar = (120/shortSwipeDistance);
            }
            CGPoint finalPoint = CGPointMake(recognizer.view.frame.size.width+60 + (translation.x * scalar), leftPreviewView.center.y);
            finalPoint.x = MAX(finalPoint.x, recognizer.view.frame.size.width - 60);
            //finalPoint.y = MIN(MAX(final2Point.y, 0), recognizer.view.bounds.size.height);
            if (-1*translation.x > (shortSwipeDistance+8)) {
                rightPreviewView.alpha = 1.0f;
            } else {
                rightPreviewView.alpha = 0.75f;
            }

            rightPreviewView.center = finalPoint;
        }

    }
    //LIFTS FINGER

    //once user lifts finger, do whatever should happen within swipe range
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        //remove the UIView when this gets called


        leftPreviewView.hidden = YES;
        rightPreviewView.hidden = YES;
        leftPreviewView.center = CGPointMake(-60, leftPreviewView.center.y);
        rightPreviewView.center = CGPointMake(recognizer.view.frame.size.width+60, rightPreviewView.center.y);




        if (translation.x > 0) {

            //ended swipe on right side

            if ((translation.x >= longSwipeDistance) && longSwipesEnabled) {
                //if long swipe right, show list
                if (switchShortSwipeDirections) {
                    //but if switched, show newest message
                    convos = [[%c(CKConversationList) sharedConversationList] conversations];
                    [ckMessagesController showConversation:[convos objectAtIndex:0] animate:YES];
                } else {
                    [ckMessagesController showConversationList:YES];
                }
                return;
            }

            if (translation.x >= shortSwipeDistance) {
                //this is short swipe: show next convo
                [ckMessagesController showConversation:[convos objectAtIndex:nextConvoIndex] animate:YES];
                return;
            }

        } else {

            //ended swipe on left side
            //long swipe stuff left
            translation.x = -1 * translation.x;


            if ((translation.x >= longSwipeDistance) && longSwipesEnabled) {
                if (switchShortSwipeDirections) {
                    [ckMessagesController showConversationList:YES];
                } else {
                    convos = [[%c(CKConversationList) sharedConversationList] conversations];
                    [ckMessagesController showConversation:[convos objectAtIndex:0] animate:YES];
                }
                return;
            }
            //short swipe stuff left
            if (translation.x >= shortSwipeDistance) {
                //this is short swipe: show next convo

                [ckMessagesController showConversation:[convos objectAtIndex:nextConvoIndex] animate:YES];
                return;
            }
        }



    }

}

//delegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}
@end

static MSSwipeDelegate *swipeDelegate;

%hook CKTranscriptController

- (void)viewDidAppear:(BOOL)arg1
{
    //only run this part once or otherwise we'll have multiple gestureRecognizers and shit
    if (isFirstLaunch) {
        backPlacard = self.view;
        if (backPlacard) {
            isFirstLaunch = NO;
            if (!swipeDelegate) {
                swipeDelegate = [[MSSwipeDelegate alloc] init];
            }
            //just in case it isn't default
            backPlacard.userInteractionEnabled = YES;

            //testing pan gesture recognizer - works pretty well
            UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:swipeDelegate action:@selector(messageSwiper_handlePan:)];
            panRecognizer.maximumNumberOfTouches = 1;
            [backPlacard addGestureRecognizer:panRecognizer];

            //possibly add another panRecognizer to allow for two finger longSwipes
        }
    }

    if (longSwipesEnabled && hideBackButton && globalEnable) {
        [[self navigationItem] setHidesBackButton:YES];
    }


    %orig;

}

- (void)_messageReceived:(id)arg1
{

    %orig;
    if (updateFrequently) {
        convos = [[%c(CKConversationList) sharedConversationList] conversations];
        currentConvoIndex = [convos indexOfObject:[self conversation]];
    }

}
%end

//
%hook CKMessagesController
-(void)_conversationLeft:(id)left
{
    //if you delete a convo
    convos = [[%c(CKConversationList) sharedConversationList] conversations];


    %orig;
}

//
-(void)showConversation:(id)conversation animate:(BOOL)animate
{
    //resets currentConvoIndex

    currentConvoIndex = [convos indexOfObject:conversation];
    %orig;
}
-(void)showConversation:(id)conversation animate:(BOOL)animate forceToTranscript:(BOOL)transcript
{

    currentConvoIndex = [convos indexOfObject:conversation];
    %orig;
}

-(BOOL)resumeToConversation:(id)conversation
{
    currentConvoIndex = [convos indexOfObject:conversation];
    return %orig;
}
//grabs the ckMessagesController object

-(id)init
{

    convos = [[%c(CKConversationList) sharedConversationList] conversations];

    ckMessagesController = self;

    // UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"convos"
    //     message:[NSString stringWithFormat:@"%@", convos]
    //     delegate:nil
    //     cancelButtonTitle:@"K"
    //     otherButtonTitles:nil];
    // [alert show];
    // [alert release];


    return %orig;
    //init prefs again
    preferences = [[NSDictionary alloc] initWithContentsOfFile:PrefPath];

    if (preferences == nil) {
        globalEnable = YES;
    } else {
        //if the option exists make it that, else default
        if ([preferences valueForKey:@"globalEnable"] != nil) {
            globalEnable = [[preferences valueForKey:@"globalEnable"] boolValue];
        } else {
            globalEnable = YES;
        }
        if ([preferences valueForKey:@"customSwipeSettings"] != nil) {
            customSwipeSettings = [[preferences valueForKey:@"customSwipeSettings"] boolValue];
        } else {
            customSwipeSettings = NO;
        }
        if (customSwipeSettings) {
            if ([preferences valueForKey:@"switchShortSwipeDirections"] != nil) {
                switchShortSwipeDirections = [[preferences valueForKey:@"switchShortSwipeDirections"] boolValue];
            } else {
                switchShortSwipeDirections = NO;
            }
            if ([preferences valueForKey:@"wrapAroundEnabled"] != nil) {
                wrapAroundEnabled = [[preferences valueForKey:@"wrapAroundEnabled"] boolValue];
            } else {
                wrapAroundEnabled = NO;
            }
            if ([preferences valueForKey:@"enableAnimations"] != nil) {
                enableAnimations = [[preferences valueForKey:@"enableAnimations"] boolValue];
            } else {
                enableAnimations = YES;
            }
            if ([preferences valueForKey:@"longSwipesEnabled"] != nil) {
                longSwipesEnabled = [[preferences valueForKey:@"longSwipesEnabled"] boolValue];
            } else {
                longSwipesEnabled = YES;
            }
            if ([preferences valueForKey:@"hideBackButton"] != nil) {
                hideBackButton = [[preferences valueForKey:@"hideBackButton"] boolValue];
            } else {
                hideBackButton = NO;
            }
            if ([preferences valueForKey:@"updateFrequently"] != nil) {
                updateFrequently = [[preferences valueForKey:@"updateFrequently"] boolValue];
            } else {
                updateFrequently = YES;
            }
            if ([preferences valueForKey:@"longSwipeDistance"] != nil) {
                longSwipeDistance = [[preferences valueForKey:@"longSwipeDistance"] intValue];
            } else {
                longSwipeDistance = 200;
            }
            if ([preferences valueForKey:@"shortSwipeDistance"] != nil) {
                shortSwipeDistance = [[preferences valueForKey:@"shortSwipeDistance"] intValue];
            } else {
                shortSwipeDistance = 50;
            }
            if ([preferences valueForKey:@"previewSwipeSensitivity"] != nil) {
                previewSwipeSensitivity = [[preferences valueForKey:@"previewSwipeSensitivity"] floatValue];
            } else {
                previewSwipeSensitivity = 50.0f;
            }
        } else {
            //defaults
            switchShortSwipeDirections = NO;
            wrapAroundEnabled = NO;
            enableAnimations = YES;
            longSwipesEnabled = YES;
            hideBackButton = NO;
            updateFrequently = YES;
            longSwipeDistance = 200;
            shortSwipeDistance = 50;
            previewSwipeSensitivity = 50.0f;
        }
    }
    [preferences release];
}

%end

%hook CKConversation

- (void)sendMessage:(id)arg1 newComposition:(BOOL)arg2
{
    if (updateFrequently) {
        convos = [[%c(CKConversationList) sharedConversationList] conversations];
        currentConvoIndex = [convos indexOfObject:self];
    }
    %orig;
}
- (void)sendMessage:(id)arg1 onService:(id)arg2 newComposition:(BOOL)arg3
{
    if (updateFrequently) {
        convos = [[%c(CKConversationList) sharedConversationList] conversations];
        currentConvoIndex = [convos indexOfObject:self];
    }
    %orig;

}

%end


// ====================================================================================================================================
// ====================================================================================================================================
// ====================================================================================================================================
// ====================================================================================================================================
// ====================================================================================================================================
// ====================================================================================================================================
// ====================================================================================================================================
// ====================================================================================================================================
// ====================================================================================================================================
// ====================================================================================================================================
// ====================================================================================================================================
// ====================================================================================================================================




%ctor {

   //init prefs again
    preferences = [[NSDictionary alloc] initWithContentsOfFile:PrefPath];
    if (preferences == nil) {
        globalEnable = YES;
    } else {
        //if the option exists make it that, else default
        if ([preferences valueForKey:@"globalEnable"] != nil) {
            globalEnable = [[preferences valueForKey:@"globalEnable"] boolValue];
        } else {
            globalEnable = YES;
        }
        if ([preferences valueForKey:@"customSwipeSettings"] != nil) {
            customSwipeSettings = [[preferences valueForKey:@"customSwipeSettings"] boolValue];
        } else {
            customSwipeSettings = NO;
        }
        if (customSwipeSettings) {
            if ([preferences valueForKey:@"switchShortSwipeDirections"] != nil) {
                switchShortSwipeDirections = [[preferences valueForKey:@"switchShortSwipeDirections"] boolValue];
            } else {
                switchShortSwipeDirections = NO;
            }
            if ([preferences valueForKey:@"wrapAroundEnabled"] != nil) {
                wrapAroundEnabled = [[preferences valueForKey:@"wrapAroundEnabled"] boolValue];
            } else {
                wrapAroundEnabled = NO;
            }
            if ([preferences valueForKey:@"enableAnimations"] != nil) {
                enableAnimations = [[preferences valueForKey:@"enableAnimations"] boolValue];
            } else {
                enableAnimations = YES;
            }
            if ([preferences valueForKey:@"longSwipesEnabled"] != nil) {
                longSwipesEnabled = [[preferences valueForKey:@"longSwipesEnabled"] boolValue];
            } else {
                longSwipesEnabled = YES;
            }
            if ([preferences valueForKey:@"hideBackButton"] != nil) {
                hideBackButton = [[preferences valueForKey:@"hideBackButton"] boolValue];
            } else {
                hideBackButton = NO;
            }
            if ([preferences valueForKey:@"updateFrequently"] != nil) {
                updateFrequently = [[preferences valueForKey:@"updateFrequently"] boolValue];
            } else {
                updateFrequently = YES;
            }
            if ([preferences valueForKey:@"longSwipeDistance"] != nil) {
                longSwipeDistance = [[preferences valueForKey:@"longSwipeDistance"] intValue];
            } else {
                longSwipeDistance = 200;
            }
            if ([preferences valueForKey:@"shortSwipeDistance"] != nil) {
                shortSwipeDistance = [[preferences valueForKey:@"shortSwipeDistance"] intValue];
            } else {
                shortSwipeDistance = 50;
            }
        } else {
            //defaults
            switchShortSwipeDirections = NO;
            wrapAroundEnabled = NO;
            enableAnimations = YES;
            longSwipesEnabled = YES;
            hideBackButton = NO;
            updateFrequently = YES;
            longSwipeDistance = 200;
            shortSwipeDistance = 50;
        }
    }
    [preferences release];

    if (globalEnable) {
        %init;
        %init(WhatsAppStuff);
    }


    // [tempglobalEnable release];
    // [tempcustomSwipeSettings release];

    // if(something) %init(HelloWorld); //This makes the hello world group functional based on an if statement, just for code management.
    //make a group for WhatsApp and only init if WhatsApp is running or something
    //after making this,
    //also possibly make group for iOS5 to stop crashes
    //determine if the app is WhatsApp
    //NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
}