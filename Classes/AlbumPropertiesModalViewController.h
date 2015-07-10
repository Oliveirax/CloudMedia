//
//  AlbumPropertiesModalViewController.h
//  Xmedia
//
//  Created by Luis Oliveira on 9/7/11.
//

typedef enum{
    contentTypeSingle,
    contentTypeMultiple
}ContentType;

@class AssetsGroup;

@interface AlbumPropertiesModalViewController : UITableViewController 
<ModalViewController>
{
    AssetsGroup *group;
    NSArray *groups;
    ContentType contentType;
    
    
    BOOL cancelled;
    ModalViewControllerType type;
}

@property(nonatomic, readonly)ContentType contentType;
@property(nonatomic, assign)ModalViewControllerType type;
@property(nonatomic, readonly)BOOL cancelled;
@property(nonatomic, assign) id<ModalViewControllerDelegate> modalDelegate;


- (id)initWithAssetsGroup:(AssetsGroup *)group;
- (id)initWithArray:(NSArray *)groups;

@end
