//
//  AlbumContentsVC.m
//  Xmedia
//
//  Created by Luis Oliveira on 12/17/12.
//  Copyright (c) 2012 EVOLVE Space Solutions. All rights reserved.
//

#import "AlbumContentsVC.h"
#import "ClipboardManager.h"
#import "Asset.h"
#import "AssetsGroup.h"
#import "ImportAlbumsVC.h"
#import "ExportAlbumsVC.h"
#import "LibraryManager.h"
#import "ImportFilesVC.h"
#import "FileUtils.h"


#define ACTION_SHEET_PROGRESS_TAG 100
//#define ACTION_SHEET_ADD_TAG 101
#define ACTION_SHEET_DELETE_TAG 102



#pragma mark - Private interface

@interface AlbumContentsVC()


@property (nonatomic, retain)NSArray *toolbarButtons;
@property (nonatomic, retain)NSArray *editModeToolbarButtons;
@property (nonatomic, assign)UIBarButtonItem* IEButton;
@property (nonatomic, retain)UIActionSheet* actionSheet;																
@property (nonatomic, retain)UIProgressView* progressView;


@end


@implementation AlbumContentsVC

//@synthesize toolbarButtons = _toolbarButtons;
//@synthesize editModeToolbarButtons = _editModeToolbarButtons;
//@synthesize IEButton = _IEButton;
//@synthesize actionSheet = _actionSheet;
//@synthesize progressView = _progressView;


#pragma mark - Views stuff

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	//customize navigation bar
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	//addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction)];
	
	
	//toolbar Buttons - normal mode
	UIBarButtonItem* actionButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionAction)];
	UIBarButtonItem* optionsButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"sliders24"] style:UIBarButtonItemStylePlain target:self action:@selector(optionsAction)];
	
	//toolbar buttons
	UIBarButtonItem* IEButton = [[UIBarButtonItem alloc]initWithTitle:@"Import" style:UIBarButtonItemStyleBordered target:self action:@selector(IEAction)];
	UIBarButtonItem* deviceButton =   [[UIBarButtonItem alloc]initWithTitle:@"Device" style:UIBarButtonItemStyleBordered target:self action:@selector(deviceAction)];
	UIBarButtonItem* zipButton =   [[UIBarButtonItem alloc]initWithTitle:@"Zip" style:UIBarButtonItemStyleBordered target:self action:@selector(zipAction)];
	UIBarButtonItem* deleteButton = [[UIBarButtonItem alloc]initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered target:self action:@selector(deleteAction)];
	UIBarButtonItem* flexibleSpace =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	//button sizes 
	IEButton.width = 53;
	deviceButton.width = 53;
	//copyButton.width = 53;
	//pasteButton.width = 53;
	deleteButton.width = 53;
	
	//save a reference to this button
	self.IEButton = IEButton;
	
	// normal toolbar
	_toolbarButtons = [[NSArray alloc] initWithObjects:actionButton,flexibleSpace, optionsButton, nil];
	
	// edit mode toolbar
	_editModeToolbarButtons = [[NSArray alloc] initWithObjects:	deviceButton, flexibleSpace,
							  IEButton, flexibleSpace, 
							  zipButton, flexibleSpace,
							  //pasteButton, flexibleSpace,
							  deleteButton,nil];
	
	[flexibleSpace release];
	[IEButton release];
	[deviceButton release];
	[zipButton release];
	//[pasteButton release];
	[deleteButton release];
	[actionButton release];
	[optionsButton release];
	
	//customize toolbar
	//self.navigationController.toolbarHidden = NO;
	self.toolbarItems = self.toolbarButtons;
}



- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
	[self.navigationController setToolbarHidden:NO animated:YES];
}

//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    [self.navigationController setToolbarHidden:YES animated:YES];
//    
//}



#pragma mark - ActionSheet Show/Return

- (void)showProgressActionSheet{
    
    [self.navigationController setToolbarHidden:YES animated:YES];

	
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Importing...\n\n\n" 
                                              delegate:self 
                                     cancelButtonTitle:nil  
                                destructiveButtonTitle:nil
                                     otherButtonTitles:nil];
	
	self.actionSheet = as;
	[as release];
	
    self.actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    self.actionSheet.tag = ACTION_SHEET_PROGRESS_TAG;
	
    UIProgressView *pv = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
	self.progressView = pv;
	[pv release];
	
    self.progressView.progress = 0.0;
	
    // dimension the progressbar according to orientation
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait){
        self.progressView.frame = CGRectMake(25,45,270,30);
    }
    else{
        self.progressView.frame = CGRectMake(25,45,390,30);
    }
	
    [self.actionSheet addSubview:self.progressView];
    //[self.actionSheet showInView:self.navigationController.view];
    [self.actionSheet performSelector:@selector(showInView:) withObject:self.navigationController.view afterDelay:0.3];
}



- (void)showDeleteActionSheet
{ 
    [self.navigationController setToolbarHidden:YES animated:YES];

	UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Delete Selected Items"
											  delegate:self 
									 cancelButtonTitle:@"Cancel"  
								destructiveButtonTitle:@"Delete" 
									 otherButtonTitles:nil]; 
	self.actionSheet = as;
	[as release];
	
	self.actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	self.actionSheet.tag = ACTION_SHEET_DELETE_TAG;
	
	[self.actionSheet showInView:self.navigationController.view];
}



- (void)actionSheet:(UIActionSheet *)theActionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	if(theActionSheet.tag==ACTION_SHEET_DELETE_TAG){
        
        
        if (buttonIndex == 0){ //delete
            
            for (Asset *a in self.assets){
                if (a.selected){
                    [[LibraryManager getInstance]removeAsset:a inAlbum:self.assetsGroup.selfFilePath];
                }
            }
            [self performSelector:@selector(reloadAssetsAndDataAnimated) withObject:nil afterDelay:0.0];
        }
        [self.navigationController setToolbarHidden:NO animated:YES];
    }
	
	self.actionSheet = nil;
    [self.navigationController setToolbarHidden:NO animated:YES];
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
    
    if(controller.cancelled){
        
        return;
    }
    
    // import from current lib
	if (controller.type == ModalViewControllerTypeImportFromLibrary){
                
        ClipboardManager *cm = [ClipboardManager getInstance];
		[cm pasteInAssetsGroup:self.assetsGroup];
        [self reloadAssetsAndDataAnimated];
        return;
    }
	
    // import from photos app
    if (controller.type == ModalViewControllerTypeImportFromDevice){
        
        [self showProgressActionSheet];
        ClipboardManager *cm = [ClipboardManager getInstance];
        [cm setTaskProgressDelegate:self];
        [cm performSelectorInBackground:@selector(pasteInAssetsGroup:) withObject:self.assetsGroup];
        return;
    }
	
	if (controller.type == ModalViewControllerTypeExportToLibrary){
        
		return;
	}
	
	if (controller.type == ModalViewControllerTypeExportToLibraryMove){
        
       		
		for (Asset *a in self.assets){
			if (a.selected){
				[[LibraryManager getInstance]removeAsset:a inAlbum:self.assetsGroup.selfFilePath];
			}
		}
		
		self.selectedItemsCount = 0;
		[self reloadAssetsAndDataAnimated];
		return;
	}
    
    // import from itunes
    if (controller.type == ModalViewControllerTypeImportFromItunes){
        
        [self dismissModalViewControllerAnimated:YES];
        [self showProgressActionSheet];
        ClipboardManager *cm = [ClipboardManager getInstance];
        [cm setTaskProgressDelegate:self];
        [cm performSelectorInBackground:@selector(pasteInAssetsGroup:) withObject:self.assetsGroup];
        
        [self reloadAssetsAndDataAnimated];
        return;
    }

}



#pragma mark - Task progress Delegate

- (void)taskProgressed:(CGFloat)amount
{
    // UI elements must be updated in main thread
    [self performSelectorOnMainThread:@selector(taskProgressedHelper:) withObject:[NSNumber numberWithFloat:amount] waitUntilDone:NO];
}



- (void)taskProgressedHelper:(NSNumber *)amount
{
    self.progressView.progress += [amount floatValue];
} 



-(void)taskCompleted
{
    // UI elements must be updated in main thread
    [self performSelectorOnMainThread:@selector(taskCompletedHelper) withObject:nil waitUntilDone:NO];
} 



- (void)taskCompletedHelper{
    NSLog(@"TASK COMPLETED");
	[self.actionSheet dismissWithClickedButtonIndex:1 animated:YES];
	self.progressView = nil;
	self.actionSheet = nil;
    [self reloadAssetsAndDataAnimated];
}




#pragma mark - Selection Stuff

- (void)selectionHasChanged
{
	[super selectionHasChanged];
	
    if (self.selectedItemsCount == 0){
        self.IEButton.title = @"Import";
    }
    else{
        self.IEButton.title = @"Export";
    }
}




#pragma mark - button actions

- (void) addAction{
	NSLog(@"add");
}

- (void) actionAction{
	NSLog(@"action");
}

- (void)optionsAction
{
	NSLog(@"options");
}

- (void)IEAction
{
    if (self.selectedItemsCount == 0){
        NSLog(@"import");
		ImportAlbumsVC *atavc = [[ImportAlbumsVC alloc ]initWithCurrentLibrary];
		[self showModalViewController:atavc withTransition:UIModalTransitionStyleCoverVertical];
    }
    else{
        NSLog(@"export");
		
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
}

- (void)deviceAction
{
	NSLog(@"Info");
    ImportAlbumsVC *atavc = [[ImportAlbumsVC alloc ]initWithDeviceLibrary];
	[self showModalViewController:atavc withTransition:UIModalTransitionStyleCoverVertical];

}



- (void)deleteAction
{	
	NSLog(@"delete");
	
    [self showDeleteActionSheet];
}

- (void) zipAction
{
    NSLog(@"ZIPPY");
    ImportFilesVC *atavc = [[ImportFilesVC alloc ]initWithPath:[FileUtils getDocumentsDirectory]];
    [self showModalViewController:atavc withTransition:UIModalTransitionStyleCoverVertical];
}



- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    [self deselectAllItems];
	
    if(editing){
        
        [self.navigationItem setHidesBackButton:YES animated:YES];
        //[self.navigationItem setLeftBarButtonItem:addButton animated:animated];
        [self setToolbarItems:self.editModeToolbarButtons animated:animated];
        
    }
    else{
        [self.navigationItem setHidesBackButton:NO animated:YES];
        //[self.navigationItem setLeftBarButtonItem:nil animated:animated];
        [self setToolbarItems:self.toolbarButtons animated:animated];
    }
}



@end
