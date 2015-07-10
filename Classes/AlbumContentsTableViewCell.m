
#import "AlbumContentsTableViewCell.h"
#import "ThumbnailView.h"

NSString *const AlbumContentsTableViewCellIdentifier = @"AlbumContentsTableViewCellIdentifier";

@implementation AlbumContentsTableViewCell

@synthesize row;
@synthesize tapDelegate;
@synthesize items;



- (id)init{
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AlbumContentsTableViewCellIdentifier])) {
        
		// this cell is not selectable, only the thumbs in it
		self.selectionStyle = UITableViewCellSelectionStyleNone;

        
        NSMutableArray *theItems = [[NSMutableArray alloc] init];
        
        for (int i = 0 ; i < 6 ; i++){
            ThumbnailView *tiv = [[ThumbnailView alloc]initWithIndex:i];
            tiv.tapDelegate = self;
            //tiv.index = i;
            [theItems insertObject:tiv atIndex:i];
            
            CGRect frame = CGRectMake( 4 + i*(75+4) ,4, 75, 75);
            [tiv setFrame:frame];
            [self addSubview:tiv];
            
            [tiv release];
        }
        
         self.items = theItems;
        [theItems release];
    }
    return self;
}



- (void)dealloc {
	[items release];
    [super dealloc];
}


/*
- (void)layoutSubviews{
	
	    for (int i = 0 ; i < 6 ; i++){
         ThumbnailView *tiv = (ThumbnailView*)[photos objectAtIndex:i];
        CGRect frame = CGRectMake( 4 + i*(75+4) ,4, 75, 75);
        [tiv setFrame:frame];
        [self addSubview:tiv];
    }
}
*/


/*
- (void)clearHighlight {
	[photos makeObjectsPerformSelector:@selector(clearHighlight) ];
}



- (void)releaseAllPhotos{

}
*/


#pragma mark - Cell Items tap Delegate

- (void)tappedItemWithIndex:(NSUInteger)index
{
    [tapDelegate multipleItemTableViewCell:self tappedItemWithIndex:index];
}


- (void)doubleTappedItemWithIndex:(NSUInteger)index
{
    [tapDelegate multipleItemTableViewCell:self doubleTappedItemWithIndex:index];
}


- (void)longTappedItemWithIndex:(NSUInteger)index
{
    [tapDelegate multipleItemTableViewCell:self longTappedItemWithIndex:index];
}



#pragma mark - Multiple Item table view Cell implementation
-(void)select:(BOOL)selected itemWithIndex:(NSUInteger)index{
    ThumbnailView *tv = [items objectAtIndex:index];
    [tv setSelected:selected];
}
@end
