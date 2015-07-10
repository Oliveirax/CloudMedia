//
//  AssetsGroup.h
//  Xmedia
//
//  
//	A group of Assets
//
//  Created by Luis Filipe Oliveira on 11/23/10.
//

@class ALAssetsGroup;

@interface AssetsGroup : NSObject <Group>{

	NSString *selfFilePath;
    NSString *thumbFilePath;
	ALAssetsGroup *deviceGroup;
	NSString *name;
	UIImage *image;
	BOOL isALAsset;
	NSInteger numberOfAssets;
    BOOL selected;
}

@property(nonatomic,readonly) NSString *selfFilePath;
@property(nonatomic,readonly) NSString *thumbFilePath;
@property(nonatomic,readonly) NSString *name;
@property(nonatomic,readonly)BOOL isALAsset;
@property(nonatomic, assign) BOOL selected;
@property(nonatomic,readonly)UIImage *posterImage;
@property(nonatomic,readonly)NSUInteger numberOfItems;

- (id)initWithGroup:(ALAssetsGroup *)group; // init with device group
- (id)initWithPath:(NSString *)path;  //the path of an album with contenttype = kContentTypeAssets
- (id)initWithDictionary:(NSMutableDictionary *)dict; // the Dict of an album with contenttype = kContentTypeAlbums

- (NSMutableArray *)enumerateAssets; 
- (void)updateNumberOfItems;

@end
