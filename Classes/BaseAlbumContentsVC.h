//
//  BaseAlbumContentsVC.h
//  Xmedia
//
//  Created by Luis Oliveira on 12/8/12.
//  Copyright (c) 2012 EVOLVE Space Solutions. All rights reserved.
//

@class AssetsGroup;

@interface BaseAlbumContentsVC : UITableViewController 
<MultipleItemTableViewCellTapDelegate>

@property(nonatomic,retain)AssetsGroup *assetsGroup;
@property(nonatomic,retain)NSMutableArray *assets;
@property(nonatomic,assign)NSUInteger selectedItemsCount;


//constructor
- (id)initWithAssetsGroup:(AssetsGroup *)group;

// reload content
- (void)reloadAssets;
- (void)reloadData;
- (void)reloadDataAnimated;
- (void)reloadAssetsAndDataAnimated;

// Items Selection
- (void)selectItemAtIndex:(NSUInteger)index;
- (void)deselectItemAtIndex:(NSUInteger)index;
- (void)selectItemsFromIndex:(NSUInteger)index;
- (void)deselectItemsFromIndex:(NSUInteger)index;
- (void)toggleSelectionOfItemAtIndex:(NSUInteger)index;
- (void)deselectAllItems;
- (void)selectAllItems;
- (void)selectionHasChanged;

@end
