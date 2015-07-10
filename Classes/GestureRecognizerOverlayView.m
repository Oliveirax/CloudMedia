//
//  TDOverlay.m
//  Xmedia
//
//  Created by Luis Filipe Oliveira on 1/25/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "GestureRecognizerOverlayView.h"

// private interface
@interface GestureRecognizerOverlayView()

- (void)handleSingleTap:(id)sender;
- (void)handleDoubleTap:(id)sender;
- (void)handleLongTap:(id)sender;
- (void)handleSwipeLeft:(id)sender;
- (void)handleSwipeRight:(id)sender;

@end

@implementation GestureRecognizerOverlayView

@synthesize delegate;


#pragma mark - Init and Dealloc
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = YES;
        self.exclusiveTouch = YES;
        
        // if alpha is 0, it won't process touches - weird. 
        // 0.005 is an alpha value that does not draw anything, but enables touches 
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.005];
        
        //gesture recognizers
        UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self 
                                                                                                    action:@selector(handleDoubleTap:)];
        doubleTapGestureRecognizer.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTapGestureRecognizer];
        
        
        
        UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self 
                                                                                                    action:@selector(handleSingleTap:)];
        singleTapGestureRecognizer.numberOfTapsRequired = 1;
        [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
        [self addGestureRecognizer:singleTapGestureRecognizer];
        
        
        
        UISwipeGestureRecognizer *swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self 
                                                                                                          action:@selector(handleSwipeRight:)];
        swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:swipeRightGestureRecognizer];
        
        
        
        UISwipeGestureRecognizer *swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self 
                                                                                                         action:@selector(handleSwipeLeft:)];
        swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:swipeLeftGestureRecognizer];
        
        
        
        [singleTapGestureRecognizer release];
        [swipeLeftGestureRecognizer release];
        [swipeRightGestureRecognizer release];
        [doubleTapGestureRecognizer release];
    }
    return self;
}


#pragma mark - Gesture Actions

- (void)handleSingleTap:(id)sender
{
    UITapGestureRecognizer * tgr = (UITapGestureRecognizer *)sender;
//    NSLog(@"GR SINGLE TAP in %f ,%f", [tgr locationInView:self].x, [tgr locationInView:self].y );
//    NSLog(@"GR FRAME is %f ,%f", self.frame.size.width, self.frame.size.height );
    
    if ([delegate respondsToSelector:@selector(gotSingleTapAtPoint:)])
        [delegate gotSingleTapAtPoint:[tgr locationInView:self]];
}


- (void)handleDoubleTap:(id)sender
{
    UITapGestureRecognizer * tgr = (UITapGestureRecognizer *)sender;
//    NSLog(@"GR DOUBLE TAP in %f ,%f", [tgr locationInView:self].x, [tgr locationInView:self].y );
    
    if ([delegate respondsToSelector:@selector(gotDoubleTapAtPoint:)])
        [delegate gotDoubleTapAtPoint:[tgr locationInView:self]];

}

- (void)handleLongTap:(id)sender
{

}


- (void)handleSwipeLeft:(id)sender
{
    [delegate gotSwipeLeft];
    UISwipeGestureRecognizer *recognizer = (UISwipeGestureRecognizer *) sender;
    
    CGPoint point = [recognizer locationOfTouch:0 inView:self];
    NSLog(@"swipe left ( %f , %f )", point.x, point.y);
    
    //[recognizer ]
    
    /*
    CGPoint firstPoint = [[recognizer firstTouch] locationInView:self];
    CGPoint lastPoint = [[recognizer lastTouch] locationInView:self];
    CGFloat distance = ...; // the distance between firstPoint and lastPoint
    NSTimeInterval elapsedTime = [[recognizer lastTouch] timestamp] - [[recognizer firstTouch] timestamp];
    CGFloat velocity = distance / elapsedTime;
    
    NSLog(@"the velocity of the swipe was %f points per second", velocity);
     */
}
- (void)handleSwipeRight:(id)sender
{
    [delegate gotSwipeRight];
    UISwipeGestureRecognizer *recognizer = (UISwipeGestureRecognizer *) sender;
    CGPoint point = [recognizer locationOfTouch:0 inView:self];
    NSLog(@"swipe right ( %f , %f )", point.x, point.y);
}



@end
