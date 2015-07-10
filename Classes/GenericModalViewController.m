    //
//  CreateNewViewController.m
//  Xmedia
//
//  Created by Luis Filipe Oliveira on 12/8/10.ß
//

#import "GenericModalViewController.h"

// private interface
@interface GenericModalViewController()
- (void)textFieldDidChange;
@end


@implementation GenericModalViewController

@synthesize modalDelegate = _delegate;
@synthesize cancelled;
@synthesize text;
@synthesize private;
@synthesize type;
@synthesize importFromDeviceLibrary;

#pragma mark -
#pragma init and dealloc

- (id)initWithType:(ModalViewControllerType)_type {
	
	if((self = [super initWithStyle:UITableViewStyleGrouped ])){
		self.wantsFullScreenLayout = YES;
		
		type = _type;
		
//		if (type == ModalViewControllerTypeNewLibrary) {
//			self.title = @"New Library";
//		}
//		else 
        if (type == ModalViewControllerTypeNewAlbum){
			self.title = @"New Album";
		}
//		else if ( type == ModalViewControllerTypeOpenPrivateLibrary){
//			self.title = @"Open Library";
//		}
//		else if ( type == ModalViewControllerTypeDeletePrivateLibrary){
//			self.title = @"Delete Library";
//		}
		else {
			NSLog(@"Error! Invalid ModalViewController type");
		}
		
		cancelled = NO;
		text = nil;
		private = NO;
		importFromDeviceLibrary = NO;
		
		//buttons
		cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelAction)];
		doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction)];
		doneButton.enabled = NO;
		
        // thhis should be done right, and should also be done in interfaceOrientationChanged
		if( self.interfaceOrientation == UIInterfaceOrientationPortrait){
			textField = [[UITextField alloc]initWithFrame:CGRectMake(10,7, 285, 30)];
		}
		else{
			textField = [[UITextField alloc]initWithFrame:CGRectMake(10,7, 285, 30)];
		}
		
		textField.textColor = [UIColor blackColor];
		textField.placeholder = @"Enter name";
		//textField.borderStyle = UITextBorderStyleBezel;
		textField.keyboardType = UIKeyboardTypeDefault;
		textField.returnKeyType = UIReturnKeyDone;
		textField.clearButtonMode = UITextFieldViewModeAlways; 
		[textField setDelegate:self];
        [textField setEnabled: YES];
        [textField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
		
	}
	return self;
}



- (void)dealloc {
	[textField release];
	[cancelButton release];
	[doneButton release];
	[text release];
    [super dealloc];
}



#pragma mark -
#pragma mark View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// customize navigation bar
	self.navigationController.navigationBarHidden = NO;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	self.navigationItem.hidesBackButton = YES;
	self.navigationItem.title = self.title;
	
	[self.navigationItem setRightBarButtonItem:doneButton animated:NO];
	[self.navigationItem setLeftBarButtonItem:cancelButton animated:NO];
	
	//customize toolbar
	self.navigationController.toolbarHidden = YES;
 
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
			interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
			interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}






#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
	// Return the number of sections.
//	if (type == ModalViewControllerTypeNewLibrary) {
//		return 2;
//	}
	
	if(type == ModalViewControllerTypeNewAlbum){
		return 1;
	}
	
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 0) {
		return 1;
	}
	
	if (section == 1) {
		return 1;
	}
	
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	
	// enter name
	switch (indexPath.section) {
		case 0:{	
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			[cell.contentView addSubview:textField];
			
			//NSLog(@"cell %f %f", cell.contentView.frame.size.width, cell.contentView.frame.size.height);
			break;
		}
			
		/*	
		case 1:{
			if (type == ModalViewControllerTypeNewLibrary) {
				cell.textLabel.text = @"Private";
				if (private)
					cell.accessoryType = UITableViewCellAccessoryCheckmark;
				else
					cell.accessoryType = UITableViewCellAccessoryNone; 
			}
			else if(type == ModalViewControllerTypeNewAlbum){
				cell.textLabel.text = @"Import From Device";
				cell.accessoryType = UITableViewCellAccessoryNone; 
			}
			break;
		}	
		*/
	}
	
    return cell;
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	switch (indexPath.section) {
		case 0:{	
			break;
		}
			
			
//            
//		case 1:{
//			//AssetsLibrary *libraryForCell = [places objectAtIndex:indexPath.row];
//			//UIImage *posterImage = [groupForCell posterImage];
//			//cell.imageView.image = posterImage;
//			if (type == ModalViewControllerTypeNewLibrary) {
//				private  = !private;
//				[self.tableView reloadData];
//			}
//			else if(type == ModalViewControllerTypeNewAlbum){
//				importFromDeviceLibrary =  YES;
//				[self doneAction];
//			}
//			break;
//		}	
		
	}
}



#pragma mark - textField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField{
	[textField resignFirstResponder];
	
	NSLog(@"User wrote: %@",textField.text);
	
    /*
	if (![textField.text isEqualToString:@""]) {
		self.text = textField.text;
		doneButton.enabled = YES;
	}
     */
	return YES;
}


- (BOOL)textFieldShouldClear:(UITextField *)textField{
	doneButton.enabled = NO;
	return YES;
}

- (void)textFieldDidChange
{
    self.text = textField.text;
    if ([textField.text isEqualToString:@""]) {
		doneButton.enabled = NO;
	}
    else{
        doneButton.enabled = YES;
    }
}






- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



#pragma mark -
#pragma mark Button Actions

- (void)cancelAction{
	cancelled = YES;
	[self.modalDelegate modalViewFinished:self];
}



- (void)doneAction{
	[self.modalDelegate modalViewFinished:self];
}


@end
