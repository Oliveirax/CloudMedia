//
//  ImportFilesVC.h
//  Xmedia
//
//  Created by Oliveira on 10/30/13.
//
//

#import "BaseAlbumsVC.h"


@interface ImportFilesVC : UITableViewController
<ModalViewController, MultipleItemTableViewCellTapDelegate>

- (id)initWithPath:(NSString *)path;

//modalViewController protocol
@property(nonatomic, assign) id<ModalViewControllerDelegate> modalDelegate;
@property(nonatomic, readonly) BOOL cancelled;
@property(nonatomic, assign)ModalViewControllerType type;

@end

