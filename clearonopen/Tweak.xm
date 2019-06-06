#import <iOS7/SpringBoard/SBSearchViewController.h>
#import <iOS7/SpringBoard/SBSearchHeader.h>
#import <iOS6/SpringBoard/SBSearchController.h>
#import <iOS6/SpringBoard/SBSearchView.h>

#import <substrate.h>

%group iOS7
%hook SBSearchViewController

- (void)searchGesture:(id)arg1 completedShowing:(BOOL)arg2 {
    %orig;
    if (!arg2) {
        SBSearchHeader *h = MSHookIvar<SBSearchHeader *>(self, "_searchHeader");
        if (h) {
            [h searchField].text = @"";
            [self _searchFieldEditingChanged];
        }
    }
}

%end
%end

%group iOS6
static SBSearchController *sbSearchController;
%hook SBSearchController

- (id)init{
    if ((self = %orig) != nil) {
        //do stuff
        sbSearchController = self;
    }
    return self;
}

%end

%hook SBSearchView
//make search bar's text nil on init

- (void)addTableView
{
    [self searchBar].text = nil;
    //- (void)searchBar:(id)arg1 textDidChange:(id)arg2;
    [sbSearchController searchBar:self textDidChange:nil];
    //- (void)setShowsKeyboard:(BOOL)arg1 animated:(BOOL)arg2;
    [self setShowsKeyboard:YES animated:YES];
    %orig;
}
%end

%end


// %end

%ctor {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        %init(iOS7);
    } else {
        %init(iOS6);
    }

}