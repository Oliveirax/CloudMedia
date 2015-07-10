//
//  SettingsViewController.h
//  Xmedia
//
//  Created by Luis Oliveira on 7/26/12.
//  Copyright (c) 2012 EVOLVE Space Solutions. All rights reserved.
//

@interface SettingsViewController : UITableViewController <ModalViewController>

@property(nonatomic, assign)id<ModalViewControllerDelegate> modalDelegate;
@property(nonatomic, assign)ModalViewControllerType type;
@property(nonatomic, readonly)BOOL cancelled;
@property(nonatomic, readonly)BOOL userChanged;

@end
