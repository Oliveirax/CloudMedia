//
//  LibraryManager.h
//  Xmedia
//
//  Created by Luis Oliveira on 7/12/11.
//

@class Asset;

@interface LibraryManager : NSObject 

@property (nonatomic, copy)NSString *dataDirectory;
//@property (nonatomic, copy)NSString *usersFilePath;
@property (nonatomic, retain)NSMutableDictionary *currentUser;
@property (nonatomic, retain) NSMutableDictionary *currentLibrary;

@property (nonatomic) NSUInteger errorCode;


// constructor / getter
+ (LibraryManager *)getInstance;

//user stuff
- (BOOL)createUserWithName:(NSString *)name withPassword:(NSString *)password;
- (BOOL)removeUserWithName:(NSString *)name withPassword:(NSString *)password;
- (BOOL)loadUserWithName:(NSString *)name withPassword:(NSString *)password;
- (void)loadCurrentUserLibrary; 
- (BOOL)saveCurrentUserLibrary;
- (NSString *)currentUserDir; //current user dir, relative to data


// albums stuff
- (NSString *)createAlbumWithName:(NSString *)albumName inAlbum:(NSString *)parentAlbumFilePath;
- (NSString *)createAlbumWithGeneratedName:(NSString *)albumName inAlbum:(NSString *)parentAlbumFilePath;
- (BOOL)removeAlbumWithName:(NSString *)albumName inAlbum:(NSString *)parentAlbumFilePath;
- (BOOL)moveAlbumFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex inAlbum:(NSString *)parentAlbumFilePath;
- (BOOL)rebuildIndexInAlbum:(NSMutableDictionary *)album;
- (BOOL)renameAlbumWithName:(NSString *)name toName:(NSString *)newName inAlbum:(NSString *)parentAlbumFilePath;
- (BOOL)isAlbum:(NSString *)childAlbumFilePath aChildOfAlbum:(NSString *)parentAlbumFilePath;

//private???
- (NSString *)getPathOfAlbumNamed:(NSString *)albumName inAlbum:(NSString *)parentAlbumFilePath;


//assets stuff
- (BOOL)removeAsset:(Asset *)asset inAlbum:(NSString *)parentAlbumFilePath;
- (BOOL)addAsset:(Asset *)asset inAlbum:(NSString *)parentAlbumFilePath;

- (NSString *) addDataDirTo:(NSString *)path;


@end
