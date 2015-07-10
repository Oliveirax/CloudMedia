//
//  ModalAlbumsVC.m
//  Xmedia
//
//  Created by Luis Filipe Oliveira on 11/15/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "ImportAlbumsVC.h"
#import "AlbumsTableViewCell.h"
#import "ClipboardManager.h"
#import "AssetsLibrary.h"
#import "AssetsGroup.h"
#import "LibraryManager.h"
#import "ImportAlbumContentsVC.h"


#pragma mark - Private interface

@interface ImportAlbumsVC()

- (void)doneAction;

@end



@implementation ImportAlbumsVC

@synthesize modalDelegate = _modalDelegate;
@synthesize type = _type;
@synthesize cancelled = _cancelled;



#pragma mark - Init & dealloc

- (id)initWithDeviceLibrary
{
	AssetsLibrary *library = [[AssetsLibrary alloc] init];
	if ((self = [super initWithLibrary:[library autorelease]])) {
        _type = ModalViewControllerTypeImportFromDevice; // import from photos app
    }
    return self;
}



- (id)initWithCurrentLibrary
{
    NSMutableDictionary *currLibrary  = [[LibraryManager getInstance] currentLibrary];
    AssetsLibrary *library = [[AssetsLibrary alloc]initWithPath:[currLibrary objectForKey:keyLibraryRootAlbumPath]];
	if ((self = [super initWithLibrary:[library autorelease]])) {
        _type = ModalViewControllerTypeImportFromLibrary;  // import from current lib
    }
    return self;
}



- (id)initWithLibrary:(AssetsLibrary *)library
{
	if ((self = [super initWithLibrary:library])) {
        _type = ModalViewControllerTypeImportFromLibrary; // import from current lib
    }
    return self;
}



#pragma mark - View stuff

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    //customize navigation bar
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" 
                                                                    style:UIBarButtonItemStyleDone 
                                                                   target:self action:@selector(doneAction)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    [cancelButton release];
	
	// title view
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0,0,150,40)];
    UILabel *theLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,20,150,20)];
    theLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    theLabel.textColor = [UIColor whiteColor];
    theLabel.font = [UIFont boldSystemFontOfSize:20]; 
    theLabel.textAlignment = UITextAlignmentCenter;
    theLabel.text = self.title;
    
    UILabel *theLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0,5,150,10)];
    theLabel2.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    theLabel2.textColor = [UIColor whiteColor];
    theLabel2.font = [UIFont boldSystemFontOfSize:10]; 
    theLabel2.textAlignment = UITextAlignmentCenter;
    theLabel2.text = @"Import Media From:";
    
	[titleView addSubview:theLabel];
	[theLabel release];
    [titleView addSubview:theLabel2];
	[theLabel2 release];
    [self.navigationItem setTitleView:titleView]; 
	[titleView release];
	
    //customize table view behaviour
    self.tableView.allowsSelectionDuringEditing = YES;
    self.editing = YES;

}



#pragma mark - Table view data source

-( AlbumsTableViewCell *)customizeCell:(AlbumsTableViewCell *) cell atRow:(NSUInteger)row
{
    cell.editingAccessoryType =UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


#pragma mark - Table view delegate

- (void)tappedCell:(AlbumsTableViewCell *)cell atRow:(NSUInteger)row withGroup:(id<Group>)group
{
    [self deselectAllItems];
	
	// open an AssetsLibrary
    if ([group isMemberOfClass:[AssetsLibrary class]]){
        ImportAlbumsVC *vc = [[ImportAlbumsVC alloc]initWithLibrary:(AssetsLibrary *)group];
		vc.modalDelegate = self.modalDelegate;
		vc.type = self.type;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
        return;
    }
    
    // open an AssetsGroup
    if ([group isMemberOfClass:[AssetsGroup class]]){
        ImportAlbumContentsVC *vc = [[ImportAlbumContentsVC alloc] initWithAssetsGroup:group];
		vc.modalDelegate = self.modalDelegate;
		vc.type = self.type;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
        return;
    }
	
}


#pragma mark - button actions

- (void)doneAction
{
	if (self.selectedItemsCount != 0){
		
		ClipboardManager *cm = [ClipboardManager getInstance];
		[cm resetClipboard];
		//if (_type == ModalViewControllerTypeImportFromLibrary){ // import from current lib
			[cm setModeToGroups];
//		}
//		else{ // import from photos App
//			[cm setModeToGroupsCopy];
//		}
	
		for (id<Group> a in self.groups){
			if (a.selected){
				if ([a isMemberOfClass:[AssetsLibrary class]]){
					[cm addAssetsLibrary:a];
				}
				else if ([a isMemberOfClass:[AssetsGroup class]]){
					[cm addAssetsGroup:a];
				}
			}
		}
        _cancelled = NO;
	}
	else{
		_cancelled = YES;
	}
	[self.modalDelegate modalViewFinished:self];
}

@end
