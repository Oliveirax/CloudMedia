//
//  AssetsLibrary.h
//  Xmedia
//
// A group of AssetsGroups
//
//  Created by Luis Filipe Oliveira on 11/23/10.
//	
//

@class ALAssetsLibrary;

@interface AssetsLibrary : NSObject <Group>{

	NSString *selfFilePath;
    NSString *thumbFilePath;
	NSString *name;
	NSUInteger numberOfGroups;
    ALAssetsLibrary *deviceLibrary;
	UIImage *image;
	BOOL isALAsset;
    BOOL selected;
	id<AssetsLibraryGroupsEnumerationDelegate > groupsEnumerationDelegate;
}

@property(nonatomic,readonly) NSString *selfFilePath;
@property(nonatomic,readonly) NSString *thumbFilePath;
@property(nonatomic,readonly) NSString *name;
@property(nonatomic,readonly) BOOL isALAsset;
@property(nonatomic, assign) BOOL selected;
@property(nonatomic,readonly)UIImage *posterImage;
@property(nonatomic,readonly)NSUInteger numberOfItems;

@property(nonatomic, assign)id<AssetsLibraryGroupsEnumerationDelegate> groupsEnumerationDelegate;


- (id)init; //init with device library
- (id)initWithPath:(NSString *)path;    //the path of an album with contenttype = kContentTypeAlbums
- (id)initWithDictionary:(NSMutableDictionary *)dict;   // the Dict of an album with contenttype = kContentTypeAlbums

- (NSMutableArray *)enumerateGroups;

@end
