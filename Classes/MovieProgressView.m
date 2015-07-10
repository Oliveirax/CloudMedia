//
//  MovieProgressView.m
//  xmedia
//
//  Created by Luis Filipe Oliveira on 6/19/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "MovieProgressView.h"
#import <MediaPlayer/MPMoviePlayerController.h>

@interface MovieProgressView()

@property(nonatomic, retain)UIProgressView *movieProgress;
@property(nonatomic, retain)UILabel *rightLabel;
@property(nonatomic, retain)UILabel *leftLabel;
@property(nonatomic, retain)NSTimer *timer;

- (NSString *)seconds2HMS:(CGFloat)seconds;

@end



@implementation MovieProgressView

@synthesize movieProgress = _movieProgress;
@synthesize rightLabel = _rightLabel;
@synthesize leftLabel = _leftLabel;
@synthesize duration = _duration;
@synthesize progress = _progress;
@synthesize orientation = _orientation;
@synthesize moviePlayer = _moviePlayer;
@synthesize timer = _timer;



#pragma mark - init and dealloc

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 10, 0, 0)];
    if (self) {
        NSLog(@"------------- progress init");
        self.userInteractionEnabled = NO;
        self.multipleTouchEnabled = NO;
        self.exclusiveTouch = NO;
        //self.backgroundColor = [UIColor clearColor];
		self.backgroundColor = [UIColor blueColor];
		
		_orientation = UIInterfaceOrientationPortrait;
		
		//overlay progressBar
		_movieProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        _movieProgress.frame = CGRectMake(40,5,240,20);
		
		//overlay labels
		_leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
		_leftLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
		_leftLabel.textColor = [UIColor whiteColor];
		_leftLabel.font = [UIFont systemFontOfSize:10]; 
		_leftLabel.textAlignment = UITextAlignmentCenter;
		//leftLabel.text = [NSString stringWithFormat:@"%1.2f",5];
		_leftLabel.text = @"0:00:00";
		
		_rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(280, 0, 40, 20)];
		_rightLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
		_rightLabel.textColor = [UIColor whiteColor];
		_rightLabel.font = [UIFont systemFontOfSize:10]; 
		_rightLabel.textAlignment = UITextAlignmentCenter;
		//rightLabel.text = [NSString stringWithFormat:@"%1.2f",10];
		_rightLabel.text = @"0:00:00";
        
        [self addSubview:_movieProgress];
        [self addSubview:_leftLabel];
        [self addSubview:_rightLabel];

    }
    return self;
}

- (void)dealloc
{
	self.movieProgress = nil;
	self.rightLabel = nil;
	self.leftLabel = nil;
    [super dealloc];
}


- (void)setMoviePlayer:(MPMoviePlayerController *)moviePlayer
{
    _moviePlayer = moviePlayer;
    if (moviePlayer){
        [self updateProgress];
        //start a thread to update the view
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress) userInfo: nil repeats:YES];
    }
    else{
        [_timer invalidate];
    }
}


- (void)layoutSubviews
{
	//add a breakpoint here
    //NSLog(@"------------- progress layout");
}



- (void)updateProgress
{
    if (!_moviePlayer) return;
    
    CGFloat progress = _moviePlayer.currentPlaybackTime;
    CGFloat duration = _moviePlayer.duration;
    //NSLog(@"------------- progress set %f,%f",progress, duration);
    self.movieProgress.progress = progress/duration;
 	self.leftLabel.text = [self seconds2HMS:progress];
	self.rightLabel.text = [self seconds2HMS:duration];
}




- (void)setOrientation:(UIInterfaceOrientation)orientation
{
	if (self.orientation == orientation) return;
	
	_orientation = orientation;
	
	if (orientation == UIInterfaceOrientationPortrait){
		_movieProgress.frame = CGRectMake(40,5,240,20);
		_leftLabel.frame = CGRectMake(0, 0, 40, 20);
		_rightLabel.frame = CGRectMake(280, 0, 40, 20);
	}
	else{
		_movieProgress.frame = CGRectMake(40,5,400,20);
		_leftLabel.frame = CGRectMake(0, 0, 40, 20);
		_rightLabel.frame = CGRectMake(440, 0, 40, 20);
	}
}


- (NSString *)seconds2HMS:(CGFloat)seconds
{
	NSUInteger secs = (NSUInteger)seconds;
	NSUInteger hours = secs/3600;
	secs%=3600;
	NSUInteger mins = secs/60;
	secs%=60;
	NSString *result = [NSString stringWithFormat:@"%d:%02d:%02d",hours, mins, secs];
	return result;
}

@end
