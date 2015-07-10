//
// File:       MediaDisplayViewController.m
//
// Abstract:   View controller to manage displaying a photo or a video.
//
// 

#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MPMoviePlayerViewController.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import <QuartzCore/QuartzCore.h>

#import "MediaDisplayViewController.h"
#import "ImageScrollView.h"
#import "SlideShowViewController.h"
#import "PlayButtonImageView.h"
#import "TapDetectingImageView.h"
#import "AssetsGroup.h"
#import "Asset.h"
#import "LibraryManager.h"



#define PLAY_BUTTON_TAG 2000

#define ZOOM_STEP 1.5
#define kFadeDelay 0.3
#define kAutoHideDelay 5
#define PADDING  20
#define EXTRA  0

@interface MediaDisplayViewController (UtilityMethods)
- (void)showBars;
- (void)hideBars;
- (void)hideBarsHelper;

- (void)adjustSizeForLandscape;
- (void)adjustSizeForPortrait;

- (void)setPagesInView;
- (ImageScrollView *)dequeueRecycledPage;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;
- (void)configurePage:(ImageScrollView *)page forIndex:(NSUInteger)index;
- (void)configurePageInBackground:(ImageScrollView *)page;

- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;

- (void)moviePlayerFinished:(NSNotification*)notification;

@end



@implementation MediaDisplayViewController

#pragma mark -
#pragma mark init and dealloc

- (id)initWithAssets:(NSMutableArray *)theAssets startingIndex:(NSInteger)index{
	if ((self = [super init])) {
		
		self.wantsFullScreenLayout = YES;
		assets = [theAssets retain];
		currentIndex = index;
		self.title = [NSString stringWithFormat: @"%d of %d", currentIndex+1, assets.count ];
		
		// toolbar buttons
		UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem* playButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playAction)];
	
		toolbarButtons = [[NSArray alloc]initWithObjects:flexibleSpace, playButton, flexibleSpace, nil];
		
		[flexibleSpace release];
		[playButton release];
		
				
			
	}
	return self;
}



- (void)dealloc {
	NSLog(@"media display release");

	[assets release];
	[pagingScrollView release];
	[recycledPages release];
	[visiblePages release];
    [super dealloc];
}



#pragma mark -
#pragma mark View lifecycle

- (void)loadView{
	
	// background view, should be a tapdetecting view
	UIView * backgroundView = [[UIView alloc] init];
	//NSString *path = [[NSBundle mainBundle] pathForResource:@"metal5" ofType:@"png"];
	//backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:path]];
	backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"metal"]];
    self.view = backgroundView;
	[backgroundView release];
	
	// pages
    recycledPages = [[NSMutableSet alloc] init];
    visiblePages  = [[NSMutableSet alloc] init];

	
	// paging scrollview
	CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
	pagingScrollView = [[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];
	pagingScrollView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
	pagingScrollView.pagingEnabled = YES;
	pagingScrollView.showsVerticalScrollIndicator = NO;
    pagingScrollView.showsHorizontalScrollIndicator = NO;
    pagingScrollView.contentSize = CGSizeMake(pagingScrollViewFrame.size.width * assets.count,pagingScrollViewFrame.size.height);
	pagingScrollView.contentOffset = CGPointMake(currentIndex * pagingScrollView.bounds.size.width,0);
    pagingScrollView.delegate = self;
    [self.view addSubview:pagingScrollView];

	[self setPagesInView];
}



- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	NSLog(@"MediaDisplayViewController did Appear");
	
	
	
    //[self.navigationController.toolbar setItems:toolbarButtons animated:YES];
    [self setToolbarItems:toolbarButtons animated:YES];
    [self showBars];
	
	if (self.interfaceOrientation == UIInterfaceOrientationPortrait){ 
		[self adjustSizeForPortrait];
	}
	else{
		[self adjustSizeForLandscape];
	}
    
    NSLog(@"MediaDisplayViewController finished Appearing");
}



- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	NSLog(@"MediaDisplayViewController did Disappear");
	
	//cancel the request to hide the bars after a while
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}



#pragma mark -
#pragma mark page configuration

- (void)setPagesInView 
{
    // Calculate which pages are visible
	// the bounds Rect origin coordinates are the same as contentOffset 
    CGRect visibleBounds = pagingScrollView.bounds;
    int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
    firstNeededPageIndex = MAX(firstNeededPageIndex - EXTRA, 0);
    lastNeededPageIndex  = MIN(lastNeededPageIndex + EXTRA, assets.count - 1);
	
	//NSLog(@"set pages: %d %d", firstNeededPageIndex, lastNeededPageIndex);
	//NSLog(@"bounds: %f %f %f %f", visibleBounds.origin.x, visibleBounds.origin.y, visibleBounds.size.width, visibleBounds.size.height);
	//NSLog(@"offset: %f", pagingScrollView.contentOffset.x);
    
	// Recycle no-longer-visible pages 
    for (ImageScrollView *page in visiblePages) {
        if (page.index < firstNeededPageIndex || page.index > lastNeededPageIndex) {
			
			
			
			
			[page releaseMedia];
            
			
			
			[recycledPages addObject:page];
            [page removeFromSuperview];
        }
    }
    [visiblePages minusSet:recycledPages];
    
    // add missing pages
    for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
            ImageScrollView *page = [self dequeueRecycledPage];
            if (page == nil) {
                page = [[[ImageScrollView alloc] init] autorelease];
				page.tapDelegate = self;
            }
            [self configurePage:page forIndex:index];
            [pagingScrollView addSubview:page];
            [visiblePages addObject:page];
        }
    }
}



- (ImageScrollView *)dequeueRecycledPage
{
    ImageScrollView *page = [recycledPages anyObject];
    if (page) {
        [[page retain] autorelease];
        [recycledPages removeObject:page];
    }
    return page;
}



- (BOOL)isDisplayingPageForIndex:(NSUInteger)index
{
    BOOL foundPage = NO;
    for (ImageScrollView *page in visiblePages) {
        if (page.index == index) {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}



- (void)configurePage:(ImageScrollView *)page forIndex:(NSUInteger)index
{
    NSLog(@"configure page for index: %d",index);
    
    page.index = index;
    page.frame = [self frameForPageAtIndex:index];
	
	Asset *asset = [assets objectAtIndex:index];
	
	TapDetectingImageView *tdiv = [[TapDetectingImageView alloc] initWithImage:[asset image]];
    [page setImage:tdiv];
	
	if ([asset.type isEqualToString:kAssetTypeImage]){
		[page setZoomEnabled:YES]; // zoom photos
	}
	else if ([asset.type isEqualToString:kAssetTypeVideo] ){
		
		//[page setZoomEnabled:NO]; // don't zoom videos
		
		// add a play button for videos
		PlayButtonImageView *playButtonImageView = [[PlayButtonImageView alloc]init];
		playButtonImageView.tag = PLAY_BUTTON_TAG;
		playButtonImageView.delegate = self;
		playButtonImageView.center = tdiv.center;
		[tdiv addSubview:playButtonImageView];
        [playButtonImageView release];
	}
	else{
		NSLog(@"Warning: MDVC - configurePage failed: Unknown asset type");
	}
    
    [tdiv release];
}



#pragma mark - Frame calculations

- (CGRect)frameForPagingScrollView {

	CGRect frame;
	if (self.interfaceOrientation == UIInterfaceOrientationPortrait){ 
		frame = CGRectMake(0,0,320,480);
	}
	else{
		frame = CGRectMake(0,0,480,320);
	}
	
	//NSLog(@"pgsv frame: %f %f", frame.size.width, frame.size.height);
    
	frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    
	return frame;
}



- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    
	CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    CGRect pageFrame = [self frameForPagingScrollView];
    
	pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (pagingScrollViewFrame.size.width * index) + PADDING;
    
	return pageFrame;
}



#pragma mark -
#pragma mark handling rotations

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
			interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
			interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}



- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
	
	if (interfaceOrientation == UIInterfaceOrientationPortrait) {
		[UIView animateWithDuration: duration animations: ^{ [self adjustSizeForPortrait]; } completion: nil ];
	}
	else{
		[UIView animateWithDuration: duration animations: ^{ [self adjustSizeForLandscape]; } completion: nil ];
	}	 
}



- (void)adjustSizeForLandscape{
	CGRect frame;
	
	frame = CGRectMake(0,0,480,320);
	frame.origin.x -= PADDING;
	frame.size.width += (2 * PADDING);
	
	pagingScrollView.frame = frame;
	pagingScrollView.contentSize = CGSizeMake(pagingScrollView.frame.size.width * assets.count,320);
	pagingScrollView.contentOffset = CGPointMake(currentIndex * pagingScrollView.frame.size.width, 0);
	
	for (ImageScrollView *page in visiblePages) {
		frame = CGRectMake(0,0,480,320);
		frame.origin.x = (pagingScrollView.frame.size.width * page.index) + PADDING;
		page.frame = frame;
	}
}



- (void)adjustSizeForPortrait{
	CGRect frame;
	frame = CGRectMake(0,0,320,480);
	frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
   
	pagingScrollView.frame = frame;
    
   	pagingScrollView.contentSize = CGSizeMake(pagingScrollView.frame.size.width * assets.count,480);
   	pagingScrollView.contentOffset = CGPointMake(currentIndex * pagingScrollView.frame.size.width, 0);
   	
	for (ImageScrollView *page in visiblePages) {
        frame = CGRectMake(0,0,320,480);
		frame.origin.x = (pagingScrollView.frame.size.width * page.index) + PADDING;
		page.frame = frame;
	}
}



#pragma mark -
#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
	
	//NSLog(@"paging view end decelerating");
	
	CGRect visibleBounds = pagingScrollView.bounds;
	currentIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
	self.title = [NSString stringWithFormat: @"%d of %d", currentIndex+1, assets.count ];
		
}
	


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	NSLog(@"ScrollView Did scroll!!!!");
	//[self hideBars];
    [self setPagesInView];
}



#pragma mark  - Tap Delegate 

- (void)gotSingleTapAtPoint:(CGPoint)tapPoint {
	
	// check if the tap was in the play button overlay
	if (tapPoint.x == PLAY_BUTTON_TAG){
	
		// start movie player
		Asset *asset = [assets objectAtIndex:currentIndex];
		MPMoviePlayerViewController *mp = [[MPMoviePlayerViewController alloc] initWithContentURL: [asset url]];
        // Register to receive a notification when the movie has finished playing.  
        [[NSNotificationCenter defaultCenter] addObserver:self  
                                                 selector:@selector(moviePlayerFinished:)  
                                                     name:MPMoviePlayerPlaybackDidFinishNotification  
                                                   object:mp.moviePlayer];
		
        //mp.moviePlayer.controlStyle = MPMovieControlStyleEmbedded; 
        NSLog(@"movieplayer starting... %@",[[asset url] path]);
        
                
		// use this mode to watch the video till the end, no controls.
		//[mp.moviePlayer setControlStyle: MPMovieControlStyleNone];
        //NSLog(@"movieplayer play");
		//[mp.moviePlayer play];
		
		// fade out
		[UIView animateWithDuration:0.3 
						 animations: ^{ 
							 self.navigationController.view.alpha = 0.0;
						 } 
						 completion: ^(BOOL finished) {
							 
							 [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
							 [self.navigationController setNavigationBarHidden:TRUE animated:NO];
							 [self.navigationController setToolbarHidden:TRUE animated:NO];
							 
							 // push movie player
							 [self.navigationController pushViewController:mp animated:NO];
                             NSLog(@"movieplayer push");
                             [mp release];
							 
							 // fade in
							 [UIView animateWithDuration:0.3
											  animations: ^{ 
												  self.navigationController.view.alpha = 1.0;
											  }
											  completion: nil 
							  ];
						 }
		 ];
		
		 
		
	}
	else {
		
		// single tap shows/hides bars
		if ([self.navigationController isNavigationBarHidden] ) {
			[self showBars];
		}
		else {
			[self hideBars];
		}
	}
}



#pragma mark - movie player delegate 

- (void)moviePlayerFinished:(NSNotification*)notification{
	MPMoviePlayerController *mp = [notification object];
    
    NSNumber *reason = [[notification userInfo]objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self  
													name:MPMoviePlayerPlaybackDidFinishNotification  
												  object:mp];  
	
	/*
	// fade to black
	[UIView animateWithDuration:0.5 
					 animations: ^{ 
						 self.navigationController.view.alpha = 0.0;
					 } 
					 completion: ^(BOOL finished) {
						 
						 // pop movie player
						 [ self.navigationController popViewControllerAnimated:NO];
						 
						 // fade in
						 [UIView animateWithDuration:0.5
										  animations: ^{ 
											  self.navigationController.view.alpha = 1.0;
										  }
										  completion: nil 
						  ];
					 }
	 ];
	 */
	
    NSInteger rcode = [reason integerValue];
    NSString *msg;
    
    if (rcode == MPMovieFinishReasonPlaybackEnded) msg = @"movie ended";
    else if (rcode == MPMovieFinishReasonPlaybackError) msg = @"play error";
    else if (rcode == MPMovieFinishReasonUserExited) msg = @"user exited";
    else msg = @"unknown reason";
    
	NSLog(@"movieplayer finished with %d. Reason %@",rcode, msg);
	//crossfade
    /*
	CATransition* transition = [CATransition animation];
	transition.duration = 0.3;
	transition.type = kCATransitionFade;
	//transition.subtype = kCATransitionFromTop;
	
	[self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
	*/
	[ self.navigationController popViewControllerAnimated:NO];
}



#pragma mark -
#pragma mark hide and show bars animations 

- (void)showBars {
	
	if (![self.navigationController isNavigationBarHidden] ) return;
		
	// show status bar
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	
	// show bars and make them transparent
	self.navigationController.navigationBar.alpha = 0.0;
	self.navigationController.toolbar.alpha = 0.0;
	[self.navigationController setNavigationBarHidden:NO animated:NO];
	[self.navigationController setToolbarHidden:NO animated:NO];
	[self.navigationController.toolbar setItems:toolbarButtons animated:NO];
	
    
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
    
}



- (void)hideBars {
	
	if ([self.navigationController isNavigationBarHidden] ) return;
	
	//cancel any previous requests made to hide the bars after a delay
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
	// hide status bar
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	

	//make bars transparent
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
}



#pragma mark -
#pragma mark button actions

// start slideshow
- (void)playAction{
	
	//hide bars
	//[self hideBars];
	
	SlideShowViewController *svc = [[SlideShowViewController alloc] initWithAssets:assets startingIndex:currentIndex];
	
	/*
	//no animation 
	[[self navigationController] pushViewController:svc animated:NO];
	[svc start];
	[svc release];
	 */
	
	
	/*
	// flip 
	[UIView transitionWithView: self.navigationController.view
			duration: 1.0
			options: UIViewAnimationOptionTransitionFlipFromLeft
			animations: ^{ [[self navigationController] pushViewController:svc animated:NO]; }
			completion: ^(BOOL finished){ [svc start]; [svc release]; } ];
	 */
	
	// fade to black
	[UIView animateWithDuration:1.0 
		animations: ^{ 
			self.navigationController.view.alpha = 0.0;
		} 
		completion: ^(BOOL finished) {
			
            //hide bars
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            [self.navigationController setNavigationBarHidden:YES];
			[self.navigationController setToolbarHidden:YES];	

			// push slideshow
			[ self.navigationController pushViewController:svc animated:NO];
            self.navigationController.view.alpha = 1.0;
			[svc release];
		}
	 ];
}
@end
