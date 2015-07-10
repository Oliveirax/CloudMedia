//
//  AlbumsVC.m
//  Xmedia
//
//  Created by DEV1 on 6/25/13.
//
//


#import "AlbumsVC.h"
#import "AlbumContentsVC.h"
#import "AssetsLibrary.h"
#import "AssetsGroup.h"
#import "AlbumsTableViewCell.h"
#import "LibraryManager.h"
#import "ClipboardManager.h"
#import "ImportAlbumsVC.h"
#import "ExportAlbumsVC.h"
#import "SettingsViewController.h"
#import "GenericModalViewController.h"
#import "FileUtils.h"
#import "ImportFilesVC.h"

#define ACTION_SHEET_PROGRESS_TAG 100
#define ACTION_SHEET_DELETE_TAG 101

static const CGRect progressViewPortraitRect = { { 25.0f, 45.0f }, { 270.0f, 30.0f } };
static const CGRect progressViewLandscapeRect = { { 25.0f, 45.0f }, { 390.0f, 30.0f } };
static const CGRect renameTextPortraitRect = { { 106.0f, 9.0f }, { 180.0f, 25.0f } };
static const CGRect renameTextLandscapeRect = { { 106.0f, 9.0f }, { 340.0f, 25.0f } };


#pragma mark - Private interface

@interface AlbumsVC ()

//methods




// action sheet 
@property (nonatomic, retain) UIActionSheet* actionSheet;
@property (nonatomic, retain) UIProgressView* progressView;

// buttons
@property (nonatomic, retain) UIBarButtonItem *addButton;
@property (nonatomic, retain) UIBarButtonItem *settingsButton;
@property (nonatomic, assign) UIBarButtonItem *ieButton;
@property (nonatomic, retain) NSArray *editModeToolbarButtons;
@property (nonatomic, retain) NSArray *normalModeToolbarButtons;

// rename
@property(nonatomic,retain)UITextField *renameTextField;
@property(nonatomic,copy)NSString *renameAlbumName;
@property(nonatomic,retain)NSIndexPath *renameIndexPath;

@end




@implementation AlbumsVC


//@synthesize actionSheet = _actionSheet;
//@synthesize progressView = _progressView;
//
//@synthesize addButton = _addButton;
//@synthesize settingsButton = _settingsButton;
//@synthesize ieButton = _IEButton;
//@synthesize editModeToolbarButtons = _editModeToolbarButtons;
//
//@synthesize renameTextField = _renameTextField;
//@synthesize renameAlbumName = _renameAlbumName;
//@synthesize renameIndexPath = _renameIndexPath;




- (void)dealloc {
	
	self.actionSheet = nil;
    self.progressView = nil;
    self.addButton = nil;
    self.settingsButton = nil;
    self.editModeToolbarButtons = nil;
    self.normalModeToolbarButtons = nil;
    self.renameTextField = nil;
    self.renameIndexPath = nil;
    
    [super dealloc];
}


#pragma mark - Views stuff

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"AVC did load");
    
    //navigation bar buttons
    _addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction)];
    _settingsButton = [[UIBarButtonItem alloc]initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(settingsAction)];
    
    //toolbar buttons
    UIBarButtonItem *ieButton = [[UIBarButtonItem alloc]initWithTitle:@"Import" style:UIBarButtonItemStyleBordered target:self action:@selector(IEAction)];
    UIBarButtonItem* deviceButton =   [[UIBarButtonItem alloc]initWithTitle:@"Device" style:UIBarButtonItemStyleBordered target:self action:@selector(deviceAction)];
    //UIBarButtonItem* pasteButton =  [[UIBarButtonItem alloc]initWithTitle:@"Paste" style:UIBarButtonItemStyleBordered target:self action:@selector(pasteAction)];
    UIBarButtonItem* deleteButton = [[UIBarButtonItem alloc]initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered target:self action:@selector(deleteAction)];
    UIBarButtonItem* flexibleSpace =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem* zipButton =   [[UIBarButtonItem alloc]initWithTitle:@"Zip" style:UIBarButtonItemStyleBordered target:self action:@selector(zipAction)];
    
    //button sizes
    ieButton.width = 53;
    deviceButton.width = 53;
    zipButton.width = 53;
    //pasteButton.width = 53;
    deleteButton.width = 53;
    
    //save a reference to IEButton
    self.ieButton = ieButton;
    
    // edit mode toolbar
    _editModeToolbarButtons = [[NSArray alloc] initWithObjects:
                              deviceButton, flexibleSpace,
                              ieButton, flexibleSpace,
                              zipButton, flexibleSpace,
                              //pasteButton, flexibleSpace,
                              deleteButton,nil];
    
    _normalModeToolbarButtons = [[NSArray alloc] initWithObjects:flexibleSpace,nil];
    
    [ieButton release];
    [flexibleSpace release];
    [deviceButton release];
    //[copyButton release];
    //[pasteButton release];
    [deleteButton release];
    
    
    // customize navigation bar
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
     // customize toolbar
    //[self.navigationController.toolbar setItems:self.normalModeToolbarButtons animated:NO];
    
    // is this the root album? if yes, show settings button
    if ([self.navigationController.viewControllers objectAtIndex:0]==self){
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.leftBarButtonItem = self.settingsButton;
    } else{
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.hidesBackButton = NO;
    }

    //customize toolbar
    self.toolbarItems = self.normalModeToolbarButtons;
    
    //self.tableView.allowsSelectionDuringEditing = YES;
	
}




- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //when going back from another VC, contents may have changed
    [self reloadGroups];
}



- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	//possible cases are
	//a) returning from a ACVC - hide toolbar
	//b) returning from a modal view - exit edit mode
        
    if(self.tableView.editing){
        //[self setEditing:NO animated:YES];
    }
    else{
     [self.navigationController setToolbarHidden:YES animated:YES]; //hide the bar when coming back from ACVC
    }
    
    //this, with setEditing, causes a big flicker
    //[self reloadDataAnimated];
}




#pragma mark - Table view data source

-( AlbumsTableViewCell *)customizeCell:(AlbumsTableViewCell *) cell atRow:(NSUInteger)row
{
    //cell.editingAccessoryType =UITableViewCellAccessoryDetailDisclosureButton;
    cell.accessoryType =UITableViewCellAccessoryDisclosureIndicator;
    cell.showsReorderControl = YES;
    return cell;
}


#pragma mark - Table view delegate

- (void)tappedCell:(AlbumsTableViewCell *)cell atRow:(NSUInteger)row withGroup:(id<Group>)group
{
    
    //edit mode - rename it
    if ( self.isEditing){
        
        cell.selected = NO;
        
        // someone is already being renamed - stop it
        if((self.renameAlbumName && self.renameTextField && self.renameIndexPath)){
            [self commitRename];
            return;
        }
        
        NSIndexPath *ip = [NSIndexPath indexPathForRow:row inSection:0];
        [self startRenameforRowAtIndexPath:ip];
        return;
    }
    
    [self deselectAllItems];
	
	// open an AssetsLibrary
    if ([group isMemberOfClass:[AssetsLibrary class]]){
        AlbumsVC *vc = [[AlbumsVC alloc]initWithLibrary:(AssetsLibrary *)group];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
        return;
    }
    
    // open an AssetsGroup
    if ([group isMemberOfClass:[AssetsGroup class]]){
        AlbumContentsVC *vc = [[AlbumContentsVC alloc] initWithAssetsGroup:group];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
        return;
    }
    
    
    
}


#pragma mark - MultipleItemTableViewCell Tap Delegate

- (void)multipleItemTableViewCell:(id<MultipleItemTableViewCell>)cell tappedItemWithIndex:(NSUInteger)index
{
    NSLog(@"albumsVC  tappedItemWithIndex %d",index);
    
    if (self.isEditing){
        if(index == AlbumsTableViewCellCheckMark){
            [self commitRename];
            [self toggleSelectionOfItemAtIndex:cell.row];
        }
//        else if (index == AlbumsTableViewCellTitle){
//            NSIndexPath *ip = [NSIndexPath indexPathForRow:cell.row inSection:0];
//            [self startRenameforRowAtIndexPath:ip];
//        }
        else if (index == AlbumsTableViewCellImage){
            //change picture
        }
        else{
           [self forwardTapToCell:(AlbumsTableViewCell *)cell atRow:cell.row]; 
        }
    }
    else{
        [self forwardTapToCell:(AlbumsTableViewCell *)cell atRow:cell.row];
    }
}



#pragma mark - Rearranging the table view.

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
    //stop any currently active rename
    [self commitRename];
    
    [[LibraryManager getInstance]moveAlbumFromIndex:fromIndexPath.row toIndex:toIndexPath.row inAlbum:self.assetsLibrary.selfFilePath];
    
    AlbumsTableViewCell *cell;
    cell = (AlbumsTableViewCell *)[self.tableView cellForRowAtIndexPath:fromIndexPath];
    cell.row = toIndexPath.row;
    cell = (AlbumsTableViewCell *)[self.tableView cellForRowAtIndexPath:toIndexPath];
    cell.row = fromIndexPath.row;
    
    [self reloadGroups];
    [self reloadData];
    
}


#pragma mark - Rotation

// resizes rename textfield on rotation. unfortunately, resizing the progressbar does not work,
// as the actionsheet it is on does not move on rotation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    if (interfaceOrientation == UIInterfaceOrientationPortrait){
        if (self.renameTextField != nil){
            [UIView animateWithDuration:duration
                             animations: ^{
                                 self.renameTextField.frame = renameTextPortraitRect;
                             }
                             completion:nil];
        }
        
//        if (self.progressView != nil){
//            [UIView animateWithDuration:duration
//                             animations: ^{
//                                 self.progressView.frame = progressViewPortraitRect;
//                             }
//                             completion:nil];
//        }
    }
    else{
        if (self.renameTextField != nil){
            [UIView animateWithDuration:duration
                             animations: ^{
                                 self.renameTextField.frame = renameTextLandscapeRect;
                             }
                             completion:nil];
        }
        
//        if (self.progressView != nil){
//            [UIView animateWithDuration:duration
//                             animations: ^{
//                                 self.progressView.frame = progressViewLandscapeRect;
//                             }
//                             completion:nil];
//        }
    }
}






#pragma mark - Album Rename

- (void)startRenameforRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSLog(@"Start Rename");
    
    // if the textfield is already active in another cell, this will commit it
    [self commitRename];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    
    self.renameAlbumName = cell.textLabel.text;
    cell.textLabel.text = @" ";
    self.renameIndexPath = indexPath;
    
    if( self.interfaceOrientation == UIInterfaceOrientationPortrait){
        self.renameTextField = [[UITextField alloc]initWithFrame:renameTextPortraitRect];
    }
    else{
        self.renameTextField = [[UITextField alloc]initWithFrame:renameTextLandscapeRect];
    }
    
    self.renameTextField.textColor = [UIColor blackColor];
    self.renameTextField.font = cell.textLabel.font;
    //self.renameTextField.backgroundColor = [UIColor whiteColor];
    //renameTextField.placeholder = @"Enter name";
    //self.renameTextField.borderStyle = UITextBorderStyleBezel; //debug
    self.renameTextField.text = self.renameAlbumName;
    self.renameTextField.keyboardType = UIKeyboardTypeDefault;
    self.renameTextField.returnKeyType = UIReturnKeyDone;
    self.renameTextField.clearButtonMode = UITextFieldViewModeAlways;
    self.renameTextField.opaque = YES;
    [self.renameTextField setDelegate:self];
    [self.renameTextField setEnabled: YES];
    [cell  addSubview:self.renameTextField];
    [self.renameTextField becomeFirstResponder];
}


- (void)commitRename
{
    // nothing was being renamed
    if(!(self.renameAlbumName && self.renameTextField && self.renameIndexPath)){
        return;
    }
	
    BOOL nameChanged =[[LibraryManager getInstance]renameAlbumWithName:self.renameAlbumName toName:self.renameTextField.text inAlbum:self.assetsLibrary.selfFilePath];
    
    if (nameChanged){
        [self reloadGroups];
    }
	
	if ([[LibraryManager getInstance]errorCode] == 1){
        NSString *message = [NSString stringWithFormat:@"An album named \"%@\" already exists.",self.renameTextField.text];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Renaming Album"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
	[self.renameTextField resignFirstResponder];
    [self.renameTextField removeFromSuperview];
    // any kind of animation here provokes flicker
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.renameIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    self.renameTextField = nil;
    self.renameAlbumName = nil;
    self.renameIndexPath = nil;
}


#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField{
    [self commitRename];
    return true;
}


- (BOOL)textFieldShouldClear:(UITextField *)textField{
	return YES;
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
    
    if(controller.cancelled){
        [self dismissModalViewControllerAnimated:YES];
        return;
    }
    
    
    if (controller.type == ModalViewControllerTypeNewAlbum){
        
        GenericModalViewController *gmvc = (GenericModalViewController *)controller;
            
        if( ![[LibraryManager getInstance] createAlbumWithName:gmvc.text inAlbum:self.assetsLibrary.selfFilePath]){
            //album already exists - show alert
            NSString *message = [NSString stringWithFormat:@"An album named \"%@\" already exists.",gmvc.text];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Creating Album"
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
            
        }
        else{
            [self dismissModalViewControllerAnimated:YES];
            [self reloadGroupsAndDataAnimated];
            return;
 
        }
    }
    
    
        
    
    if (controller.type == ModalViewControllerTypeUserSettings){
        
        //user has probably changed - load new user library
      
        NSLog(@"AlbumsVC loading new user...");
           
        [[LibraryManager getInstance]loadCurrentUserLibrary];
        NSMutableDictionary *library = [LibraryManager getInstance].currentLibrary;
        AssetsLibrary *newLibrary = [[AssetsLibrary alloc]initWithPath:[library objectForKey:keyLibraryRootAlbumPath]];
        self.assetsLibrary = newLibrary;
        [newLibrary release];
        self.title = self.assetsLibrary.name;
        
        [self dismissModalViewControllerAnimated:YES];
        [self reloadGroupsAndDataAnimated];
        return;
    }
    
    
    if (controller.type == ModalViewControllerTypeImportFromLibrary){
               
        ClipboardManager *cm = [ClipboardManager getInstance];
        [cm pasteInAssetsLibrary:self.assetsLibrary];
        
        [self dismissModalViewControllerAnimated:YES];
        [self reloadGroupsAndDataAnimated];
        return;
    }
    
    
    // import from photos app
    if (controller.type == ModalViewControllerTypeImportFromDevice){
        
        [self showProgressActionSheet];
        ClipboardManager *cm = [ClipboardManager getInstance];
        [cm setTaskProgressDelegate:self];
        [cm performSelectorInBackground:@selector(pasteInAssetsLibrary:) withObject:self.assetsLibrary];
        
        [self dismissModalViewControllerAnimated:YES];
        [self reloadGroupsAndDataAnimated];
        return;
    }
       
	
	if (controller.type == ModalViewControllerTypeExportToLibrary){
        
		return;
	}
	
    
	if (controller.type == ModalViewControllerTypeExportToLibraryMove){
        
        //delete the moved files
		for (AssetsGroup *a in self.groups){
			if (a.selected){
                
				[[LibraryManager getInstance]removeAlbumWithName:a.name inAlbum:self.assetsLibrary.selfFilePath];
			}
		}
        
        [self dismissModalViewControllerAnimated:YES];
        [self reloadGroupsAndDataAnimated];
        return;
	}
    
    
    // import from itunes
    if (controller.type == ModalViewControllerTypeImportFromItunes){
        
        [self dismissModalViewControllerAnimated:YES];
        [self showProgressActionSheet];
        ClipboardManager *cm = [ClipboardManager getInstance];
        [cm setTaskProgressDelegate:self];
        [cm performSelectorInBackground:@selector(pasteInAssetsLibrary:) withObject:self.assetsLibrary];
        
        [self reloadGroupsAndDataAnimated];
        return;
    }
    
}




#pragma mark - ActionSheet Show/Return

- (void)showProgressActionSheet{

    self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"Importing...\n\n\n"
                                              delegate:self
                                     cancelButtonTitle:nil
                                destructiveButtonTitle:nil
                                     otherButtonTitles:nil];
	
    self.actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    self.actionSheet.tag = ACTION_SHEET_PROGRESS_TAG;
	
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.progress = 0.0;
	
    // dimension the progressbar according to orientation
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait){
        //self.progressView.frame = CGRectMake(25,45,270,30);
        self.progressView.frame = progressViewPortraitRect;
    }
    else{
        //self.progressView.frame = CGRectMake(25,45,390,30);
        self.progressView.frame = progressViewLandscapeRect;
    }
	
    [self.actionSheet addSubview:self.progressView];
    //[self.actionSheet showInView:self.navigationController.view];
    [self.actionSheet performSelector:@selector(showInView:) withObject:self.navigationController.view afterDelay:0.3];
 
}



- (void)showDeleteActionSheet{
    
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"Delete?"
                                              delegate:self
                                     cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:@"Delete"
                                     otherButtonTitles:nil];
    
	self.actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	self.actionSheet.tag = ACTION_SHEET_DELETE_TAG;
	
    [self.actionSheet showInView:self.navigationController.view];
     
}



- (void)actionSheet:(UIActionSheet *)theActionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	if (theActionSheet.tag==ACTION_SHEET_DELETE_TAG){
        
        
        if (buttonIndex == 0){ //delete
            
            for (AssetsGroup *a in self.groups){
                if (a.selected){
                    [[LibraryManager getInstance]removeAlbumWithName:a.name inAlbum:self.assetsLibrary.selfFilePath];
                }
            }
            [self performSelector:@selector(reloadGroupsAndDataAnimated) withObject:nil afterDelay:0.0];
        }
    }
    
    self.actionSheet = nil;
     
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



- (void)taskCompletedHelper
{
    [self.actionSheet dismissWithClickedButtonIndex:1 animated:YES];
	self.progressView = nil;
    [self reloadGroupsAndDataAnimated];
}



#pragma mark - Selection Stuff

- (void)selectionHasChanged
{
	[super selectionHasChanged];
	
    if (self.selectedItemsCount == 0){
        self.ieButton.title = @"Import";
    }
    else{
        self.ieButton.title = @"Export";
    }
}


#pragma mark - Button Actions

- (void)addAction
{
	GenericModalViewController *gmvc = [[GenericModalViewController alloc ] initWithType:ModalViewControllerTypeNewAlbum];
    gmvc.modalDelegate = self;
    [self showModalViewController:gmvc withTransition:UIModalTransitionStyleCoverVertical];
}



- (void)settingsAction
{
	SettingsViewController *msvc = [[SettingsViewController alloc]init];
    msvc.modalDelegate = self;
    [self showModalViewController:msvc withTransition:UIModalTransitionStyleFlipHorizontal];
}



- (void)deviceAction
{
    ImportAlbumsVC *atavc = [[ImportAlbumsVC alloc ]initWithDeviceLibrary];
    atavc.modalDelegate = self;
	[self showModalViewController:atavc withTransition:UIModalTransitionStyleCoverVertical];
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
		[cm setModeToGroups];
		
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
		
		ExportAlbumsVC *atavc = [[ExportAlbumsVC alloc ]initWithCurrentLibrary];
		[self showModalViewController:atavc withTransition:UIModalTransitionStyleCoverVertical];
    }
}




- (void)deleteAction
{
    //[self hideToolbar];
    [self showDeleteActionSheet];
}



- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    // change toolbar buttons
    if(editing){
        [super setEditing:YES animated:animated];
        [self.navigationItem setHidesBackButton:YES animated:animated];
        [self.navigationItem setLeftBarButtonItem:self.addButton animated:animated];
        [self setToolbarItems:self.editModeToolbarButtons animated:YES];
        [self.navigationController setToolbarHidden:NO animated:YES];

    }
    else{
        // is this the root album? if yes, show settings button
        if ([self.navigationController.viewControllers objectAtIndex:0]==self){
            [self.navigationItem setHidesBackButton:YES animated:animated];
            [self.navigationItem setLeftBarButtonItem:self.settingsButton animated:animated];
        } else{
            [self.navigationItem setLeftBarButtonItem:nil animated:animated];
            [self.navigationItem setHidesBackButton:NO animated:animated];
        }
        
        [self deselectAllItems];
        [self commitRename];
        [self setToolbarItems:self.normalModeToolbarButtons animated:YES];
        [self.navigationController setToolbarHidden:YES animated:YES];
        
        //edit mode animation must be performed later to avoid being messed up by reloadData,
        //which is called by deselectAllItems and commitRename
        NSNumber *isAnimated = [NSNumber numberWithBool:animated];
        [self performSelector:@selector(exitEditModeAnimated:) withObject:isAnimated afterDelay:0.3];
        
    }
    
}

- (void) zipAction
{
    NSLog(@"ZIPPY");
    ImportFilesVC *atavc = [[ImportFilesVC alloc ]initWithPath:[FileUtils getDocumentsDirectory]];
    [self showModalViewController:atavc withTransition:UIModalTransitionStyleCoverVertical];
}



- (void)exitEditModeAnimated:(NSNumber *)animated
{
    [super setEditing:NO animated:animated.boolValue];
}

@end

