//
//  TrashViewController.m
//  Xmedia
//
//  Created by Luis Oliveira on 7/5/12.
//  Copyright 2012 EVOLVE Space Solutions. All rights reserved.
//

#import "TrashViewController.h"
#import "AssetsLibrary.h"
#import "AssetsGroup.h"
#import "Asset.h"
#import "LibraryManager.h"
#import "FileUtils.h"
#import "ClipboardManager.h"
#import "ExportAlbumsVC.h"



#pragma mark - Private interface

@interface TrashViewController()

@property(nonatomic,retain)AssetsLibrary *assetsLibrary;
@property(nonatomic,retain)NSMutableArray *referencedAssets;
@property (nonatomic, retain)NSArray *toolbarButtons;
@property (nonatomic, retain)NSArray *editModeToolbarButtons;


- (NSMutableArray *)getAllReferencedAssetsInLibrary:(AssetsLibrary *)library;
- (void)addAssetsInGroup:(id<Group>)group toArray:(NSMutableArray *)array;
- (BOOL)isFileReferenced:(NSString *)file;

- (void)showModalViewController:(id<ModalViewController>)controller withTransition:(UIModalTransitionStyle)style;

- (void)reloadAssetsHelper;

- (void)emptyAction;
- (void)exportAction;
- (void)deleteAction;

@end



@implementation TrashViewController

@synthesize assetsLibrary = _assetsLibrary;
@synthesize referencedAssets = _referencedAssets; 
@synthesize toolbarButtons = _toolbarButtons;
@synthesize editModeToolbarButtons = _editModeToolbarButtons;


#pragma mark - Init & dealloc

- (id)init
{
//	if ((self = [super init])) {
//		
//        //AssetsLibrary must be retained, because whoever instantiates this (options), releases the library. 
//		_assetsLibrary = [library retain];
//		
//		_referencedAssets = [self getAllReferencedAssetsInLibrary:library];
//	}
//	return self;
	
	
	
	if ((self = [super initWithAssetsGroup:nil])) {
        NSMutableDictionary *currLibrary  = [[LibraryManager getInstance] currentLibrary];
        _assetsLibrary  = [[AssetsLibrary alloc]initWithPath:[currLibrary objectForKey:keyLibraryRootAlbumPath]];
		_referencedAssets = [[NSMutableArray alloc]init];
	}
    return self;
}






- (void)dealloc
{
    self.assetsLibrary = nil;
	self.referencedAssets = nil;
	[super dealloc];
}



#pragma mark - View lifecycle
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	//navigation bar
	self.title = @"Trash";
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	//toolbar Buttons - normal mode
	UIBarButtonItem* emptyButton =   [[UIBarButtonItem alloc]initWithTitle:@"Empty" style:UIBarButtonItemStyleBordered target:self action:@selector(emptyAction)];
	
	//toolbar buttons - edit mode
	UIBarButtonItem* addToButton =   [[UIBarButtonItem alloc]initWithTitle:@"Export" style:UIBarButtonItemStyleBordered target:self action:@selector(exportAction)];
	UIBarButtonItem* deleteButton = [[UIBarButtonItem alloc]initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered target:self action:@selector(deleteAction)];
	UIBarButtonItem* flexibleSpace =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	//button sizes 
	emptyButton.width = 53;
	addToButton.width = 53;
	deleteButton.width = 53;
	
	// normal toolbar
	NSArray *tb = [[NSArray alloc] initWithObjects:flexibleSpace, emptyButton, flexibleSpace, nil];
	self.toolbarButtons = tb;
	[tb release];
	
	// edit mode toolbar
	NSArray *emtb = [[NSArray alloc] initWithObjects:flexibleSpace, addToButton, flexibleSpace, deleteButton, flexibleSpace,nil];
	self.editModeToolbarButtons = emtb;
	[emtb release];
	
	[flexibleSpace release];
	[addToButton release];
	[deleteButton release];
	[emptyButton release];
	
	self.toolbarItems = self.toolbarButtons;
	self.navigationController.toolbarHidden = NO;
}



//- (void)viewDidAppear:(BOOL)animated 
//{
//    [super viewDidAppear:animated];
//	
//	//set buttons
//	if (self.tableView.editing ){
//		[self.navigationController.toolbar setItems:self.editModeToolbarButtons animated:NO];
//	}
//	else{
//		[self.navigationController.toolbar setItems:self.toolbarButtons animated:NO];
//	}
//	
//	// make the toolbar visible
//	[self.navigationController setToolbarHidden:NO animated:YES];
//}


#pragma mark - reload content

- (void)reloadAssetsHelper
{
	self.referencedAssets = [self getAllReferencedAssetsInLibrary:self.assetsLibrary];
    
    if (self.assets == nil){
        NSMutableArray *array = [[NSMutableArray alloc]init];
        self.assets = array;
        [array release];
    }
    else{
        [self.assets removeAllObjects];
    }
    
	//get the files in media directory that are not referenced
    LibraryManager *lm = [LibraryManager getInstance];
	NSString *libraryPath = [lm.currentUser objectForKey:keyUsersUserDirectoryPath];
	NSString *mediaPath = [lm addDataDirTo:[libraryPath stringByAppendingPathComponent:kMediaDirectoryName]];
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:mediaPath error:NULL];
	
	for (NSString* file in files){
		if (![self isFileReferenced:file]){
            Asset *a = [FileUtils loadAssetInUserDir:libraryPath withName:file];
			[self.assets addObject:a];
		}
	}
	self.selectedItemsCount = 0;
	[self performSelectorOnMainThread:@selector(reloadDataAnimated) withObject:nil waitUntilDone:NO];
}



- (void)reloadAssets
{
	[self performSelectorInBackground:@selector(reloadAssetsHelper) withObject:nil];
}



- (BOOL)isFileReferenced:(NSString *)file
{
	for (Asset *a in self.referencedAssets){
		if( [a.mediaFilePath hasSuffix:file]){
			return YES;
		}
	}
	return NO;
}



- (NSMutableArray *)getAllReferencedAssetsInLibrary:(AssetsLibrary *)library
{
	NSMutableArray *theAssets = [[NSMutableArray alloc ]init];
    [self addAssetsInGroup:library toArray:theAssets];
	return [theAssets autorelease];
}



- (void)addAssetsInGroup:(id<Group>)group toArray:(NSMutableArray *)array
{ 	
	// AssetsLibrary
    if ([group isMemberOfClass:[AssetsLibrary class]]){
        NSMutableArray *libraryGroups = [(AssetsLibrary *)group enumerateGroups];
        for(id<Group> aGroup in libraryGroups){
            [self addAssetsInGroup:aGroup toArray:array];
        }
    }
    
    // AssetsGroup
    else if ([group isMemberOfClass:[AssetsGroup class]]){
        NSMutableArray *newArray = [(AssetsGroup *)group enumerateAssets];
		[array addObjectsFromArray:newArray];
    }
}



#pragma mark - Modal View Controller Show/Return

- (void)showModalViewController:(id<ModalViewController>)controller withTransition:(UIModalTransitionStyle)style
{
    controller.modalDelegate = self;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:(UIViewController *)controller];
    [nc setModalTransitionStyle:style];
    [self presentModalViewController:nc animated:YES];
    [nc release];
    [controller release];
}



- (void)modalViewFinished:(id<ModalViewController>) controller
{
    [self dismissModalViewControllerAnimated:YES];
    
	if (!controller.cancelled){
		[[ClipboardManager getInstance]resetClipboard];
		[self reloadAssets]; //
	}
}


#pragma mark - Button Actions

- (void)emptyAction
{
	for (Asset *a in self.assets){
		[FileUtils removeItemInDataDir:a.mediaFilePath];
		[FileUtils removeItemInDataDir:a.fullScreenFilePath];
		[FileUtils removeItemInDataDir:a.thumbFilePath];
		[FileUtils removeItemInDataDir:a.vidCapFilePath];
	}
    //self.selectedItemsCount = 0;
    [self reloadAssets];
}



- (void)exportAction
{
	ClipboardManager *cm = [ClipboardManager getInstance];
	[cm resetClipboard];
	[cm setModeToAssets];
	
	for (Asset *a in self.assets){
		if (a.selected){
			[cm addAsset:a];
		}
	}
	
	ExportAlbumsVC *atavc = [[ExportAlbumsVC alloc ]initWithCurrentLibrary];
	[self showModalViewController:atavc withTransition:UIModalTransitionStyleCoverVertical];
}



- (void)deleteAction
{
	for (Asset *a in self.assets){
		if (a.selected){
            [FileUtils removeItemInDataDir:a.mediaFilePath];
			[FileUtils removeItemInDataDir:a.fullScreenFilePath];
			[FileUtils removeItemInDataDir:a.thumbFilePath];
			[FileUtils removeItemInDataDir:a.vidCapFilePath];
        }
	}
    //self.selectedItemsCount = 0;
    [self reloadAssets];
}



#pragma mark - enter/exit edit mode

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	
    // change toolbar buttons 
    if(editing){
		[self setToolbarItems:self.editModeToolbarButtons animated:YES];
	}
    else{
		[self deselectAllItems];
		[self setToolbarItems:self.toolbarButtons animated:YES];	
	}
}

@end