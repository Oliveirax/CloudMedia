//
//  AlbumPropertiesModalViewController.m
//  Xmedia
//
//  Created by Luis Oliveira on 9/7/11.
//

#import "AlbumPropertiesModalViewController.h"
#import "Asset.h"
#import "AssetsGroup.h"

@interface AlbumPropertiesModalViewController()
- (void)cancelAction;
- (void)doneAction;
- (UITableViewCell *)getTitleCell;
- (UITableViewCell *)getSwitchCell;
@end

@implementation AlbumPropertiesModalViewController

@synthesize contentType;
@synthesize type;
@synthesize cancelled;
@synthesize modalDelegate = _modalDelegate;


#pragma mark - Init and Dealloc

- (id)initWithAssetsGroup:(AssetsGroup *)_group
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        contentType = contentTypeSingle;
        group = [_group retain];
        groups = nil;
        
    }
    return self;
}


- (id)initWithArray:(NSArray *)_groups
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        contentType = contentTypeMultiple;
        groups = [_groups retain];
        group = nil;
    }
    return self;
}

- (void)dealloc
{
    if (group) [group release];
    if (groups) [groups release];
        
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
	self.navigationItem.title = @"Album Properties";
    
    // navigation bar buttons
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self 
                                                                                 action:@selector(cancelAction)];
    
    // navigation bar buttons
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self 
                                                                                 action:@selector(doneAction)];

    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = doneButton;
    [cancelButton release];
    [doneButton release];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0){
        return 1;
    }
    else{
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    
    if (indexPath.section == 0){
        cell = [self getTitleCell];
        
        if (contentType == contentTypeSingle){
            cell.textLabel.text = [group name];
        }
        else{
            cell.textLabel.text = @"Multiple Albums";
        }
    }
    else{
        cell = [self getSwitchCell];
        cell.textLabel.text = @"Shuffle";
        UISwitch *switchView = (UISwitch *)cell.accessoryView;
        BOOL shuffle = YES;
        
        if (shuffle) {
            [switchView setOn:YES animated:NO];
        } else {
            [switchView setOn:NO animated:NO];
        }
        
        //if([switchView isOn])
        //the best way is to pass the property name to the getSwitchCell method and have the cell returned already inited
        // then, on clicking DONE, go through the cells, get the property name and update the value on the plist

        
    }
    
    return cell;
}





- (UITableViewCell *)getTitleCell
{
    static NSString *CellIdentifier = @"TitleCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    return cell;
}



- (UITableViewCell *)getSwitchCell
{
    static NSString *CellIdentifier = @"SwitchCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    //add a switch
    UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
    cell.accessoryView = switchview;
    [switchview release];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [self.tableView rowHeight];
//    if (indexPath.section == 1){
//        height = 80;
//    }
    return height;
}


#pragma mark - Button Actions

- (void)cancelAction{
    cancelled = YES;
    [self.modalDelegate modalViewFinished:self];
}

- (void)doneAction{
    cancelled = YES;
    [self.modalDelegate modalViewFinished:self];
}

@end
