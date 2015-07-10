//
//  CreateNewViewController.h
//  Xmedia
//
//  Created by Luis Filipe Oliveira on 12/8/10.
//

@interface GenericModalViewController : UITableViewController 
<UITextFieldDelegate,
ModalViewController> {

	UIBarButtonItem *cancelButton;
	UIBarButtonItem *doneButton;
	UITextField *textField; 
	BOOL cancelled;
	NSString *text;
	BOOL private;
	BOOL importFromDeviceLibrary;
	ModalViewControllerType type;
}

@property(nonatomic, assign)id<ModalViewControllerDelegate> modalDelegate;
@property(nonatomic, readonly) BOOL cancelled;
@property(nonatomic, copy) NSString* text;
@property(nonatomic, assign, getter = isPrivate) BOOL private;
@property(nonatomic, assign) BOOL importFromDeviceLibrary;
@property(nonatomic, assign)ModalViewControllerType type;

- (id)initWithType:(ModalViewControllerType)_Type;
- (void)cancelAction;
- (void)doneAction;

@end
