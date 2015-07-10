//
// ThumbnailImageView.m
//
// Xmedia
//
//  Created by Luis Filipe Oliveira on 8/4/11.
//


#import "ThumbnailView.h"

// private interface
@interface ThumbnailView()
//- (void)createWhiteHighlightImageViewIfNecessary;
//- (void)createBlackHighlightImageViewIfNecessary;
//- (void)createSelectedBadgeViewIfNecessary;
- (void)setHighlighted:(BOOL)highlighted;
- (void)handleSingleTap;
- (void)handleLongTap;
- (NSString *)seconds2HMS:(CGFloat)seconds;


@property(nonatomic, retain)UILabel *durationLabel;

@end



@implementation ThumbnailView

@synthesize tapDelegate;
@synthesize selected;
@synthesize index;

@synthesize durationLabel = _durationLabel;


#pragma mark - init and dealloc
- (id)initWithIndex:(NSUInteger)_index{
    self = [super initWithFrame:CGRectMake(0,0,75,75)];
    if (self) {
        
        
        self.exclusiveTouch = YES; // to prevent touching two thumbs and pushing two view controllers
        
        // touch area test
        //        UIView *background = [[UIView alloc ]initWithFrame:CGRectMake(0, 0, 75,75)];
        //        background.backgroundColor = [UIColor yellowColor];
        //        [self addSubview:background];
        
        
        // the checked/unchecked/highlighted imageViews
       
        thumbnailImageView = [[UIImageView alloc ]initWithImage:nil];
        thumbnailImageView.alpha = 1.0;
        //[thumbnailImageView setCenter:CGPointMake(22,22)];
        [thumbnailImageView setFrame:CGRectMake(0,0,75,75)];
        [self addSubview:thumbnailImageView];
        
        //duration label
		_durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
		_durationLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
		_durationLabel.textColor = [UIColor whiteColor];
		_durationLabel.font = [UIFont systemFontOfSize:10];
		_durationLabel.textAlignment = UITextAlignmentCenter;
        _durationLabel.text = @"0:00:00";
        _durationLabel.hidden = YES;
        [self addSubview:_durationLabel];

        
        UIImage *image = [UIImage imageNamed:@"BlackHighlight"];
        highlightedImageView = [[UIImageView alloc ]initWithImage:image];
        highlightedImageView.alpha = 0.0;
        //[highlightedImageView setCenter:CGPointMake(22,22)];
        [highlightedImageView setFrame:CGRectMake(0,0,75,75)];
        [self addSubview:highlightedImageView];
        
        UIImage *image2 = [UIImage imageNamed:@"TickChecked"];
        checkedImageView = [[UIImageView alloc ]initWithImage:image2];
        checkedImageView.alpha = 0.0;
        [checkedImageView setCenter:CGPointMake(22,22)];
        [self addSubview:checkedImageView];
        
        
        // the gesture recognizers
        UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap)];
        singleTapGestureRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTapGestureRecognizer];
        
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongTap)];
        [self addGestureRecognizer:longPressGestureRecognizer];
        
        [singleTapGestureRecognizer release];
        [longPressGestureRecognizer release];

        longTapActive = NO;
        selected = NO;
        index = _index;
    }
	return self;
}



- (void)dealloc {
    //if (blackHighlightView)[blackHighlightView release];
	//if (whiteHighlightView)[whiteHighlightView release];
    //if (selectedBadgeView)[selectedBadgeView release];
    [thumbnailImageView release];
    [highlightedImageView release];
    [checkedImageView release];
    
    self.durationLabel = nil;
    
    [super dealloc];
}



#pragma mark - Touch handling


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setHighlighted:YES];
	NSLog(@"ThumbnailView TOUCHES BEGAN");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setHighlighted:NO];
    //[tapDelegate tappedItemWithIndex:index];
    NSLog(@"ThumbnailView TOUCHES ENDED");
}



- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setHighlighted:NO];
    NSLog(@"ThumbnailView TOUCHES CANCELLED");
}

- (void)handleSingleTap
{
    NSLog(@"ThumbnailView SINGLE TAP");
    //[self setHighlighted:NO]; //single tap fails to send touches ended if you press for too long
    [tapDelegate tappedItemWithIndex:index];
}


- (void)handleLongTap
{
    NSLog(@"ThumbnailView LONG TAP");
    
    if(longTapActive){
        longTapActive = NO;
        [self setHighlighted:NO];
        NSLog(@"LongTapActive = NO");
        
    }
    else{
        longTapActive = YES;
        [tapDelegate longTappedItemWithIndex:index];
         NSLog(@"LongTapActive = YES");
    }
    
}



//- (void)clearHighlight {
//    [blackHighlightView removeFromSuperview];
//	//[selectedBadgeView removeFromSuperview];
//}
//
//
//
//- (void)setSelected:(BOOL)value{
//	
//	//NSLog(@"thumb was Selected");
//	
//	// change nothing
//	if (selected == value) return;
//		
//	selected = value;
//	
//	if(selected){
//		//[self createWhiteHighlightImageViewIfNecessary];
//		[self createSelectedBadgeViewIfNecessary];
//		//[self addSubview:whiteHighlightView];
//		[self addSubview:selectedBadgeView];
//	}
//	else{
//		[selectedBadgeView removeFromSuperview];
//		//[whiteHighlightView removeFromSuperview];
//	}
//}


#pragma mark - Property setters

- (void)setImage:(UIImage *)image
{
    [thumbnailImageView setImage:image];
}


- (void)setDuration:(CGFloat)duration
{
    if ( duration == -1){
        self.durationLabel.hidden = YES;
    }
    else{
        self.durationLabel.text = [self seconds2HMS:duration];
        self.durationLabel.hidden = NO;
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


- (void)setSelected:(BOOL)_selected
{
    selected = _selected;
    
    if( selected){
        
        [UIView animateWithDuration:0.3 
                         animations: ^{ 
                             checkedImageView.alpha = 1.0;
                             //uncheckedImageView.alpha = 0.0;
                         } 
                         completion:nil];
    }
    else{
        
        [UIView animateWithDuration:0.3 
                         animations: ^{ 
                             checkedImageView.alpha = 0.0;
                             //uncheckedImageView.alpha = 1.0;
                         } 
                         completion:nil];
    }
}


#pragma mark - Helper methods

- (void)setHighlighted:(BOOL)highlighted
{
    if(highlighted){
        highlightedImageView.alpha = 0.5;
    }
    else{
        highlightedImageView.alpha = 0.0;
    }
}




//- (void)createBlackHighlightImageViewIfNecessary {
//    if (!blackHighlightView) {
//        UIImage *thumbnailHighlight = [UIImage imageNamed:@"BlackHighlight"];
//        blackHighlightView = [[UIImageView alloc] initWithImage:thumbnailHighlight];
//        [blackHighlightView setAlpha: 0.5];
//    }
//}


/*
- (void)createWhiteHighlightImageViewIfNecessary {
    if (!whiteHighlightView) {
        UIImage *thumbnailHighlight = [UIImage imageNamed:@"WhiteHighlight"];
        whiteHighlightView = [[UIImageView alloc] initWithImage:thumbnailHighlight];
        [whiteHighlightView setAlpha: 0.5];
    }
}
*/

//- (void)createSelectedBadgeViewIfNecessary {
//    if (!selectedBadgeView) {
//        UIImage *tickBadge = [UIImage imageNamed:@"TickChecked"];
//        selectedBadgeView = [[UIImageView alloc] initWithImage:tickBadge];
//		//selectedBadgeView.frame = 
//        //[highlightView setAlpha: 0.5];
//    }
//}

@end
