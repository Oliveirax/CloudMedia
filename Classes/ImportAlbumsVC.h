//
//  ModalAlbumsVC.h
//  Xmedia
//
//  Created by Luis Filipe Oliveira on 11/15/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "BaseAlbumsVC.h"


@interface ImportAlbumsVC : BaseAlbumsVC
<ModalViewController>

- (id)initWithCurrentLibrary;
- (id)initWithDeviceLibrary;
- (id)initWithLibrary:(AssetsLibrary *)library;

//modalViewController protocol
@property(nonatomic, assign) id<ModalViewControllerDelegate> modalDelegate;
@property(nonatomic, readonly) BOOL cancelled;
@property(nonatomic, assign)ModalViewControllerType type;

@end
