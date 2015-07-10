//
//  ExportAlbumContentsVC.m
//  Xmedia
//
//  Created by Luis Oliveira on 12/17/12.
//  Copyright (c) 2012 EVOLVE Space Solutions. All rights reserved.
//

#import "ExportAlbumContentsVC.h"
#import "ClipboardManager.h"
#import "Asset.h"

@interface ExportAlbumContentsVC()

@property(nonatomic, retain)NSArray *toolbarButtons;

- (void)cancelAction;
- (void)copyAction;
- (void)moveAction;
- (void)modalViewFinished;

@end

@implementation ExportAlbumContentsVC


@synthesize modalDelegate = _modalDelegate;
@synthesize type = _type;
@synthesize cancelled = _cancelled;
@synthesize toolbarButtons = _toolbarButtons;


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
	
	//customize table view behaviour
    self.editing = NO;

}


-(void)viewDidUnload
{
	[super viewDidUnload];
	self.toolbarButtons = nil;
}



#pragma mark - MultipleItemTableViewCell Tap Delegate

- (void)multipleItemTableViewCell:(id<MultipleItemTableViewCell>)cell tappedItemWithIndex:(NSUInteger)index
{
}


- (void)multipleItemTableViewCell:(id<MultipleItemTableViewCell>)cell doubleTappedItemWithIndex:(NSUInteger)index
{
}



- (void)multipleItemTableViewCell:(id<MultipleItemTableViewCell>)cell longTappedItemWithIndex:(NSUInteger)index
{
}




#pragma mark - button actions

- (void)doneAction
{
	if (self.selectedItemsCount != 0){
		
		ClipboardManager *cm = [ClipboardManager getInstance];
		[cm resetClipboard];
		//if (_type == ModalViewControllerTypeExportToLibrary){
			[cm setModeToAssets];
		//}
		//else{
		//	[cm setModeToAssetsCopy];
		//}
		
		for (Asset *a in self.assets){
			if (a.selected){
				[cm addAsset:a];
			}
			_cancelled = NO;
		}
	}
	else{
		_cancelled = YES;
	}
	[self.modalDelegate modalViewFinished:self];
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
	[[ClipboardManager getInstance]pasteInAssetsGroup:self.assetsGroup];
	[self reloadAssetsAndDataAnimated];
	_type = ModalViewControllerTypeExportToLibrary;
	[self performSelector:@selector(modalViewFinished) withObject:nil afterDelay:1.0];
}


- (void)moveAction
{
	_cancelled = NO;
	[[ClipboardManager getInstance]pasteInAssetsGroup:self.assetsGroup];
	[self reloadAssetsAndDataAnimated];
	self.type = ModalViewControllerTypeExportToLibraryMove;
	[self performSelector:@selector(modalViewFinished) withObject:nil afterDelay:1.0];
}

- (void)modalViewFinished
{
	[self.modalDelegate modalViewFinished:self];
}



@end
