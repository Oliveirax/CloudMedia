//
//  LoginViewController.m
//  Xmedia
//
//  Created by Luis Oliveira on 7/27/12.
//  Copyright (c) 2012 EVOLVE Space Solutions. All rights reserved.
//  A view to login a user, showing a user and pass textfields.
//  When the user presses "new user" button, this view turns to a new user view. 
//

#import "LoginViewController.h"
#import "LibraryManager.h"



//operation mode
typedef enum{
	modeLogin,
	modeNewUser
} mode;



@interface LoginViewController()

@property(nonatomic,retain)UITextField *usernameTextField;
@property(nonatomic,retain)UITextField *passwordTextField;
@property(nonatomic,retain)UITextField *passConfTextField;
@property(nonatomic,retain)UIBarButtonItem *createNewUserButton;
@property(nonatomic,retain)UIBarButtonItem *cancelButton;
@property(nonatomic,assign)mode mode;

- (void)newUserAction;
- (void)cancelAction;


@end



@implementation LoginViewController

@synthesize usernameTextField = _usernameTextField;
@synthesize passwordTextField = _passwordTextField;
@synthesize passConfTextField = _passConfTextField;
@synthesize createNewUserButton = _createNewUserButton;
@synthesize cancelButton = _cancelButton;
@synthesize mode = _mode;


#pragma mark - Init & Dealloc

- (id)init
{
	self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.wantsFullScreenLayout = YES;
		self.mode = modeLogin;
	}
	return self;
}



- (void)dealloc 
{
	[super dealloc];
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	//create buttons
	_createNewUserButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newUserAction)];
	_cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
	
	//create TextFields
	_usernameTextField = [[UITextField alloc]initWithFrame:CGRectMake(100,10, 190, 30)];
	_usernameTextField.textColor = [UIColor darkGrayColor];
	//usernameTextField.borderStyle = UITextBorderStyleBezel;
	_usernameTextField.keyboardType = UIKeyboardTypeDefault;
	_usernameTextField.returnKeyType = UIReturnKeyNext;
	_usernameTextField.clearButtonMode = UITextFieldViewModeNever;
	_usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_usernameTextField.enablesReturnKeyAutomatically = YES; //disable return key when field has no text
	_usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
	[_usernameTextField setDelegate:self];
	[_usernameTextField setEnabled: YES];
	
	_passwordTextField = [[UITextField alloc]initWithFrame:CGRectMake(100,10, 190, 30)];
	_passwordTextField.textColor = [UIColor darkGrayColor];
	//passwordTextField.borderStyle = UITextBorderStyleBezel;
	_passwordTextField.keyboardType = UIKeyboardTypeDefault;
	_passwordTextField.returnKeyType = UIReturnKeyDefault;
	_passwordTextField.clearButtonMode = UITextFieldViewModeNever;
	_passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_passwordTextField.enablesReturnKeyAutomatically = NO;
	_passwordTextField.secureTextEntry = YES;
	[_passwordTextField setDelegate:self];
	[_passwordTextField setEnabled: YES];
	
	_passConfTextField = [[UITextField alloc]initWithFrame:CGRectMake(100,10, 190, 30)];
	_passConfTextField.textColor = [UIColor darkGrayColor];
	//passConfTextField.borderStyle = UITextBorderStyleBezel;
	_passConfTextField.keyboardType = UIKeyboardTypeDefault;
	_passConfTextField.returnKeyType = UIReturnKeyDefault;
	_passConfTextField.clearButtonMode = UITextFieldViewModeNever;
	_passConfTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_passConfTextField.enablesReturnKeyAutomatically = NO;
	_passConfTextField.secureTextEntry = YES;
	[_passConfTextField setDelegate:self];
	[_passConfTextField setEnabled: YES];
	
	
	// customize navigation bar & toolbar
	self.navigationController.navigationBarHidden = NO;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	self.navigationItem.hidesBackButton = NO;
	self.navigationItem.title = @"Login";
	self.navigationItem.rightBarButtonItem = _createNewUserButton;
	self.navigationController.toolbarHidden = YES;
    
}



- (void)viewDidUnload
{
    [super viewDidUnload];
	self.createNewUserButton = nil;
	self.cancelButton = nil;
	self.usernameTextField = nil;
	self.passwordTextField = nil;
	self.passConfTextField = nil;
}



- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.usernameTextField becomeFirstResponder];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_mode == modeLogin){
        return 2;
    }
    
	if (_mode == modeNewUser){
		return 3;
	}
	
	//error
	return 0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierValue1 = @"CellValue1";
    
    UITableViewCell *cell;
    
	if( _mode == modeLogin ){ //Login
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierValue1];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
                                           reuseIdentifier:CellIdentifierValue1] autorelease];
        }
        if(indexPath.row == 0){
            cell.textLabel.text = @"Username";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView addSubview:_usernameTextField];
            
        }
        else{
            cell.textLabel.text = @"Password";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView addSubview:_passwordTextField];
        }
		
    }
    else{ //New user
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierValue1];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
                                           reuseIdentifier:CellIdentifierValue1] autorelease];
        }
        if( indexPath.row == 0 ){
            cell.textLabel.text = @"Username";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView addSubview:_usernameTextField];
        }
        else if( indexPath.row == 1 ){
            cell.textLabel.text = @"Password";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView addSubview:_passwordTextField];
        }
        else{
            cell.textLabel.text = @"Password";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView addSubview:_passConfTextField];
        }
    }
    return cell;
}



#pragma mark - Table view delegate
/*
 
 implement a login button and a create new user button
 
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (type == ModalViewControllerTypeUserSettings){
        
        if (indexPath.section == 0) { //login section
            if (indexPath.row == 0){
                //login
                UsersModalViewController *msvc = [[UsersModalViewController alloc] initWithType:ModalViewControllerTypeLogin];
                msvc.modalDelegate = self;
                
                UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:msvc];
                [nc setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
                [self presentModalViewController:nc animated:YES];
                [nc release];
                [msvc release];
            }
            else{
                //logout
                //[[XmediaFileManager getManager]loadUserWithName:@"Guest" withPassword:@""];
                [[LibraryManager getInstance]loadUserWithName:kGuestUsername withPassword:@""];
                userChanged = YES;
                //currentUser = [[[XmediaFileManager getManager] currentUser]objectForKey:@"username"];
                currentUser = [[[LibraryManager getInstance]currentUser] objectForKey:keyUsersUsername];               
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
        else if (indexPath.section == 1){ // trash section
            //open trash
            NSMutableDictionary *library  = [[LibraryManager getInstance] currentLibrary];
            AssetsLibrary *al = [[AssetsLibrary alloc]initWithPath:[library objectForKey:keyLibraryRootAlbumPath]];
            TrashViewController *tvc = [[TrashViewController alloc] initWithLibrary:al];
            [self.navigationController pushViewController:tvc animated:YES];
            [tvc release];
        }
        
    }
}
*/


#pragma mark - TextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField{
    
    //username field
    if( [aTextField isEqual:_usernameTextField]){
        [_usernameTextField resignFirstResponder];
        [_passwordTextField becomeFirstResponder];
        return YES;
    }
    
    
    // password field
    if( [aTextField isEqual:_passwordTextField]){
        
		// login mode
		if ( _mode == modeLogin){
            
            // wrong username/password pair
            if(![[LibraryManager getInstance]loadUserWithName:_usernameTextField.text withPassword:_passwordTextField.text] ) {
                _passwordTextField.text = @"";
				
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Error" 
                                                                message:@"Incorrect username or password" 
                                                               delegate:nil 
                                                      cancelButtonTitle:@"Dismiss" 
                                                      otherButtonTitles:nil];
                [alert show];
                [alert release];
                return YES;
            }
            
            // successful login
            [_passwordTextField resignFirstResponder];
            //[self.navigationController popViewControllerAnimated:YES];
            [self.navigationController popToRootViewControllerAnimated:YES];
            return YES;
        }
        
        //new user
        [_passwordTextField resignFirstResponder];
        [_passConfTextField becomeFirstResponder];
        return YES;
    }
    
    //new user mode - passwords dont match
    if(![_passwordTextField.text isEqualToString:_passConfTextField.text]){ 
        _passwordTextField.text = @"";
        _passConfTextField.text = @"";
        [_passwordTextField becomeFirstResponder];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                        message:@"The passwords do not match" 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Dismiss" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return YES;
    }
    
    //new user mode - user creation error
    if(![[LibraryManager getInstance]createUserWithName:_usernameTextField.text 
										   withPassword:_passConfTextField.text] ){    
        _usernameTextField.text = @"";
        _passwordTextField.text = @"";
        _passConfTextField.text = @"";
        [_usernameTextField becomeFirstResponder];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                        message:@"Invalid username" 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Dismiss" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return YES;
    }
    
    // new user mode - user created sucessfully - perform login
	[[LibraryManager getInstance]loadUserWithName:_usernameTextField.text 
									 withPassword:_passwordTextField.text];
    
    [_passConfTextField resignFirstResponder];
    //[self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
    return YES;
}



#pragma mark - Button Actions

- (void)newUserAction
{
	self.passwordTextField.returnKeyType = UIReturnKeyNext;
    self.mode = modeNewUser;
	self.navigationItem.title = @"New User";
    self.navigationItem.rightBarButtonItem = _cancelButton;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}



- (void)cancelAction
{
	self.passwordTextField.returnKeyType = UIReturnKeyDefault;
    self.mode = modeLogin;
	self.navigationItem.title = @"Login";
    self.navigationItem.rightBarButtonItem = _createNewUserButton;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

@end
