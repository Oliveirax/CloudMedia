//
//  SlideShowViewController.m
//  Xmedia
//
//  Created by Luis Filipe Oliveira on 2/17/11.
//

#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import "SlideShowViewController.h"

#define kVideoSeekInc 1.0


//private interface
@interface SlideShowViewController()

//movie seeking properties

// Loading Assets into Views
- (void)loadView:(UIView **)view withAssetAtIndex:(NSInteger)index;
- (void)loadNextItem;
- (void)loadPreviousItem;

// Animating Bars Show/Hide
- (BOOL)showBars;
- (BOOL)hideBars;

//Animating Overlays
- (void)flashPlayOverlay;
- (void)flashPauseOverlay;
- (void)showMovieProgress;
- (void)hideMovieProgress;

// Animating Transitions
- (void)performTransition;
- (void)performTransition2;
- (void)performTransition1;

//SlideShow Control
- (void)start; //public
- (void)stop;  //public
- (void)previous;
- (void)next;

//Button Actions
- (void)playAction;
- (void)pauseAction;
- (void)previousAction;
- (void)nextAction;
- (void)doneAction;

//Stopping and Releasing a MoviePlayer
- (void)stopMoviePlayer:(MPMoviePlayerController **)mPlayer releaseImmediately:(BOOL)releaseImmediately;


//Notification Delegates
- (void)moviePlayerFinished:(NSNotification*)notification; //movie player finished
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag; // core animation delegate

@end



@implementation SlideShowViewController

@synthesize slideShowDelay;
@synthesize transitionDelay;



#pragma mark - init and dealloc

- (id)initWithAssets:(NSMutableArray *)theAssets startingIndex:(NSInteger)index
{
	if ((self = [super init])) {
		
		self.wantsFullScreenLayout = YES;
		assets = [theAssets retain];
		currentIndex = index;
		self.title = @"Slide Show";
		nextMoviePlayer = nil;
        moviePlayer2 = nil;
        currentMoviePlayer = nil;
        moviePlayerToRelease = nil;
        currentView = nil;
        nextView = nil;
        transitioning = NO;
        playing = NO;
		
		//done button
		doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction)];
		
		
		//toolbar Buttons
		UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem* previousButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(previousAction)];
		UIBarButtonItem* nextButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(nextAction)];
		UIBarButtonItem* playButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playAction)];
		UIBarButtonItem* pauseButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(pauseAction)];
				
		//toolbars
		playToolbar = [[NSArray alloc]initWithObjects:flexibleSpace, previousButton, flexibleSpace, playButton, flexibleSpace, nextButton, flexibleSpace, nil];
		pauseToolbar = [[NSArray alloc]initWithObjects:flexibleSpace, previousButton, flexibleSpace, pauseButton, flexibleSpace, nextButton, flexibleSpace, nil];
		
		[flexibleSpace release];
		[previousButton release];
		[nextButton release];
		[playButton release];
		[pauseButton release];
		
		
		transitionDelay = SlideShowDefaultTransitionDelay;
		slideShowDelay = SlideShowDefaultDelay;
		
		timer = nil;
        
        
	}
	return self;
}


- (void)dealloc 
{
    [assets release];
    [doneButton release];
	if (nextMoviePlayer)[nextMoviePlayer release];
	if (moviePlayerToRelease) [moviePlayerToRelease release];
	[backgroundView release];
    [grOverlayView release];
	[playOverlayView release];
	[pauseOverlayView release];
    [movieProgressView release];
    [super dealloc];
}



#pragma mark - View lifecycle

- (void)loadView 
{
	// background view
	backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = [UIColor clearColor];
	backgroundView.tag = -1;
	self.view = backgroundView;
	
    //overlay buttons
	playOverlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PlayOverlay"]];
	pauseOverlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PauseOverlay"]];
    
    //overlay progressBarView
    movieProgressView = [[MovieProgressView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
	// customize navigation bar
	self.navigationController.navigationBarHidden = YES;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	self.navigationItem.hidesBackButton = NO;
	self.navigationItem.title = self.title;
	self.navigationItem.leftBarButtonItem = doneButton;
	
	//customize toolbar
	self.navigationController.toolbarHidden = YES;
	self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;
}


- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
	NSLog(@"SLIDESHOW did appear!!!! \n ");
	
    [self loadView:&nextView withAssetAtIndex:currentIndex];
    currentView = nil; //start from a black view
    currentIndex--;
	
    //gesture recognizer transparent overlay
    grOverlayView = [[GestureRecognizerOverlayView alloc] initWithFrame:self.view.frame];
    grOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    grOverlayView.delegate = self;
    [self.view addSubview:grOverlayView];
    
    //play it
    [self start];
    [self next ];
}


- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:animated];
	NSLog(@"slideshow did disappear");
    
    // stop the current movie
    if (currentMoviePlayer){
        [self stopMoviePlayer:&currentMoviePlayer releaseImmediately:YES];
    }
    
	[self stop];
}	



- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main currentView.
    // e.g. self.myOutlet = nil;
}



#pragma mark - Loading Assets into Views

- (void)loadView:(UIView **)view withAssetAtIndex:(NSInteger)index
{
    if (*view != nil){
        [*view removeFromSuperview];
    }
    
    if (moviePlayerToRelease != nil){
        NSLog(@"LOAD VIEW - moviePlayerToRelease Released");
        [moviePlayerToRelease release];
        moviePlayerToRelease = nil;
    }
    
    Asset *asset = [assets objectAtIndex:index];
    UIView *newView;
    
    if ([asset.type isEqualToString:kAssetTypeVideo]){
        MPMoviePlayerController *mp = [[MPMoviePlayerController alloc] initWithContentURL:[asset url]];
        mp.shouldAutoplay = NO;
        
        //these two instructions cancel any video currently playing, so... 
        if (!currentMoviePlayer){
            mp.controlStyle = MPMovieControlStyleNone;
            [mp prepareToPlay];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self  
                                                 selector:@selector(moviePlayerFinished:)  
                                                     name:MPMoviePlayerPlaybackDidFinishNotification  
                                                   object:mp];
        
        newView = mp.view;
        [self.view insertSubview:newView atIndex:0]; // insert it under all the other views
        
        if (nextMoviePlayer == nil){
            nextMoviePlayer = mp;
            NSLog(@"LOAD VIEW - loading MoviePlayer1 - index: %d", index);
        }
        else{
            moviePlayer2 = mp;
            NSLog(@"ERROR!!!!! LOAD VIEW : moviePlayer2 now has something - index %d", index);
        }
    }
    else{ // Image
        newView= [[UIImageView alloc] initWithImage:[asset image]];
        [self.view insertSubview:newView atIndex:0]; // insert it under all the other views
        [newView setContentMode:UIViewContentModeScaleAspectFit];
        [newView release]; //the superView is the owner, careful not to do this with the mp view
         NSLog(@"LOAD VIEW - loading Image - index %d", index);
    }
    
	newView.frame = self.view.frame;
    newView.hidden = YES;
    *view = newView; //the supplied pointer references the new view
}


- (void)loadNextItem{
	
	// advance one index
	currentIndex++;
	
	if (currentIndex >= assets.count) {
		currentIndex = 0;
	}
	
	NSInteger nextIndex = currentIndex+1;
	
	if (nextIndex >= assets.count) {
		nextIndex = 0;
	}
	
	// swap	
	UIView *temp = nextView;
	nextView = currentView;
	currentView = temp;
	
    [self loadView:&nextView withAssetAtIndex:nextIndex];
}



- (void)loadPreviousItem{
	
	NSInteger nextIndex = currentIndex-1;
	
	if (nextIndex < 0){
		nextIndex = assets.count-1;
	}
	
    //let's pretend we are in the (currentIndex-2)th position
	currentIndex = nextIndex-1;
	
	if (currentIndex < 0){
		currentIndex = assets.count-1;
	}
    
    //release next movie, if loaded
    if (nextMoviePlayer){
       NSLog(@"RELEASING NExt MOvie");
//        [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                        name:MPMoviePlayerPlaybackDidFinishNotification
//                                                      object:moviePlayer1];
//        
//        moviePlayer1.initialPlaybackTime = -1.0;
//        [moviePlayer1 stop];
//        [moviePlayer1 release];
//        moviePlayer1 = nil;
        
        [self stopMoviePlayer:&nextMoviePlayer releaseImmediately:YES];
    }
	
    [self loadView:&nextView withAssetAtIndex:nextIndex];
}




#pragma mark - Animating Rotations

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
			interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
			interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}



- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
	
	if (interfaceOrientation == UIInterfaceOrientationPortrait) {
		[UIView animateWithDuration: duration 
						 animations: ^{ 
							 backgroundView.frame = CGRectMake(0,0,320,480);
							 currentView.frame = CGRectMake(0,0,320,480);
							 nextView.frame = CGRectMake(0,0,320,480);
							 movieProgressView.orientation = interfaceOrientation;
						 } 
						 completion: nil
		 ];
		
	}
	else{
		[UIView animateWithDuration: duration 
						 animations: ^{ 
							 backgroundView.frame = CGRectMake(0,0,480,320);
							 currentView.frame = CGRectMake(0,0,480,320);
							 nextView.frame = CGRectMake(0,0,480,320);
							 movieProgressView.orientation = interfaceOrientation;
						 } 
						 completion: nil
		 ];
	}	 
}



#pragma mark - Animating Bars Show/Hide 

- (BOOL)showBars 
{	
    //cancel previous auto-hide requests
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideBars) object:nil];
    
	if (![self.navigationController isNavigationBarHidden] ) {
        if (playing || (currentMoviePlayer && currentMoviePlayer.currentPlaybackRate > 0)) {
            [self.navigationController.toolbar setItems:pauseToolbar animated:YES];
        }
        else {
            [self.navigationController.toolbar setItems:playToolbar animated:YES];
        }
        return NO;
    }
    
    //hide movie progress
    [self hideMovieProgress];
	
	// show status bar
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	
	// make bars transparent, then show them
	self.navigationController.navigationBar.alpha = 0.0;
	self.navigationController.toolbar.alpha = 0.0;
	[self.navigationController setNavigationBarHidden:NO animated:NO];
	[self.navigationController setToolbarHidden:NO animated:NO];
	
	if (playing || (currentMoviePlayer && currentMoviePlayer.currentPlaybackRate > 0)) {
		[self.navigationController.toolbar setItems:pauseToolbar animated:NO];
	}
	else {
		[self.navigationController.toolbar setItems:playToolbar animated:NO];
	}
    
	// animate transition from transparent to opaque
	[UIView animateWithDuration:kFadeDelay
					 animations:^{ 	
						 self.navigationController.navigationBar.alpha = 1.0; //test with hidden
						 self.navigationController.toolbar.alpha = 1.0;			
					 }  
					 completion:^(BOOL finished) {
						 // auto hide the bars after a delay
						 [self performSelector:@selector(hideBars) withObject:nil afterDelay:kAutoHideDelay];
					 }
	 ];	
    return YES;
}



- (BOOL)hideBars 
{	
    //cancel previous auto-hide requests
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideBars) object:nil];     
	
    if ([self.navigationController isNavigationBarHidden] ) return NO;
	
	// hide status bar
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	
	//animate transition from opaque to transparent, then hide them
	[UIView animateWithDuration:kFadeDelay
					 animations:^{ 	
						 self.navigationController.navigationBar.alpha = 0.0; 
						 self.navigationController.toolbar.alpha = 0.0;			
					 }  
					 completion:^(BOOL finished) {
						 [self.navigationController setNavigationBarHidden:YES animated:NO];
						 [self.navigationController setToolbarHidden:YES animated:NO];	
					 }
	 ];
    return YES;
}



#pragma mark - Animating Overlays

- (void)flashPlayOverlay
{
	playOverlayView.alpha = 1.0;
	playOverlayView.center = backgroundView.center;
	
	[backgroundView addSubview:playOverlayView];
	
	[UIView animateWithDuration:1.5
					 animations:^{ 	
						 playOverlayView.alpha = 0.0;
					 }  
					 completion:^(BOOL finished) {
						 [playOverlayView removeFromSuperview];
					 }
	 ];	
}


- (void)flashPauseOverlay
{
	pauseOverlayView.alpha = 1.0;
	pauseOverlayView.center = backgroundView.center;
	
	[backgroundView addSubview:pauseOverlayView];
	
	[UIView animateWithDuration:1.5
					 animations:^{ 	
						 pauseOverlayView.alpha = 0.0;
					 }  
					 completion:^(BOOL finished) {
						 [pauseOverlayView removeFromSuperview];
					 }
	 ];	
}

- (void)showMovieProgress
{
    if (! currentMoviePlayer ) return;
    
	//cancel previous hide requests
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideMovieProgress) object:nil];
    
    //hide bars
    [self hideBars];
    
	[movieProgressView setOrientation:self.interfaceOrientation];
    [movieProgressView setMoviePlayer:currentMoviePlayer];
    
    movieProgressView.alpha = 1.0;
	[backgroundView addSubview:movieProgressView];
    
    // auto hide the movieProgress after a delay
    [self performSelector:@selector(hideMovieProgress) withObject:nil afterDelay:kMovieProgressAutoHideDelay];	
}


- (void)hideMovieProgress
{
    //cancel previous hide requests
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideMovieProgress) object:nil];
    
	[UIView animateWithDuration:kFadeDelay
					 animations:^{ 	
						 movieProgressView.alpha = 0.0;
					 }  
					 completion:^(BOOL finished) {
                         [movieProgressView setMoviePlayer:nil];
						 [movieProgressView removeFromSuperview];
					 }
	 ];	
}



#pragma mark - Animating Transitions 

- (void)performTransition{
    NSLog(@"perform transition");
    [self performTransition1];
}


// layer based animation
-(void)performTransition1
{
	//this kind of animation works best with fully transparent backgounds
	backgroundView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
	
    // First create a CATransition object to describe the transition
    CATransition *transition = [CATransition animation];
    transition.duration = transitionDelay;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    // Now to set the type of transition. Since we need to choose at random, we'll setup a couple of arrays to help us.
    //NSString *types[4] = {kCATransitionMoveIn, kCATransitionPush, kCATransitionReveal, kCATransitionFade};
    //NSString *types[4] = {kCATransitionMoveIn, kCATransitionPush, kCATransitionReveal, kCATransitionMoveIn};
    //NSString *subtypes[4] = {kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom};
    
	
	// private api transitions
	//NSString *types2[] = {	@"suckEffect",@"rippleEffect"};
    
    //random transition
    //transition.type = types[random() % 4];
    //transition.subtype = subtypes[random() % 4];
	
    //custom transition
    transition.type = kCATransitionFade;
    //transition.type = kCATransitionMoveIn;
    //transition.subtype = kCATransitionFromRight;
	
    // Finally, to avoid overlapping transitions we assign ourselves as the delegate for the animation and wait for the
    // -animationDidStop:finished: message. When it comes in, we will flag that we are no longer transitioning.
    transitioning = YES;
    transition.delegate = self;
    
    // Next add it to the containerView's layer. This will perform the transition based on how we change its contents.
    [backgroundView.layer addAnimation:transition forKey:nil];
    
    // Here we hide view1, and show view2, which will cause Core Animation to animate view1 away and view2 in.
    currentView.hidden = YES;
    nextView.hidden = NO;
    
}


//UIView block animation 
- (void)performTransition2 {
	
	//pageCurl must be fully opaque, or the pic below will be visible, flip works well both ways
	backgroundView.backgroundColor = [UIColor blackColor];
	
	NSUInteger types[4] = { UIViewAnimationOptionTransitionFlipFromLeft,    
				UIViewAnimationOptionTransitionFlipFromRight,
				UIViewAnimationOptionTransitionCurlUp, 
   				UIViewAnimationOptionTransitionCurlDown  };
   				
   	int rnd = random() % 4;			
   	NSUInteger transitionType = types[rnd];	
    
    transitioning = YES;
    
	[UIView transitionWithView: backgroundView
		duration: transitionDelay
		options: transitionType | UIViewAnimationOptionAllowUserInteraction
		animations: ^{ 
			currentView.hidden = YES;
			nextView.hidden = NO;
		}
		completion: ^(BOOL finished){ 
			[self animationDidStop:nil finished:finished];
		} 
	];
}



#pragma mark -  SlideShow Control

- (void)start
{    
    NSLog(@"START!");
	
	//make sure only one timer is running
	if (timer != nil) {
		[self stop];
	}
    
	// start the timer that calls next every n seconds
	timer = [NSTimer scheduledTimerWithTimeInterval: transitionDelay + slideShowDelay 
											 target: self 
										   selector: @selector(next) 
										   userInfo: nil 
											repeats: YES];
	playing = YES;
    
    // disable system sleep
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}



- (void)stop
{
    NSLog(@"STOP");
	//stop the timer
	[timer invalidate];
	timer = nil;
	playing = NO;
    
    // enable system sleep
    [UIApplication sharedApplication].idleTimerDisabled = NO;    
}


- (void)previous
{
	if(!transitioning)
    {
         NSLog(@"PREV;");
        
        //a movie is playing
        if (currentMoviePlayer){
            //playback time is over 4 seconds - rewind
            if (currentMoviePlayer.currentPlaybackTime > 4){
                currentMoviePlayer.currentPlaybackTime = 0;
                return;
            }
            
            // Else, stop movie 
//            [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                            name:MPMoviePlayerPlaybackDidFinishNotification
//                                                          object:currentMoviePlayer];
//                
//            currentMoviePlayer.initialPlaybackTime = -1.0;
//            [currentMoviePlayer stop];
//            moviePlayerToRelease = currentMoviePlayer;
//            currentMoviePlayer = nil;
            [self stopMoviePlayer:&currentMoviePlayer releaseImmediately:NO];
            [self start];
        }
        
		[self loadPreviousItem];
        
        //check if the previous item is a movie and start it
        if (nextMoviePlayer != nil){
            [self stop];
            
            nextMoviePlayer.controlStyle = MPMovieControlStyleNone;
            [nextMoviePlayer play];
            
            currentMoviePlayer = nextMoviePlayer;
            
            if (moviePlayer2 != nil){
                NSLog(@"PREV - MEdiaPlayer2 has something");
                nextMoviePlayer = moviePlayer2;
                moviePlayer2 = nil;
            }
            else{
                nextMoviePlayer = nil;
            }
        }
        
        [self performTransition];
    }	
}


- (void)next 
{
	if(!transitioning)
    {
        NSLog(@"NEXT;");
        
        //a movie is playing - stop it
        if (currentMoviePlayer){
            NSLog(@"NEXT - stopping currentMoviePlayer");
            [self stopMoviePlayer:&currentMoviePlayer releaseImmediately:NO];
            [self start];
            
            //replace here the video view with a screen cap, do it also in movieplayerfinished and previous
            //or, alternatively in stopmovieplayer.
            
        }
        
        //next item is a movie - play it
        if (nextMoviePlayer != nil){
            [self stop];
            
            NSLog(@"NEXT - playing nextMovie (moviePlayer1)");
            
            //this can be done in animationFinished
            nextMoviePlayer.controlStyle = MPMovieControlStyleNone;
            [nextMoviePlayer play];
            
            currentMoviePlayer = nextMoviePlayer;
            
            if (moviePlayer2 != nil){
                NSLog(@"NEXT - MEdiaPlayer2 has something");
                nextMoviePlayer = moviePlayer2;
                moviePlayer2 = nil;
            }
            else{
                nextMoviePlayer = nil;
            }
        }
        
        [self performTransition];
    }	
}



#pragma mark - Button Actions

- (void)playAction
{
    if (currentMoviePlayer){
        [currentMoviePlayer play ];
    }else{
        [self start];
    }
    
    [self flashPlayOverlay];
    [self hideBars];
}


- (void)pauseAction
{
    if (currentMoviePlayer){
        [currentMoviePlayer pause];
    }else{
        [self stop];
    }
    
    [self flashPauseOverlay];
    [self showBars];
}


- (void)previousAction
{
    [self previous];
    [self showBars];
}


- (void)nextAction
{
    [self next];
    [self showBars];
}


- (void)doneAction
{    
    [self stop];
    [self showBars];
	[[self navigationController] popViewControllerAnimated:NO];
}



#pragma mark - Tap/Gesture Delegates

- (void)gotSingleTapAtPoint:(CGPoint)tapPoint 
{
	NSLog(@"SlideShow SINGLE TAP");
    
    //single tap on right side - next slide or video
    if (tapPoint.x > self.view.frame.size.width * 0.75){
        [self next];
        [self hideBars];
        return;
    }
    
    //single tap on left side - previous slide or video
    if (tapPoint.x < self.view.frame.size.width * 0.25){
        [self previous];
        [self hideBars];
        return;
    }
    
    //center - show movieprogress or bars
    if (currentMoviePlayer){
        //[currentMoviePlayer endSeeking];
        [self stopSeekingCurrentMoviePlayer];
        [self showMovieProgress];
    }
    else{
        if (! [self showBars]) [self hideBars];
    }
}


- (void)gotDoubleTapAtPoint:(CGPoint)tapPoint
{
	NSLog(@"SlideShow DOUBLE");
    //show/hide bars
    if (! [self showBars]) [self hideBars];  
}


- (void)gotTwoFingerTapAtPoint:(CGPoint)tapPoint
{
	NSLog(@"SlideShow TWO FINGER");
}


- (void)gotSwipeLeft
{
    NSLog(@"SlideShow SWIPE LEFT");
    // seek movie backwards
    if (currentMoviePlayer){
        //[currentMoviePlayer beginSeekingBackward];
        [self seekCurrentMoviePlayerBackward];
        [self showMovieProgress];
    }
}


- (void)gotSwipeRight
{
    NSLog(@"SlideShow SWIPE RIGHT");
    // seek movie forward
    if (currentMoviePlayer){
        //[currentMoviePlayer beginSeekingForward];
        [self seekCurrentMoviePlayerForward];
        [self showMovieProgress];
    }
}



#pragma mark - Stopping and Releasing a MoviePlayer

- (void)stopMoviePlayer:(MPMoviePlayerController **)mPlayer releaseImmediately:(BOOL)releaseImmediately
{
    NSLog(@"Stopping and releasing movie player");
    
    //remove from notification center, to avoid callback loops
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:(*mPlayer)];
    
    //testing - doing stop blacks out the video screen
    [(*mPlayer) pause];
    //(*mPlayer).initialPlaybackTime = -1;
    //[(*mPlayer) stop ];
    
    if (releaseImmediately){
        [(*mPlayer) release ];
    }
    else{
        moviePlayerToRelease = (*mPlayer);
    }
    (*mPlayer) = nil;
}


#pragma mark - Notification Delegates

- (void)moviePlayerFinished:(NSNotification*)notification
{
    NSLog(@"Movie Player FINISHED");
    
//    MPMoviePlayerController *mp = [notification object];
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:MPMoviePlayerPlaybackDidFinishNotification
//                                                  object:mp];
//    mp.initialPlaybackTime = -1.0;
//    [mp stop];
//    moviePlayerToRelease = mp;
//    currentMoviePlayer = nil;
    
    
    
    [self stopMoviePlayer:&currentMoviePlayer releaseImmediately:NO];
    
    // this is for regular slideshow flow
    [self start];
    [self next];
}


- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    NSLog(@"transition finished");
    
    //this can be done here instead of in next
//    if (currentMoviePlayer){
//        currentMoviePlayer.controlStyle = MPMovieControlStyleNone;
//        [currentMoviePlayer play];
//    }
    
	[self loadNextItem];
    transitioning = NO;
}



#pragma mark - Movie Touch Control
- (void)forwardCurrentMoviePlayerBy:(NSUInteger)seconds{
	if (currentMoviePlayer.currentPlaybackTime + seconds > currentMoviePlayer.duration){
    	currentMoviePlayer.currentPlaybackTime = currentMoviePlayer.duration;
        //or next
    }
    else{
        currentMoviePlayer.currentPlaybackTime += seconds;
    }
}



- (void)rewindCurrentMoviePlayerBy:(NSUInteger)seconds{
	if (currentMoviePlayer.currentPlaybackTime - seconds < 0){
    	currentMoviePlayer.currentPlaybackTime = 0;
        //or previous
    }
    else{    
    	currentMoviePlayer.currentPlaybackTime -= seconds;
    }  
}



- (void)seekCurrentMoviePlayerForward
{
    // is it seeking backward?
    if ( currentMoviePlayer.currentPlaybackRate < 0){
        currentMoviePlayer.currentPlaybackRate = 1.0;
    }
    else{
        currentMoviePlayer.currentPlaybackRate += kVideoSeekInc;
        NSLog(@"seeking forward at: %f", currentMoviePlayer.currentPlaybackRate);
    }
}



- (void)seekCurrentMoviePlayerBackward
{
    // is it seeking forward?
    if ( currentMoviePlayer.currentPlaybackRate > 1.0){
        currentMoviePlayer.currentPlaybackRate = 1.0;
    }
    else{
        currentMoviePlayer.currentPlaybackRate -= kVideoSeekInc;
        NSLog(@"seeking backward at: %f", currentMoviePlayer.currentPlaybackRate);
    }
}



- (void)stopSeekingCurrentMoviePlayer
{
    //is it seeking?
    if (currentMoviePlayer.currentPlaybackRate > 1.0 || currentMoviePlayer.currentPlaybackRate < 0){
        currentMoviePlayer.currentPlaybackRate = 1.0;
    }
}




@end
