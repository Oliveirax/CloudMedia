//
//  AlbumsTableViewCell.h
//  Xmedia
//
//  Created by Luis Filipe Oliveira on 6/9/11.
//


extern NSString *const AlbumsTableViewCellIdentifier;

// constants to identify this cell's clickable items
extern NSUInteger const AlbumsTableViewCellCheckMark;
extern NSUInteger const AlbumsTableViewCellImage;
extern NSUInteger const AlbumsTableViewCellTitle;



@interface AlbumsTableViewCell : UITableViewCell 
<CellItemTapDelegate,
MultipleItemTableViewCell>


//@property(nonatomic, assign)BOOL checked;
@property(nonatomic, assign)id <MultipleItemTableViewCellTapDelegate> tapDelegate;


- (id)init;
- (void)setPosterImage:(UIImage *)image;
- (void)setTitle:(NSString *)text;
- (void)setNumberOfItems:(NSUInteger)items;
- (void)setNumberOfAlbums:(NSUInteger)albums;

@end
