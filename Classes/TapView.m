//
//  TapDetectingView.m
//  Xmedia
//
//  Created by Luis Oliveira on 1/28/13.
//  Copyright (c) 2013 EVOLVE Space Solutions. All rights reserved.
//

#import "TapView.h"

@interface TapView()

@end


@implementation TapView

@synthesize tapDelegate = _tapDelegate;
@synthesize index = _index;
@synthesize tapGestureRecognizer = _tapGestureRecognizer;
@synthesize lpGestureRecognizer = _lpGestureRecognizer;


- (id)initWithFrame:(CGRect)frame andIndex:(NSUInteger)index
{
    self = [super initWithFrame:frame];
    if (self) {
       
        _index = index;
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
        
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap)];
        _tapGestureRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:_tapGestureRecognizer];
		
		_lpGestureRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongTap)];
        [self addGestureRecognizer:_lpGestureRecognizer];
    }
    return self;
}

- (void)dealloc{
	self.tapGestureRecognizer = nil;
	self.lpGestureRecognizer = nil;
	[super dealloc];
}


#pragma mark - Gesture handling

- (void)handleSingleTap;
{
    NSLog(@"TDV tapped");
    [_tapDelegate tappedItemWithIndex:_index];
}



- (void)handleLongTap
{
	//this boolean is necessary, since long tap sends two events
    //otherwise, range selection does not work, it selects and then deselects.
	static BOOL longTapActive;
	
    NSLog(@"TDV long tapped");
	
    
    if(longTapActive){
		NSLog(@"TDV long tap OFF");
        longTapActive = NO;
    }
    else{
		NSLog(@"TDV long tap ON");
        longTapActive = YES;
        [_tapDelegate longTappedItemWithIndex:_index];
    }
}



#pragma mark - Touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    [self setHighlighted:YES];
	NSLog(@"TDV TOUCHES BEGAN");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
    [self setHighlighted:NO];
    NSLog(@"TDV TOUCHES ENDED");
}



- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event 
{
    [self setHighlighted:NO];
    NSLog(@"TDV TOUCHES CANCELLED");
}


#pragma mark - highlight

- (void)setHighlighted:(BOOL)highlighted
{
	if(highlighted){
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];    
	}
    else{
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];    }
}


@end
