//
//  BaseAlbumContentsVC.m
//  Xmedia
//
//  Created by Luis Oliveira on 12/8/12.
//  Copyright (c) 2012 EVOLVE Space Solutions. All rights reserved.
//

#import "BaseAlbumContentsVC.h"
#import "AlbumContentsTableViewCell.h"
#import "ThumbnailView.h"
#import "Asset.h"
#import "AssetsGroup.h"
#import "MediaDisplayViewController.h"



#pragma mark - Private interface

@interface BaseAlbumContentsVC()

@property(nonatomic, assign)NSUInteger numberOfPhotosPerRow;

@end



@implementation BaseAlbumContentsVC 

@synthesize assetsGroup = _assetsGroup;
@synthesize assets = _assets;
@synthesize selectedItemsCount = _selectedItemsCount;
@synthesize numberOfPhotosPerRow = _numberOfPhotosPerRow;



#pragma mark - Init & dealloc

- (id)initWithAssetsGroup:(AssetsGroup *)group
{
	if ((self = [super initWithStyle:UITableViewStylePlain])) {
		
		self.assetsGroup = group;
		self.title = [group name];
        self.assets = nil;
				
		self.wantsFullScreenLayout = YES;
        
		//lastSelectedRow = NSNotFound;
        
        if (self.interfaceOrientation == UIInterfaceOrientationPortrait){
            _numberOfPhotosPerRow = 4;
        }
        else{
            _numberOfPhotosPerRow = 6;
        }

		
	}
	return self;
}



- (void)dealloc {
	
	self.assetsGroup = nil;
    self.assets = nil;
	
    [super dealloc];
}



#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSLog(@"ACVC did load");
	
	// customize navigation bar
	self.navigationController.navigationBarHidden = NO;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	self.navigationItem.hidesBackButton = NO;
	self.navigationItem.title = self.title;
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	//customize toolbar
	self.navigationController.toolbarHidden = YES;
	self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;
	
	//customize tableview
	self.tableView.rowHeight = 79; //thumbs from ALAssets have 75x75 pixels, so size the rows accordingly
	self.tableView.allowsSelection = NO;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	//get assets
	[self reloadAssets];
	
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"ACVC view will appear");

	
	//in case we are exposing this view after a modalViewController, and orientation has changed....
	if (self.interfaceOrientation == UIInterfaceOrientationPortrait){
		_numberOfPhotosPerRow = 4;
	}
	else{
		_numberOfPhotosPerRow = 6;
	}
	
	[self.tableView reloadData];	
}



#pragma mark - handling orientation change

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
			interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
			interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}



- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	
    NSLog(@"ACVC will rotate");
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
		_numberOfPhotosPerRow = 4;
	}
	else{
		_numberOfPhotosPerRow = 6;
	}	 
}



- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
	
    NSLog(@"ACVC will animate rotation");
	if (interfaceOrientation == UIInterfaceOrientationPortrait) {
		//[UIView animateWithDuration: duration animations: ^{ [self adjustSizeForPortrait]; } completion: nil ];
        [self.tableView reloadData];
	}
	else{
		//[UIView animateWithDuration: duration animations: ^{ [self adjustSizeForLandscape]; } completion: nil ];
        [self.tableView reloadData];
	}	 
}



#pragma mark  - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return ceil((float)_assets.count / _numberOfPhotosPerRow);
}



// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    AlbumContentsTableViewCell *cell = (AlbumContentsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:AlbumContentsTableViewCellIdentifier];
    if (cell == nil) {
        cell = [[[AlbumContentsTableViewCell alloc] init] autorelease];
    }
    
    NSUInteger firstPhotoInCell = indexPath.row * _numberOfPhotosPerRow;
    NSUInteger lastPhotoInCell  = firstPhotoInCell + _numberOfPhotosPerRow;
    
    if (_assets.count <= firstPhotoInCell) {
        NSLog(@"We are out of range, asking to start with photo %d but we only have %d", firstPhotoInCell, _assets.count);
        return nil;
    }
    
    NSUInteger currentPhotoIndex = 0;
    //NSUInteger lastPhotoIndex = MIN(lastPhotoInCell, assets.count);
    for ( ; firstPhotoInCell + currentPhotoIndex < lastPhotoInCell ; currentPhotoIndex++) {
        
		ThumbnailView *tiv = [cell.items objectAtIndex:currentPhotoIndex];
		
		//blank thumbnails at the end of the list
		if (firstPhotoInCell + currentPhotoIndex >= _assets.count) {
            [tiv setImage:nil];
            [tiv setDuration:-1];
			[tiv setSelected:NO];
		}
		else{
			Asset *asset = [_assets objectAtIndex:firstPhotoInCell + currentPhotoIndex];
			UIImage *thumbnail = [asset thumbnail];
            [tiv setImage:thumbnail];
            [tiv setDuration:asset.duration];
			[tiv setSelected:asset.selected];
		}
	}
    
    //cell properties
    cell.editingAccessoryType =UITableViewCellAccessoryNone;
    cell.accessoryType =UITableViewCellAccessoryNone;
    cell.showsReorderControl = NO;
	cell.tapDelegate = self;
    cell.row = indexPath.row;

	
    return cell;
}



#pragma mark - Table view delegate

// this defines the left control type when in editing mode (none)
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}


#pragma mark - MultipleItemTableViewCell Tap Delegate

- (void)multipleItemTableViewCell:(id<MultipleItemTableViewCell>)cell tappedItemWithIndex:(NSUInteger)index
{
	NSUInteger tappedIndex = cell.row*_numberOfPhotosPerRow + index;
    
    // clicked on a empty photo space - do nothing
	if ( tappedIndex >= _assets.count ){
		return;
	}
	
	// a thumb was selected while in edit mode
	if(self.editing){
        
		[self toggleSelectionOfItemAtIndex:tappedIndex];
    }
    else{
        // open asset
		MediaDisplayViewController *mvc = [[MediaDisplayViewController alloc] initWithAssets:_assets startingIndex:tappedIndex];
		//lastSelectedRow = cell.row;
		[[self navigationController] pushViewController:mvc animated:YES];
		[mvc release];
	}
}


- (void)multipleItemTableViewCell:(id<MultipleItemTableViewCell>)cell doubleTappedItemWithIndex:(NSUInteger)index
{
}



- (void)multipleItemTableViewCell:(id<MultipleItemTableViewCell>)cell longTappedItemWithIndex:(NSUInteger)index{
    
    NSUInteger tappedIndex = cell.row * _numberOfPhotosPerRow + index;
    // clicked on a empty photo space - do nothing
	if ( tappedIndex >= _assets.count ){
		return;
	}
    
    if (self.editing){
        Asset *asset = [_assets objectAtIndex:tappedIndex];
        if (asset.selected){
            [self deselectItemsFromIndex:tappedIndex];
        }
        else{
            [self selectItemsFromIndex:tappedIndex];         
        }
    }
    else{
		//show properties
    }
}



#pragma mark - reload content

- (void)reloadAssets
{
	self.assets = [_assetsGroup enumerateAssets];	
	_selectedItemsCount = 0;
   // [self selectionHasChanged];
}



- (void)reloadDataAnimated{
	[self.tableView  reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}



- (void)reloadData
{
	[self.tableView reloadData];
}



- (void)reloadAssetsAndDataAnimated
{
    [self reloadAssets];
    [self reloadDataAnimated];
}



#pragma mark - Items Select/Deselect

- (void)selectItemsFromIndex:(NSUInteger)index
{
    for (NSUInteger i = index ; i < [_assets count] ; i++){
        Asset *a = [_assets objectAtIndex:i];
        if (a.selected){break;} //already selected? - Stop!
        a.selected = YES;
		_selectedItemsCount++;
    }
    [self selectionHasChanged];
}



- (void)deselectItemsFromIndex:(NSUInteger)index
{
    for (NSUInteger i = index ; i < [_assets count] ; i++){
        Asset *a = [_assets objectAtIndex:i];
        if (!a.selected){break;} //already de-selected? - Stop!
        a.selected = NO;
		_selectedItemsCount--;
    }
    [self selectionHasChanged];
}



- (void)selectItemAtIndex:(NSUInteger)index
{
	Asset *a = [_assets objectAtIndex:index];
	if (a.selected){
		return;
	}
	a.selected = YES;
	_selectedItemsCount++;
	[self selectionHasChanged];	
}



- (void)deselectItemAtIndex:(NSUInteger)index
{
	Asset *a = [_assets objectAtIndex:index];
	if (!a.selected){
		return;
	}
	a.selected = NO;
	_selectedItemsCount--;
	[self selectionHasChanged];	
}




- (void)toggleSelectionOfItemAtIndex:(NSUInteger)index
{
    Asset *a = [_assets objectAtIndex:index];
    if (a.selected){ //deselect
        a.selected = NO;
        _selectedItemsCount--;
    }
    else { //select
        a.selected = YES;
        _selectedItemsCount++;
    }
    [self selectionHasChanged];
}



- (void)deselectAllItems
{
    //deselect all assets
    for (Asset *a in _assets){
        a.selected = NO;
    }
    _selectedItemsCount=0;
    [self selectionHasChanged];
}



- (void)selectAllItems
{
    //select all groups
    for (Asset *a in _assets){
        a.selected = YES;
    }
    _selectedItemsCount=_assets.count;
    [self selectionHasChanged];
}



- (void)selectionHasChanged
{
	[self reloadData];
}


@end
