//
//  TapDetectingView.h
//  Xmedia
//
//  Created by Luis Oliveira on 1/28/13.
//  Copyright (c) 2013 EVOLVE Space Solutions. All rights reserved.
//



@interface TapView : UIView

@property (nonatomic, assign) id<CellItemTapDelegate> tapDelegate;
@property (nonatomic, assign) NSUInteger index;

// this view's Gesture Recognizers are here to be configured/removed by subclasses
@property (nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, retain) UILongPressGestureRecognizer *lpGestureRecognizer;

- (id)initWithFrame:(CGRect)frame andIndex:(NSUInteger)index;
- (void)setHighlighted:(BOOL)highlighted;
- (void)handleSingleTap;
- (void)handleLongTap;


@end
