//
//  ImageScrollView.m
//  Xmedia
//
//  Created by Luis Filipe Oliveira on 1/17/11.
//

#import "ImageScrollView.h"
#import "TapDetectingImageView.h"

#define ZOOM_STEP 1.5
#define MAX_ZOOM 2

@interface ImageScrollView ()
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;
@end


@implementation ImageScrollView

@synthesize tapDelegate;
@synthesize image;
@synthesize index;
@synthesize zoomEnabled;


#pragma mark -
#pragma mark init and dealloc

- (id)init {
    
    self = [super init];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.0]];
		[self setDelegate:self];
		self.bouncesZoom = YES;
		image = nil;
		zoomEnabled = YES;
    }
    return self;
}



- (void)dealloc {
	
	[self releaseMedia];
    [super dealloc];
}



#pragma mark -
#pragma mark public methods

- (void)setFrame:(CGRect)rect{
	//NSLog(@"imageScrollView setFrame");
	[super setFrame:rect];
	[self computeMinimumZoomScale];
	// for rotations. in case you rotate from portrait to landscape, and the picture is fully
	// zoomed out, zoom in so that the picture fills the entire screen
	
	if (self.zoomScale < self.minimumZoomScale || !zoomEnabled){
		[self zoomToMinimumScaleAnimated:YES];
	}
	else {
		[self centerContentViewAnimated:YES];
	}
	
	//NSLog(@"ImageSV Frame: %f, %f, %f, %f,",rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
	
}



- (void)setImage:(TapDetectingImageView *)img{
		
	image = [img retain]; 
	
	[self setContentSize:[image frame].size];
	[self addSubview:image];
	[image setDelegate:self];
	[self computeMinimumZoomScale];
	// when setting an image, we want it totally zoomed out
	if (self.zoomScale > self.minimumZoomScale || !zoomEnabled){
		[self zoomToMinimumScaleAnimated:NO];
	}
	else{
		[self centerContentViewAnimated:NO];
	}
}



- (void)releaseMedia{
	
	if (image){ 
		[image removeFromSuperview];
		[image release];
		image = nil;
	}
}



// the zoom needed to fill the screen
- (void)computeMinimumZoomScale{
	
    NSLog(@"compute minimum scale!!!");
    
	if(!image || !image.image)return;
	
	float minimumScale;
	
	//display orientation is portrait
	if (self.frame.size.height > self.frame.size.width){
	
		float aspectRatio = image.image.size.height / image.image.size.width;
		
		if ( aspectRatio > 1.5)
			minimumScale = self.frame.size.height / image.image.size.height;
		else 
			minimumScale = self.frame.size.width / image.image.size.width;
	}
	// display orientation is landscape
	else {
		
		float aspectRatio = image.image.size.width / image.image.size.height;
		
		if ( aspectRatio > 1.5)
			minimumScale = self.frame.size.width / image.image.size.width;
		else 
			minimumScale = self.frame.size.height / image.image.size.height;
		
		
	}

	[self setMinimumZoomScale:minimumScale];
	
	if (zoomEnabled) { 
		//if an image is very small, its minimumScale can be bigger than MAX_ZOOM
		[self setMaximumZoomScale:MAX( MAX_ZOOM, minimumScale ) ];
	}
	else{	
		[self setMaximumZoomScale:minimumScale];
	}
		
}


- (void)setZoomEnabled:(BOOL)value{
	zoomEnabled = value;
	[self setBouncesZoom:value];
}


- (void)zoomToMinimumScaleAnimated:(BOOL)animated{
	
    NSLog(@"zoom to minimum scale!!!");
    
	if(!image || !image.image)return;
	
	[self zoomToRect:CGRectMake( 0.0, 0.0, image.image.size.width, image.image.size.height) animated:animated];
}


- (void)centerContentViewAnimated:(BOOL)animated{

	NSLog(@"center content view!!!");
	// center 
    CGFloat offsetX = (self.bounds.size.width > self.contentSize.width)? 
	(self.bounds.size.width - self.contentSize.width) * 0.5 : 0.0;
    
	CGFloat offsetY = (self.bounds.size.height > self.contentSize.height)? 
	(self.bounds.size.height - self.contentSize.height) * 0.5 : 0.0;
	
		
	
	if (animated) {
		[UIView animateWithDuration:0.3 
						 animations: ^{ 
							 image.center = CGPointMake(self.contentSize.width * 0.5 + offsetX, self.contentSize.height * 0.5 + offsetY);
						 } 
						 completion: nil
		 ];
	}
	else{
		image.center = CGPointMake(self.contentSize.width * 0.5 + offsetX, self.contentSize.height * 0.5 + offsetY);
	}
	
}


#pragma mark -
#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return image;
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	//NSLog(@"scroll view end drag");
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
	//NSLog(@"scroll view begin drag");
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
	
	[self centerContentViewAnimated:NO];
	
}




#pragma mark -
#pragma mark TapDetectingImageViewDelegate methods

- (void)gotSingleTapAtPoint:(CGPoint)tapPoint {
	
	if ([tapDelegate respondsToSelector:@selector(gotSingleTapAtPoint:)])
        [tapDelegate gotSingleTapAtPoint:tapPoint];
}

- (void)gotDoubleTapAtPoint:(CGPoint)tapPoint {
    // double tap zooms in
    if (self.zoomScale == self.maximumZoomScale ) return;
	float newScale = [self zoomScale] * ZOOM_STEP;
	
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:tapPoint];
    [self zoomToRect:zoomRect animated:YES];
}

- (void)gotTwoFingerTapAtPoint:(CGPoint)tapPoint {
    // two-finger tap zooms out
	if (self.zoomScale == self.minimumZoomScale ) return;
    float newScale = [self zoomScale] / ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:tapPoint];
    [self zoomToRect:zoomRect animated:YES];
}



#pragma mark -
#pragma mark Utility methods

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates. 
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [self frame].size.height / scale;
    zoomRect.size.width  = [self frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

@end
