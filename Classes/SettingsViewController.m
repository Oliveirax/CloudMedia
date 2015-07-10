//
//  SettingsTableViewController.m
//  Xmedia
//
//  Created by Luis Oliveira on 7/26/12.
//  Copyright (c) 2012 EVOLVE Space Solutions. All rights reserved.
//

#import "SettingsViewController.h"
#import "LibraryManager.h"
#import "AssetsLibrary.h"
#import "TrashViewController.h"
#import "LoginViewController.h"

//#import "UsersModalViewController.h"


// private interface
@interface SettingsViewController()

@property(nonatomic,copy)NSString *currentUser;

- (void)doneAction;
//- (void)cancelAction;

@end



@implementation SettingsViewController

@synthesize modalDelegate = _modalDelegate;
@synthesize type = _type;
@synthesize cancelled = _cancelled;
@synthesize currentUser = _currentUser;
@synthesize userChanged = _userChanged;



#pragma mark - Init & Dealloc

- (id)init
{
	self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.wantsFullScreenLayout = YES;
        _type = ModalViewControllerTypeUserSettings;
        _cancelled = NO;
		_userChanged = NO;
		self.currentUser = [[[LibraryManager getInstance]currentUser] objectForKey:keyUsersUsername];
	}
	return self;
}



- (void)dealloc 
{
	self.currentUser = nil;
	[super dealloc];
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // customize navigation bar
	self.navigationController.navigationBarHidden = NO;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	self.navigationItem.hidesBackButton = YES;
	
    //buttons & title
    self.navigationItem.title = @"Settings";
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
																				   target:self action:@selector(doneAction)];
    
    //UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
    self.navigationItem.rightBarButtonItem = doneButton;
   // self.navigationItem.leftBarButtonItem = cancelButton;
    
	[doneButton release];
    //[cancelButton release];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	self.currentUser = [[[LibraryManager getInstance]currentUser] objectForKey:keyUsersUsername];
	[self.tableView reloadData];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case 0: // login section
			if ([self.currentUser isEqualToString:kGuestUsername]){
				return 1;
			}
			return 2; 
		
		case 1:	// trash section
			return 1;
						
		default:
			return 0;
	}
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierValue1 = @"CellValue1";
    static NSString *CellIdentifierDefault = @"CellDefault";
    
    UITableViewCell *cell = nil;
	
	switch (indexPath.section) {
		
		case 0: // login section
			if (indexPath.row == 0){
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierValue1];
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
                                                   reuseIdentifier:CellIdentifierValue1] autorelease];
                }
                cell.textLabel.text = @"Current User";
                cell.detailTextLabel.text = self.currentUser;
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				cell.accessoryType =UITableViewCellAccessoryDisclosureIndicator;
            }
            else{
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierDefault];
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                   reuseIdentifier:CellIdentifierDefault] autorelease];
                }
                cell.textLabel.text = @"Logout";
                cell.textLabel.textAlignment = UITextAlignmentCenter;
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            }
			break;
	
		case 1:	// trash section
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierDefault];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                               reuseIdentifier:CellIdentifierDefault] autorelease];
            }
            cell.textLabel.text = @"Trash";
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			break;
	}
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	switch (indexPath.section) {
        
        case 0: // login section 
            
			if (indexPath.row == 0){ //login
				
                
                LoginViewController *msvc = [[LoginViewController alloc] init];
                [self.navigationController pushViewController:msvc animated:YES];
                [msvc release];
            }
            else{ //logout

                [[LibraryManager getInstance]loadUserWithName:kGuestUsername withPassword:@""];
                self.currentUser = [[[LibraryManager getInstance]currentUser] objectForKey:keyUsersUsername];               
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            }
			break;
			
        case 1: // trash
		{
			//NSMutableDictionary *library  = [[LibraryManager getInstance] currentLibrary];
            //AssetsLibrary *al = [[AssetsLibrary alloc]initWithPath:[library objectForKey:keyLibraryRootAlbumPath]];
            TrashViewController *tvc = [[TrashViewController alloc] init];
            [self.navigationController pushViewController:tvc animated:YES];
            [tvc release];
			//[al release];
			break;
		}
		
	}
}



#pragma mark - Button Actions

- (void)doneAction
{
	_cancelled = NO;
	[self.modalDelegate modalViewFinished:self];
}

//- (void)cancelAction
//{
//	_cancelled = YES;
//	[self.modalDelegate modalViewFinished:self];
//}

@end
