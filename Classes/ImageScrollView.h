//
//  ImageScrollView.h
//  Xmedia
//
//  Created by Luis Filipe Oliveira on 1/17/11.
//

@class TapDetectingImageView;

@interface ImageScrollView : UIScrollView <UIScrollViewDelegate, TapDelegate>{

	TapDetectingImageView *image;
	id <TapDelegate> tapDelegate;
	NSUInteger     index;	
	BOOL zoomEnabled;
}

@property (nonatomic, assign) id <TapDelegate> tapDelegate;
@property (nonatomic, retain) TapDetectingImageView *image;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) BOOL zoomEnabled;

- (void)zoomToMinimumScaleAnimated:(BOOL)animated;
- (void)centerContentViewAnimated:(BOOL)animated;
- (void)computeMinimumZoomScale;
- (void)releaseMedia;
@end
