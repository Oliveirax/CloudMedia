//
//  ImportAlbumContentsVC.m
//  Xmedia
//
//  Created by Luis Oliveira on 12/14/12.
//  Copyright (c) 2012 EVOLVE Space Solutions. All rights reserved.
//

#import "ImportAlbumContentsVC.h"
#import "ClipboardManager.h"
#import "Asset.h"

@implementation ImportAlbumContentsVC


@synthesize modalDelegate = _modalDelegate;
@synthesize type = _type;
@synthesize cancelled = _cancelled;



#pragma mark - Views stuff

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
    self.editing = YES;
	
}



#pragma mark - button actions

- (void)doneAction
{
	if (self.selectedItemsCount != 0){
		
		ClipboardManager *cm = [ClipboardManager getInstance];
		[cm resetClipboard];
		//if (_type == ModalViewControllerTypeImportFromLibrary){
			[cm setModeToAssets];
//		}
//		else{ // import from itunes
//			[cm setModeToAssetsCopy];
//		}
		
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


@end
