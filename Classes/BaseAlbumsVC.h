//
//  BaseAlbumsVC.h
//  Xmedia
//
//  Created by Luis Filipe Oliveira on 11/15/12.
//  Copyright (c) 2012 home. All rights reserved.
//
 
@class AssetsLibrary;
@class AlbumsTableViewCell;


@interface BaseAlbumsVC : UITableViewController 
<MultipleItemTableViewCellTapDelegate,
AssetsLibraryGroupsEnumerationDelegate>


@property(nonatomic,retain)AssetsLibrary *assetsLibrary;
@property(nonatomic,retain)NSMutableArray *groups;
@property(nonatomic,assign)NSUInteger selectedItemsCount;


//constructor
- (id)initWithLibrary:(AssetsLibrary *)library;

//customize cell appearance
-( AlbumsTableViewCell *)customizeCell:(AlbumsTableViewCell *) cell atRow:(NSUInteger)row;

//Tapped a table view cell
- (void)tappedCell:(AlbumsTableViewCell *)cell atRow:(NSUInteger)row withGroup:(id<Group>)group;

//Forward a event to the cell itself
- (void)forwardTapToCell:(AlbumsTableViewCell *)cell atRow:(NSUInteger)row;

// reload content
- (void)reloadGroups;
- (void)reloadData;
- (void)reloadDataAnimated;
- (void)reloadGroupsAndDataAnimated;


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
