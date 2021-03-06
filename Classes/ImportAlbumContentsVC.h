//
//  ImportAlbumContentsVC.h
//  Xmedia
//
//  Created by Luis Oliveira on 12/14/12.
//  Copyright (c) 2012 EVOLVE Space Solutions. All rights reserved.
//

#import "BaseAlbumContentsVC.h"

@interface ImportAlbumContentsVC : BaseAlbumContentsVC
<ModalViewController>

//modalViewController protocol
@property(nonatomic, assign) id<ModalViewControllerDelegate> modalDelegate;
@property(nonatomic, readonly) BOOL cancelled;
@property(nonatomic, assign)ModalViewControllerType type;



@end
