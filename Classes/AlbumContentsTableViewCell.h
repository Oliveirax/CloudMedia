



extern NSString *const AlbumContentsTableViewCellIdentifier;

@class AlbumContentsTableViewCell;
@class ThumbnailView;


@interface AlbumContentsTableViewCell : UITableViewCell 
<CellItemTapDelegate,
MultipleItemTableViewCell> {

	NSArray *items;
    NSUInteger row;
    id <MultipleItemTableViewCellTapDelegate> tapDelegate;
}

@property (nonatomic, assign) NSUInteger row;
@property (nonatomic, assign) id<MultipleItemTableViewCellTapDelegate> tapDelegate;
@property (nonatomic, retain) NSArray *items;

- (id)init;
@end
