//
//  ExportAlbumsVC.h
//  Xmedia
//
//  Created by Luis Oliveira on 12/7/12.
//  Copyright (c) 2012 EVOLVE Space Solutions. All rights reserved.
//

#import "BaseAlbumsVC.h"

@interface ExportAlbumsVC : BaseAlbumsVC
<ModalViewController>

- (id)initWithCurrentLibrary;
- (id)initWithLibrary:(AssetsLibrary *)library;


//modalViewController protocol
@property(nonatomic, assign) id<ModalViewControllerDelegate> modalDelegate;
@property(nonatomic, readonly) BOOL cancelled;
@property(nonatomic, assign)ModalViewControllerType type;

@end
