//
//  ExportAlbumsVC.m
//  Xmedia
//
//  Created by Luis Oliveira on 12/7/12.
//  Copyright (c) 2012 EVOLVE Space Solutions. All rights reserved.
//

#import "ExportAlbumsVC.h"
#import "AssetsLibrary.h"
#import "AssetsGroup.h"
#import "LibraryManager.h"
#import "ClipboardManager.h"
#import "ExportAlbumContentsVC.h"
#import "AlbumsTableViewCell.h"



#pragma mark - Private interface

@interface ExportAlbumsVC()

@property(nonatomic, retain)NSArray *toolbarButtons;

- (void)cancelAction;
- (void)copyAction;
- (void)moveAction;
- (void)modalViewFinished;

@end


@implementation ExportAlbumsVC 

@synthesize modalDelegate = _modalDelegate;
@synthesize type = _type;
@synthesize cancelled = _cancelled;
@synthesize toolbarButtons = _toolbarButtons;



#pragma mark - Init & dealloc

- (id)initWithCurrentLibrary
{
    NSMutableDictionary *currLibrary  = [[LibraryManager getInstance] currentLibrary];
    AssetsLibrary *library = [[AssetsLibrary alloc]initWithPath:currLibrary[keyLibraryRootAlbumPath]];
	if ((self = [super initWithLibrary:[library autorelease]])) {
        _type = ModalViewControllerTypeExportToLibrary; //default
    }
    return self;
}


- (id)initWithLibrary:(AssetsLibrary *)library
{
	if ((self = [super initWithLibrary:library])) {
        _type = ModalViewControllerTypeExportToLibrary; //default
    }
    return self;
}




#pragma mark - View stuff

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    //customize navigation bar
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" 
                                                                    style:UIBarButtonItemStyleDone 
                                                                   target:self 
																   action:@selector(cancelAction)];
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
    theLabel2.text = @"Export Media To:";
    
	[titleView addSubview:theLabel];
	[theLabel release];
    [titleView addSubview:theLabel2];
	[theLabel2 release];
    [self.navigationItem setTitleView:titleView]; 
	[titleView release];
	
	//customize toolbar
	UIBarButtonItem* copyButton = [[UIBarButtonItem alloc]initWithTitle:@"Copy" 
																  style:UIBarButtonItemStyleBordered 
																 target:self 
																 action:@selector(copyAction)];
	
	UIBarButtonItem* moveButton = [[UIBarButtonItem alloc]initWithTitle:@"Move" 
																  style:UIBarButtonItemStyleBordered 
																 target:self 
																 action:@selector(moveAction)];
	
	UIBarButtonItem* flexibleSpace =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	//button sizes 
	copyButton.width = 53;
	moveButton.width = 53;
	
	NSArray *tb = [[NSArray alloc] initWithObjects:flexibleSpace, copyButton, flexibleSpace, moveButton, flexibleSpace, nil];
	self.toolbarButtons = tb;
	
	[flexibleSpace release];
	[copyButton release];
	[moveButton release];
	[tb release];
	
	self.toolbarItems = self.toolbarButtons;
	self.navigationController.toolbarHidden = NO;
}


-(void)viewDidUnload
{
	[super viewDidUnload];
	self.toolbarButtons = nil;
}


#pragma mark - Table view data source

-( AlbumsTableViewCell *)customizeCell:(AlbumsTableViewCell *) cell atRow:(NSUInteger)row
{
    cell.accessoryType =UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}




#pragma mark - Table view delegate

- (void)tappedCell:(AlbumsTableViewCell *)cell atRow:(NSUInteger)row withGroup:(id<Group>)group
{
    [self deselectAllItems];
	
	// open an AssetsLibrary
    if ([group isMemberOfClass:[AssetsLibrary class]]){
        ExportAlbumsVC *vc = [[ExportAlbumsVC alloc]initWithLibrary:(AssetsLibrary *)group];
		vc.modalDelegate = self.modalDelegate;
		vc.type = self.type;
		[vc setModalDelegate:self.modalDelegate];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
        return;
    }
    
    // open an AssetsGroup
    if ([group isMemberOfClass:[AssetsGroup class]]){
        ExportAlbumContentsVC *vc = [[ExportAlbumContentsVC alloc] initWithAssetsGroup:(AssetsGroup *)group];
		vc.modalDelegate = self.modalDelegate;
		vc.type = self.type;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
        return;
    }

	
}



#pragma mark - Button actions

- (void)cancelAction
{
	_cancelled = YES;
	[self.modalDelegate modalViewFinished:self];
}


- (void)copyAction
{
	_cancelled = NO;
	[[ClipboardManager getInstance]pasteInAssetsLibrary:self.assetsLibrary];
	[self reloadGroupsAndDataAnimated];
	_type = ModalViewControllerTypeExportToLibrary;
	[self performSelector:@selector(modalViewFinished) withObject:nil afterDelay:1.0];
}


- (void)moveAction
{
	_cancelled = NO;
	[[ClipboardManager getInstance]pasteInAssetsLibrary:self.assetsLibrary];
	_type = ModalViewControllerTypeExportToLibraryMove;
	[self reloadGroupsAndDataAnimated];
	[self performSelector:@selector(modalViewFinished) withObject:nil afterDelay:1.0];
}

- (void)modalViewFinished
{
	[self.modalDelegate modalViewFinished:self];
}

@end
