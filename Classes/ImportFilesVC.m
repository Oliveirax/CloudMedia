//
//  ImportFilesVC.m
//  Xmedia
//
//  Created by Oliveira on 10/30/13.
//
//

#import "ImportFilesVC.h"
#import "AssetsLibrary.h"
#import "LibraryManager.h"
#import "AlbumsTableViewCell.h"
#import "FileUtils.h"
#import "ClipboardManager.h"



@interface ImportFilesVC ()

@property(nonatomic,retain) AssetsLibrary* library;
@property(nonatomic, copy) NSString* path;
@property(nonatomic, retain) NSArray* files;
@property(nonatomic, assign)NSUInteger selectedItemsCount;
@property(nonatomic, retain)NSMutableArray* selection;

- (void)doneAction;

@end

@implementation ImportFilesVC

@synthesize modalDelegate = _modalDelegate;
@synthesize type = _type;
@synthesize cancelled = _cancelled;
@synthesize library = _library;
@synthesize path = _path;
@synthesize files = _files;
@synthesize selectedItemsCount = _selectedItemsCount;
@synthesize selection = _selection;

#pragma mark - init and dealloc

- (id)initWithPath:(NSString *)path;
{
 	if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.path = path;
        _selection = [[NSMutableArray alloc] init];
        _type = ModalViewControllerTypeImportFromItunes; 
        self.title = [path lastPathComponent];
    }
    return self;
}



- (void)dealloc {
	
	self.library = nil;
    
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
    
    //buttons
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"Done"
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self action:@selector(doneAction)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    [cancelButton release];

	
	// get assets groups
	[self reloadGroups];
    
    self.tableView.allowsSelectionDuringEditing = YES;
    self.editing = YES;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
			interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
			interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}



#pragma mark - reload content

- (void)reloadGroups
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    self.files = [fileManager contentsOfDirectoryAtPath:_path error:NULL];
    [_selection removeAllObjects];
    for (int i = 0; i < _files.count ; i++){
        [_selection addObject:@NO];
    }
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



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _files.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AlbumsTableViewCell *cell = (AlbumsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:AlbumsTableViewCellIdentifier];
    
    if (cell == nil) {
        cell = [[[AlbumsTableViewCell alloc] init] autorelease];
    }
    
    //cell content
    NSString *fileForCell = (self.files)[indexPath.row];
    [cell setTitle:fileForCell];
	[cell select:[_selection[indexPath.row] boolValue] itemWithIndex:AlbumsTableViewCellCheckMark];
    //[cell setPosterImage:groupForCell.posterImage];
    
//    if ([groupForCell isMemberOfClass:[AssetsLibrary class]]){
//        [cell setNumberOfAlbums:groupForCell.numberOfItems];
//    }
//    else{
//        [cell setNumberOfItems:groupForCell.numberOfItems];
//    }
    
	
    cell.tapDelegate = self;
    cell.row = indexPath.row;
    
    //customize cell here
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	AlbumsTableViewCell *cell = (AlbumsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	NSString *file = [_path stringByAppendingPathComponent:_files[indexPath.row]];
    
    NSLog(@"click %@",file);
    
    [self tappedCell:cell atRow:indexPath.row withFile:file];
}


// Tapped a table view cell
- (void)tappedCell:(AlbumsTableViewCell *)cell atRow:(NSUInteger)row withFile:(NSString *)file
{
    BOOL isDirectory;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:&isDirectory];
    
    if (exists){
        if (isDirectory){
            ImportFilesVC *ifvc = [[ImportFilesVC alloc ]initWithPath:file];
            ifvc.modalDelegate = _modalDelegate;
            [self.navigationController pushViewController:ifvc animated:YES];
        }
        else{
            NSString *extension = [file pathExtension];
            if ([extension isEqualToString:@"zip"]){
                NSString *target  = [[_path stringByAppendingPathComponent:[file lastPathComponent]] stringByDeletingPathExtension];
                [FileUtils createDirectoryAtPath:target];
                [FileUtils unzipArchive:file intoPath:target];
                [self reloadGroupsAndDataAnimated];
            }
        }
    }
}





//forward the event to the row, in case we are not interested in the taps in subviews
- (void)forwardTapToCell:(AlbumsTableViewCell *)cell atRow:(NSUInteger)row
{
    NSString *file = [_path stringByAppendingPathComponent:_files[row]];
    [self tappedCell:cell atRow:row withFile:file];
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
        
      
        if ([_selection[cell.row] boolValue] == YES){
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
	if ([_selection[index] boolValue] == YES){
		return;
	}
	_selection[index] = @YES;
	_selectedItemsCount++;
	[self selectionHasChanged];
}



- (void)deselectItemAtIndex:(NSUInteger)index{
	if ([_selection[index] boolValue] == NO){
		return;
	}
	_selection[index] = @YES;
	_selectedItemsCount--;
	[self selectionHasChanged];
}



- (void)selectItemsFromIndex:(NSUInteger)index
{
    for (NSUInteger i = index ; i < _selection.count ; i++){
      
        if ([_selection[i] boolValue] == YES){break;} //found a selected row - Done!
        _selection[i] = @YES;
        _selectedItemsCount++;
    }
    [self selectionHasChanged];
}



- (void)deselectItemsFromIndex:(NSUInteger)index
{
    for (NSUInteger i = index ; i < _selection.count ; i++){
       
        if ([_selection[i] boolValue] == NO){break;} //found a de-selected row - Done!
        _selection[i] = @NO;
        _selectedItemsCount--;
    }
    [self selectionHasChanged];
}

- (void)toggleSelectionOfItemAtIndex:(NSUInteger)index
{
   
    if ([_selection[index] boolValue] == YES){ //deselect
        _selection[index] = @NO;
        _selectedItemsCount--;
    }
    else { //select
        _selection[index] = @YES;
        _selectedItemsCount++;
    }
    [self selectionHasChanged];
}



- (void)deselectAllItems
{
    for (NSUInteger i = 0 ; i < _selection.count ; i++){
       _selection[i] = @NO;
        
    }
    _selectedItemsCount=0;
    [self selectionHasChanged];
}


- (void)selectAllItems
{
    for (NSUInteger i = 0 ; i < _selection.count ; i++){
        _selection[i] = @YES;
        
    }
    _selectedItemsCount=_selection.count;
    [self selectionHasChanged];
}



- (void)selectionHasChanged
{
	[self.tableView reloadData];
}




#pragma mark - button actions

- (void)doneAction
{
    if (_selectedItemsCount != 0){
        
        ClipboardManager *cm = [ClipboardManager getInstance];
		[cm resetClipboard];
        [cm setModeToFiles];
		
        
		for (int i = 0; i < _files.count; i++){
			if ([_selection[i] boolValue] == YES){
                NSString *file = [_path stringByAppendingPathComponent:_files[i]];
                [cm addFile:file];
                
//				if ([a isMemberOfClass:[AssetsLibrary class]]){
//					[cm addAssetsLibrary:a];
//				}
//				else if ([a isMemberOfClass:[AssetsGroup class]]){
//					[cm addAssetsGroup:a];
//				}
			}
		}


        _cancelled = NO;
    }
    else{
        _cancelled = YES;
    }
    [_modalDelegate modalViewFinished:self];
}


@end
