//
//  SlideShowViewController.h
//  Xmedia
//
//  Created by Luis Filipe Oliveira on 2/17/11.
//

#import "Asset.h"
#import "protocols.h"
#import "TapDetectingImageView.h"
#import "GestureRecognizerOverlayView.h"
#import "MovieProgressView.h"

#define kSlideShowDefaultTransitionDelay 1
#define kSlideShowDefaultDelay 4
#define kFadeDelay 0.3
#define kAutoHideDelay 5
#define kMovieProgressAutoHideDelay 2


@class MPMoviePlayerController;

@interface SlideShowViewController : UIViewController<TapDelegate> {
	
	NSMutableArray *assets;
	NSInteger currentIndex;
	
	MPMoviePlayerController	*nextMoviePlayer; //next movie
    MPMoviePlayerController	*moviePlayer2; //next next movie
    MPMoviePlayerController *currentMoviePlayer; //movie currently on screen
    MPMoviePlayerController *moviePlayerToRelease; //movie to release after the transition
	
	UIBarButtonItem *doneButton;
	
	NSArray *playToolbar;
	NSArray *pauseToolbar;
	
	NSTimer *timer;
    
	UIView *backgroundView;
    GestureRecognizerOverlayView *grOverlayView;
    MovieProgressView *movieProgressView;
	UIView *currentView;
	UIView *nextView;
	
	CGFloat transitionDelay;
	CGFloat slideShowDelay;
	
	BOOL transitioning;
	BOOL playing;
    
    // overlay icons
    UIImageView *_iconPlay;
    UIImageView *_iconPause;
    UIImageView *_iconFF;
    UIImageView *_iconRW;
    UILabel *_iconSpeed;
}

@property(nonatomic,assign) CGFloat transitionDelay;
@property(nonatomic,assign) CGFloat slideShowDelay;


- (id)initWithAssets:(NSMutableArray *)theAssets startingIndex:(NSInteger)index;
- (void)start;
- (void)stop;

@end
