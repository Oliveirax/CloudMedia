//
// File:       PhotoDisplayViewController.h
//
// Abstract:   View controller to manage displaying a photo or a video.
//


@interface MediaDisplayViewController : UIViewController<UIScrollViewDelegate, TapDelegate> {
    
	NSMutableArray *assets;
	NSInteger currentIndex;
	
	UIScrollView *pagingScrollView;
    NSMutableSet *recycledPages;
    NSMutableSet *visiblePages;
	
	NSArray *toolbarButtons;
}

- (id)initWithAssets:(NSMutableArray *)theAssets startingIndex:(NSInteger)index;
- (void)playAction;

@end
