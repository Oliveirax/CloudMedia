//
//  BaseAlbumsVC.m
//  Xmedia
//
//  Created by Luis Filipe Oliveira on 11/15/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "BaseAlbumsVC.h"

#import "AssetsLibrary.h"
#import "AlbumsTableViewCell.h"



#pragma mark - Private interface

@interface BaseAlbumsVC()

@end



@implementation BaseAlbumsVC

@synthesize assetsLibrary = _assetsLibrary;
@synthesize groups = _groups;
@synthesize selectedItemsCount = _selectedItemsCount;



#pragma mark - Init & Dealloc

- (id)initWithLibrary:(AssetsLibrary *)library
{
	if ((self = [super initWithStyle:UITableViewStylePlain])) {
		
        //AssetsLibrary must be retained, because whoever instantiates this (e.g. AppDelegate), releases the library. 
		_assetsLibrary = [library retain]; 
        self.title = library.name;
        
        
    }
    return self;
}



- (void)dealloc {
	
	self.assetsLibrary = nil;
    self.groups = nil;
	    
    [super dealloc];
}



#pragma mark - View stuff

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    self.wantsFullScreenLayout = YES;
	
	// customize navigation bar
	self.navigationController.navigationBarHidden = NO;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	self.navigationItem.title = self.title;
    
    
	//customize toolbar
	self.navigationController.toolbarHidden = YES;
	self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;
	
	//customize table view
	self.tableView.rowHeight = 58; //thumbs from ALAssetsGroups have 55x55 pixels, 58 gives a 1 pixel border
    self.tableView.allowsSelectionDuringEditing = YES;
	
	// get assets groups
	[self reloadGroups];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
			interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
			interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}



#pragma mark - reload content

- (void)reloadGroups
{	
	self.groups = [self.assetsLibrary enumerateGroups];
	self.assetsLibrary.groupsEnumerationDelegate = self;
    _selectedItemsCount = 0;
}



- (void)reloadData
{
	[self.tableView reloadData];
}



- (void)reloadDataAnimated
{
	[self.tableView  reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}


- (void)reloadGroupsAndDataAnimated
{
    [self reloadGroups];
    [self reloadDataAnimated];
}



#pragma mark - AssetsLibraryEnumerationDelegate

- (void)groupsEnumerationDidFinish{
    [self performSelectorOnMainThread:@selector(reloadDataAnimated) withObject:nil waitUntilDone:NO];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return self.groups.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    AlbumsTableViewCell *cell = (AlbumsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:AlbumsTableViewCellIdentifier];
    
    if (cell == nil) {
        cell = [[[AlbumsTableViewCell alloc] init] autorelease];
    }
    
    //cell content
    id<Group> groupForCell = (self.groups)[indexPath.row]; 
    [cell setTitle:groupForCell.name];
	[cell select:groupForCell.selected itemWithIndex:AlbumsTableViewCellCheckMark];
    [cell setPosterImage:groupForCell.posterImage];
    
    if ([groupForCell isMemberOfClass:[AssetsLibrary class]]){
        [cell setNumberOfAlbums:groupForCell.numberOfItems];
    }
    else{
        [cell setNumberOfItems:groupForCell.numberOfItems];
    }

	
    cell.tapDelegate = self;
    cell.row = indexPath.row;
    
    return [self customizeCell:cell atRow:indexPath.row];
}


// To Override - Customize the appearance of table view cells.
- (AlbumsTableViewCell *)customizeCell:(AlbumsTableViewCell *) cell atRow:(NSUInteger)row
{
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{    
	AlbumsTableViewCell *cell = (AlbumsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	id<Group> group = (self.groups)[indexPath.row];
    [self tappedCell:cell atRow:indexPath.row withGroup:group];
}


// To Override - Tapped a table view cell
- (void)tappedCell:(AlbumsTableViewCell *)cell atRow:(NSUInteger)row withGroup:(id<Group>)group
{

}


//forward the event to the row, in case we are not interested in the taps in subviews
- (void)forwardTapToCell:(AlbumsTableViewCell *)cell atRow:(NSUInteger)row
{
    id<Group> group = (self.groups)[row];
    [self tappedCell:cell atRow:row withGroup:group];
}



// this defines the left control type when in editing mode, it must be none in order to show our checkmark
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}



#pragma mark - MultipleItemTableViewCell Tap Delegate

- (void)multipleItemTableViewCell:(id<MultipleItemTableViewCell>)cell tappedItemWithIndex:(NSUInteger)index
{
    if(self.isEditing && index == AlbumsTableViewCellCheckMark){
        [self toggleSelectionOfItemAtIndex:cell.row];
    }
    else{
        [self forwardTapToCell:(AlbumsTableViewCell *)cell atRow:cell.row];
    }
}



- (void)multipleItemTableViewCell:(id<MultipleItemTableViewCell>)cell doubleTappedItemWithIndex:(NSUInteger)index
{
}



- (void)multipleItemTableViewCell:(id<MultipleItemTableViewCell>)cell longTappedItemWithIndex:(NSUInteger)index
{
    if(self.isEditing && index == AlbumsTableViewCellCheckMark){
        
        id<Group> group = (self.groups)[cell.row];
        if (group.selected){
            [self deselectItemsFromIndex:cell.row];
        }
        else{
            [self selectItemsFromIndex:cell.row];
        }
    }
   
}



#pragma mark - Items Selection

- (void)selectItemAtIndex:(NSUInteger)index
{
	id<Group> a = (self.groups)[index];
	if (a.selected){
		return;
	}
	a.selected = YES;
	_selectedItemsCount++;
	[self selectionHasChanged];	
}



- (void)deselectItemAtIndex:(NSUInteger)index{
	id<Group> a = (self.groups)[index];
	if (!a.selected){
		return;
	}
	a.selected = NO;
	_selectedItemsCount--;
	[self selectionHasChanged];	
}



- (void)selectItemsFromIndex:(NSUInteger)index
{
    for (NSUInteger i = index ; i < [self.groups count] ; i++){
        id<Group> a = (self.groups)[i];
        if (a.selected){break;} //found a selected row - Done!
        a.selected = YES;
        _selectedItemsCount++;
    }
    [self selectionHasChanged];
}



- (void)deselectItemsFromIndex:(NSUInteger)index
{
    for (NSUInteger i = index ; i < [self.groups count] ; i++){
        id<Group> a = (self.groups)[i];
        if (!a.selected){break;} //found a de-selected row - Done!
        a.selected = NO;
        _selectedItemsCount--;
    }
    [self selectionHasChanged];
}

- (void)toggleSelectionOfItemAtIndex:(NSUInteger)index
{
    id<Group> group = (self.groups)[index];
    
    if (group.selected){ //deselect
        group.selected = NO;
        _selectedItemsCount--;
    }
    else { //select
        group.selected = YES;
        _selectedItemsCount++;
    }
    [self selectionHasChanged];
}



- (void)deselectAllItems
{
    //deselect all groups
    for (id<Group> a in self.groups){
        a.selected = NO;
        
    }
    _selectedItemsCount=0;
    [self selectionHasChanged];
}


- (void)selectAllItems
{
    //select all groups
    for (id<Group> a in self.groups){
        a.selected = YES;
        
    }
    _selectedItemsCount=self.groups.count;
    [self selectionHasChanged];
}



- (void)selectionHasChanged
{
	[self.tableView reloadData];
}
  
    
@end
