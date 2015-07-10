//
// ThumbnailImageView.h
//  Xmedia
//
//  Created by Luis Filipe Oliveira on 8/4/11.
//

@interface ThumbnailView : UIView {

    BOOL selected;
	NSUInteger index;
    UIImageView *checkedImageView;
    UIImageView *highlightedImageView;
    UIImageView *thumbnailImageView;
    id <CellItemTapDelegate> tapDelegate;
    
    BOOL longTapActive;
    
    //UIImageView *blackHighlightView;
	//UIImageView *whiteHighlightView;
	//UIImageView *selectedBadgeView;
	
    //id <ThumbnailImageViewSelectionDelegate> delegate;
}

@property (nonatomic, assign) id<CellItemTapDelegate> tapDelegate;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) NSUInteger index;

- (id)initWithIndex:(NSUInteger)index;
- (void)setImage:(UIImage *)image;
- (void)setDuration:(CGFloat)duration; //set the movie duration in seconds. invoke with -1 for images

//@property(nonatomic, assign) id<ThumbnailImageViewSelectionDelegate> delegate;
//@property(nonatomic, assign) BOOL selected;
//@property(nonatomic, assign) NSInteger index;

//- (id)init;
//- (void)clearHighlight;

@end
