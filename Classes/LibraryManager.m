//
//  LibraryManager.m
//  Xmedia
//
//  Created by Luis Oliveira on 7/12/11.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "LibraryManager.h"
#import "FileUtils.h"
#import "Asset.h"

#pragma mark - private interface
@interface LibraryManager()


- (id)init; // private constructor



- (BOOL)createDataDirAndUsersFile;


// create an album in this users's ALBUMS dir and returns it's filename, ALBXXXX.plist
- (NSString *)createAlbumWithName:(NSString *)albumName;

- (void)removeChildrenOfAlbum:(NSString *)albumFilePath;


- (NSString *) addDataDirTo:(NSString *)path;


@end


@implementation LibraryManager

@synthesize dataDirectory = _dataDirectory; // the data directory
//@synthesize usersFilePath = _usersFilePath; // data/users.plist
@synthesize currentUser = _currentUser;     // current user entry in users.plist (dict)
@synthesize currentLibrary = _currentLibrary;  //current user, from library.plist (dict)

@synthesize errorCode = _errorCode;


static LibraryManager* instance;



#pragma mark - init and dealloc

+ (LibraryManager *)getInstance
{	
	@synchronized(self) {
		if(!instance) {
			instance = [[LibraryManager alloc] init];
		}
	}
	return instance;
}



- (id)init
{	
	if ((self = [super init])){
        
        self.dataDirectory = [FileUtils getDataDirectory];
        //self.usersFilePath = [self addDataDirTo:kUsersFileName];
        
        //create the default user, if running for the first time
        [self createDataDirAndUsersFile];
        [self createUserWithName:kGuestUsername withPassword:@""];
        
        //load default user library
        [self loadUserWithName:kGuestUsername withPassword:@""];
        
        _errorCode = 0;
    }
    return self;
}



- (void)dealloc 
{
    self.dataDirectory = nil;
    //self.usersFilePath = nil;
    self.currentUser = nil;
    self.currentLibrary = nil;
    [super dealloc];
}



#pragma mark - Users ops

- (BOOL)createDataDirAndUsersFile
{
    //create data dir
    [FileUtils createDirectoryAtPath:_dataDirectory];
    //here is the place to exclude this directory from backup, and also from options
        
    //check if users plist exists
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self addDataDirTo:kUsersFileName]]){
        return YES;
    }
    
    
    NSMutableDictionary *users = [[NSMutableDictionary alloc]init];
    [users setObject:kUsersFileName forKey:keySelfFilePath];
    BOOL success = [FileUtils saveDictionaryInDataDir:users];
    [users release];
    return success;
}



- (BOOL)createUserWithName:(NSString *)name withPassword:(NSString *)password
{    
    NSLog(@"Creating User: %@...",name);
    
    //cannot allow blank usernames
    if ([name isEqualToString:@""] ){
		NSLog(@"name is empty, returning NO");
        return NO;
    }
    
    //load users plist
	NSMutableDictionary *users = [FileUtils newDictionaryFromFileInDataDir:kUsersFileName];
	
    //verify if the user already exists
    if ([users objectForKey:name ] != nil){ 
        NSLog(@"user %@ already exists. returning...", name);
        [users release];
        return NO;
    }
    
    BOOL success = YES;
    
    //create new user directory 
    NSString *userDirectory = [FileUtils getNextUserDirectory]; //this is just USRXXXX
    success &= [FileUtils createDirectoryAtPath:[self addDataDirTo:userDirectory]];
    
    //create MEDIA directory
    NSString *mediaDirectory = [userDirectory stringByAppendingPathComponent:kMediaDirectoryName];
    success &= [FileUtils createDirectoryAtPath:[self addDataDirTo:mediaDirectory]];
    
    //create THUMBS directory
    NSString *thumbsDirectory = [userDirectory stringByAppendingPathComponent:kThumbsDirectoryName];
    success &= [FileUtils createDirectoryAtPath:[self addDataDirTo:thumbsDirectory]];
    
    //create VIDCAPS directory
    NSString *vidcapsDirectory = [userDirectory stringByAppendingPathComponent:kVidcapsDirectoryName];
    success &= [FileUtils createDirectoryAtPath:[self addDataDirTo:vidcapsDirectory]];
    
    //create FULLSCREEN directory
    NSString *fullScreenDirectory = [userDirectory stringByAppendingPathComponent:kFullScreenDirectoryName];
    success &= [FileUtils createDirectoryAtPath:[self addDataDirTo:fullScreenDirectory]];
    
    //create ALBUMS directory
    NSString *albumsDirectory = [userDirectory stringByAppendingPathComponent:kAlbumsDirectoryName];
    success &= [FileUtils createDirectoryAtPath:[self addDataDirTo:albumsDirectory]];
    
    //create root album
    NSString *rootAlbumFilePath = [albumsDirectory stringByAppendingPathComponent:@"ALB0001.plist"];
    NSMutableDictionary *album = [[NSMutableDictionary alloc] init ];
    [album setObject:rootAlbumFilePath forKey:keySelfFilePath];
    [album setObject:kRootAlbumName forKey:keyAlbumName];
    [album setObject:kContentTypeAlbums forKey:keyAlbumContentType];
    [album setObject:[NSMutableArray array] forKey:keyAlbumItemsArray];
    [album setObject:[NSMutableArray array] forKey:keyAlbumKeywordsArray];
    [album setObject:[NSMutableDictionary dictionary] forKey:keyAlbumItemsIndexDict];
    [album setObject:[NSNumber numberWithFloat:3] forKey:keyAlbumSlideDuration];
    [album setObject:kTransitionRandom forKey:keyAlbumSlideTransition];
    [album setObject:[NSNumber numberWithFloat:0.5] forKey:keyAlbumTransitionDuration];
    [album setObject:[NSNumber numberWithBool:NO] forKey:keyAlbumRepeat];
    [album setObject:[NSNumber numberWithBool:NO] forKey:keyAlbumShuffle];
    success &= [FileUtils saveDictionaryInDataDir:album];
    [album release];
       
    //create library plist
    NSString *libraryFilePath = [userDirectory stringByAppendingPathComponent:kLibraryFileName];
    NSMutableDictionary *library = [[NSMutableDictionary alloc] init];
    [library setObject:libraryFilePath                  forKey:keySelfFilePath];
    [library setObject:name                             forKey:keyLibraryUsername];
    [library setObject:password                         forKey:keyLibraryPassword];
    [library setObject:rootAlbumFilePath                    forKey:keyLibraryRootAlbumPath];
    [library setObject:albumsDirectory                  forKey:keyLibraryAlbumsDirectoryPath];
    [library setObject:vidcapsDirectory                 forKey:keyLibraryVidcapsDirectoryPath];
    [library setObject:fullScreenDirectory              forKey:keyLibraryFullScreenDirectoryPath];
    [library setObject:mediaDirectory                   forKey:keyLibraryMediaDirectoryPath];
    [library setObject:thumbsDirectory                  forKey:keyLibraryThumbsDirectoryPath];
    [library setObject:[NSMutableDictionary dictionary] forKey:keyLibraryAssetReferenceDict];
    success &= [FileUtils saveDictionaryInDataDir:library];
    
    //add new user to users plist
    NSMutableDictionary *newUser = [[NSMutableDictionary alloc] init];
    [newUser setObject:name             forKey:keyUsersUsername];
    [newUser setObject:password         forKey:keyUsersPassword];
    [newUser setObject:userDirectory    forKey:keyUsersUserDirectoryPath];
    [newUser setObject:libraryFilePath  forKey:keyUsersUserLibraryFilePath];
    [users setObject:newUser            forKey:name];
    success &= [FileUtils saveDictionaryInDataDir:users];
    
    [newUser release];
    [library release];
    [users release];
    return success;
}



- (BOOL)loadUserWithName:(NSString *)name withPassword:(NSString *)password
{    
    NSLog(@"Loading User: %@...",name);
    
    //load users plist
	NSMutableDictionary *users = [FileUtils newDictionaryFromFileInDataDir:kUsersFileName];
	
    //get the new user
    NSMutableDictionary *user = [users objectForKey:name];
    
    //verify if the user exists
    if (user == nil){ 
        NSLog(@"user does not exist");
        [users release];
        return NO;
    }
    
    // verify password
    NSString *userPassword = [user objectForKey:keyUsersPassword];
    if(![userPassword isEqualToString:password]){
        NSLog(@"User-pass pair incorrect");
        [users release];
        return NO;
    }
    
    self.currentUser = user;
    //[user release];
    
    //load the user's library
    [self loadCurrentUserLibrary];
    
    NSLog (@"current User is: %@",[_currentUser objectForKey:keyUsersUsername]);
    
    [users release];
    return YES;
}



- (BOOL)removeUserWithName:(NSString *)name withPassword:(NSString *)password{
    
    NSLog(@"Removing User: %@...",name);
    
    //load users plist
	NSMutableDictionary *users = [FileUtils newDictionaryFromFileInDataDir:kUsersFileName];
    
    //verify if the user exists
    if ([users objectForKey:name ] == nil){ 
        NSLog(@"user does not exist");
        [users release];
        return NO;
    }
    
    NSMutableDictionary *user = [users objectForKey:name];
    
    // verify password ???????????????????????????????????????????????????????? WHY?
    NSString *userPassword = [user objectForKey:keyUsersPassword];
    if(![userPassword isEqualToString:password]){
        NSLog(@"User-pass pair incorrect");
        [users release];
        return NO;
    }
    
    //remove from disk
    NSString *path = [self addDataDirTo:[user objectForKey:keyUsersUserDirectoryPath]];
    if(![FileUtils removeItemAtPath:path]){
        [users release];
        return NO;
    }
    
    //remove from users 
    [users removeObjectForKey:name];
    
    
    if(![FileUtils saveDictionaryInDataDir:users]){
        [users release];
        return NO;
    }
    
    [users release];
    return YES;
}


#pragma mark - Library ops

- (void)loadCurrentUserLibrary{
    
    //save previous library
    [self saveCurrentUserLibrary];
    
     NSLog(@"Loading Library for: %@",[_currentUser objectForKey:keyUsersUsername]);
    
    _currentLibrary = [FileUtils newDictionaryFromFileInDataDir:[_currentUser objectForKey:keyUsersUserLibraryFilePath]];
 }



- (BOOL)saveCurrentUserLibrary{
    
    if (!_currentLibrary){
        return YES;
    }
    return [FileUtils saveDictionaryInDataDir:_currentLibrary];
}

- (NSString *)currentUserDir
{
    return [self.currentUser objectForKey:keyUsersUserDirectoryPath];
}


- (void)consolidateCurrentUserLibrary{
    //if you are experiencing errors, in user options, tap on consolidate library
    //it will look for every item and see if it is in the plist
    //and look if every item in the plist is in the disk
}



#pragma mark - Album ops

- (NSString *)createAlbumWithName:(NSString *)albumName
{
    NSString *albumFilePath = [FileUtils getNextAlbumNameInUserDir:[_currentUser objectForKey:keyUsersUserDirectoryPath] ];
    
    NSMutableDictionary *album = [[NSMutableDictionary alloc] init ];
    [album setObject:albumFilePath forKey:keySelfFilePath];
    [album setObject:albumName forKey:keyAlbumName];
    [album setObject:kContentTypeAlbums forKey:keyAlbumContentType];
    [album setObject:[NSMutableArray array] forKey:keyAlbumItemsArray];
    [album setObject:[NSMutableArray array] forKey:keyAlbumKeywordsArray];
    [album setObject:[NSMutableDictionary dictionary] forKey:keyAlbumItemsIndexDict];
    [album setObject:[NSNumber numberWithFloat:3] forKey:keyAlbumSlideDuration];
    [album setObject:kTransitionRandom forKey:keyAlbumSlideTransition];
    [album setObject:[NSNumber numberWithFloat:0.5] forKey:keyAlbumTransitionDuration];
    [album setObject:[NSNumber numberWithBool:NO] forKey:keyAlbumRepeat];
    [album setObject:[NSNumber numberWithBool:NO] forKey:keyAlbumShuffle];
    
    if(![FileUtils saveDictionaryInDataDir:album]){
        [album release];
        return NO;
    }
    
    [album release];
    return albumFilePath;
}


- (NSString *)getPathOfAlbumNamed:(NSString *)albumName inAlbum:(NSString *)parentAlbumFilePath
{
    // load parent album
    NSMutableDictionary *parentAlbum = [FileUtils newDictionaryFromFileInDataDir:parentAlbumFilePath];
    
    // get albums array and index
    NSMutableArray *albums = [parentAlbum objectForKey:keyAlbumItemsArray];
    NSMutableDictionary *index = [parentAlbum objectForKey:keyAlbumItemsIndexDict];
    NSNumber *albumIndex = [index objectForKey:albumName];
    
    // check if album exists
    if (albumIndex == nil){
        NSLog(@"Album: %@. Does not (yet)exist",albumName);
        [parentAlbum release];
        return nil;
    }
    
    NSString *albumFilePath = [[albums objectAtIndex:[albumIndex unsignedIntegerValue]]copy];
    [parentAlbum release];
    return [albumFilePath autorelease]; 
}
                           


- (NSString *)createAlbumWithName:(NSString *)albumName inAlbum:(NSString *)parentAlbumFilePath
{ 
	
	//TODO check if it is an albums container (library), if not, move the assets in it into a new album
    
    NSLog(@"Creating Album: %@ in: %@",albumName, parentAlbumFilePath); 
    
    //check if the parent album name is nil, or an empty string
    if(!parentAlbumFilePath || [parentAlbumFilePath isEqualToString:@""]){
        return nil;
    }
    
    // load parent album
    NSMutableDictionary *parentAlbum = [FileUtils newDictionaryFromFileInDataDir:parentAlbumFilePath];
    
    if (!parentAlbum){
        return nil;
    }
    
    //check if the album name is nil, or an empty string
    if(!albumName || [albumName isEqualToString:@""]){
        [parentAlbum release];
        return nil;
    }
    
    //check if the album name already exists
    if([self getPathOfAlbumNamed:albumName inAlbum:parentAlbumFilePath]){
        [parentAlbum release];
        return nil;
    }
        
    //create album
    NSString *albumPath = [self createAlbumWithName:albumName];
    
    //add it to the parent album's array of items
    NSMutableArray *albumsArray = [parentAlbum objectForKey:keyAlbumItemsArray];
    [albumsArray addObject:albumPath];
    
    //add it to the index
    NSMutableDictionary *itemsIndex = [parentAlbum objectForKey:keyAlbumItemsIndexDict];
    [itemsIndex setObject:[NSNumber numberWithUnsignedInteger:[albumsArray count]-1] forKey:albumName];
    
    //save parent album
    if(![FileUtils saveDictionaryInDataDir:parentAlbum]){
        [parentAlbum release];
        return nil;
    }
    
    [parentAlbum release];
    return albumPath;
}



- (NSString *)createAlbumWithGeneratedName:(NSString *)albumName inAlbum:(NSString *)parentAlbumFilePath
{
    NSUInteger counter = 1;
    NSString *newAlbumName;
    NSString *newAlbumPath;
    do{
        newAlbumName = [NSString stringWithFormat:@"%@ (%d)",albumName,counter];
        newAlbumPath = [self createAlbumWithName:newAlbumName inAlbum:parentAlbumFilePath];
        counter++;
    }while (!newAlbumPath);
    
    return newAlbumPath;
}



- (BOOL)removeAlbumWithName:(NSString *)albumName inAlbum:(NSString *)parentAlbumFilePath
{    
    NSLog(@"Removing Album: %@...",albumName);
    
    //check if the parent album name is nil, or an empty string
    if(!parentAlbumFilePath || [parentAlbumFilePath isEqualToString:@""]){
        return NO;
    }
    
    // load parent album
    NSMutableDictionary *parentAlbum = [FileUtils newDictionaryFromFileInDataDir:parentAlbumFilePath];
    
    if (!parentAlbum){
        return NO;
    }
    
    //check if the album name is nil, or an empty string
    if(!albumName || [albumName isEqualToString:@""]){
        [parentAlbum release];
        return NO;
    }
    
    NSString *albumFile = [self getPathOfAlbumNamed:albumName inAlbum:parentAlbumFilePath];
    if(!albumFile){
        [parentAlbum release];
        return NO;
    }
    
    //delete the all children
    [self removeChildrenOfAlbum:albumFile];
    
    
    //delete album thumb
    NSMutableDictionary *theAlbum = [FileUtils newDictionaryFromFileInDataDir:albumFile];
    [FileUtils removeItemInDataDir:[theAlbum objectForKey:keyAlbumThumbFilePath]];
    [theAlbum release];
    
    
    //delete album file
    if(![FileUtils removeItemInDataDir:albumFile]){
        [parentAlbum release];
        return NO;
    }
    
    //remove album from parent
    NSMutableDictionary *itemsIndex = [parentAlbum objectForKey:keyAlbumItemsIndexDict];
    NSUInteger albumIndex = [[itemsIndex objectForKey:albumName] unsignedIntegerValue];
    NSMutableArray *albumsArray = [parentAlbum objectForKey:keyAlbumItemsArray];
    [albumsArray removeObjectAtIndex:albumIndex];
    
    //rebuild index
    [self rebuildIndexInAlbum:parentAlbum];
    
    //save parent album
    if(![FileUtils saveDictionaryInDataDir:parentAlbum]){
        [parentAlbum release];
        return NO;
    }
    [parentAlbum release];
    return YES;
}


- (void)removeChildrenOfAlbum:(NSString *)albumFilePath
{
    // load album
    NSMutableDictionary *album = [FileUtils newDictionaryFromFileInDataDir:albumFilePath];
    
    //assets album - nothing to delete, except the thumb
    if ([[album objectForKey:keyAlbumContentType] isEqualToString:kContentTypeAssets]){
        
        [FileUtils removeItemInDataDir:[album objectForKey:keyAlbumThumbFilePath]];
    
        [album release];
        return;
    }
    
    NSMutableArray *albumsArray = [album objectForKey:keyAlbumItemsArray];
    for (NSString *childPath in albumsArray){
        [self removeChildrenOfAlbum:childPath];
        [FileUtils removeItemAtPath:[self addDataDirTo:childPath]];
    }
    
    [FileUtils removeItemInDataDir:[album objectForKey:keyAlbumThumbFilePath]];
    [album release];
}


- (BOOL)moveAlbumFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex inAlbum:(NSString *)parentAlbumFilePath
{
    // load parent album
    NSMutableDictionary *parentAlbum = [FileUtils newDictionaryFromFileInDataDir:parentAlbumFilePath];
    
    if (!parentAlbum){
        return NO;
    }
    
    NSMutableArray *albumsArray = [parentAlbum objectForKey:keyAlbumItemsArray];
    NSString *album = [[albumsArray objectAtIndex:fromIndex]copy];
    [albumsArray removeObjectAtIndex:fromIndex];
    [albumsArray insertObject:album atIndex:toIndex];
    [self rebuildIndexInAlbum:parentAlbum];
    [album release];
    
    //save parent Album
    if(![FileUtils saveDictionaryInDataDir:parentAlbum]){
        [parentAlbum release];
        return NO;
    }
    [parentAlbum release];
    return YES;
}



//for now, indexing only works for assetsLibrary, ie albums containing other albums. do not use for albums containing assets
- (BOOL)rebuildIndexInAlbum:(NSMutableDictionary *)album{
    
    NSLog(@"Rebuilding Albums index...");
    
    // get albums array
    NSMutableArray *albumsArray = [album objectForKey:keyAlbumItemsArray];
    
    // create a new Index
    NSMutableDictionary *index = [[NSMutableDictionary alloc ]init ];
    
    //iterate through albums, building a new index
    for (NSUInteger currentIndex = 0; currentIndex < [albumsArray count] ; currentIndex++){
        NSString *albumFilePath = [albumsArray objectAtIndex:currentIndex];
        NSMutableDictionary *theAlbum = [FileUtils newDictionaryFromFileInDataDir:albumFilePath];
        NSString *albumName = [theAlbum objectForKey:keyAlbumName];
        NSNumber *albumIndex = [NSNumber numberWithUnsignedInteger:currentIndex];
        [index setObject:albumIndex forKey:albumName];
        [theAlbum release];
    }
    
    // replace index with the new one
    [album setObject:index forKey:keyAlbumItemsIndexDict];
    [index release];
    
    return YES;
}


- (BOOL)renameAlbumWithName:(NSString *)name toName:(NSString *)newName inAlbum:(NSString *)parentAlbumFilePath
{
	_errorCode = 0; //success
	
    if ([newName isEqualToString:@""]){
        NSLog(@"libman tried to rename an album to an empty string");
        return NO;
    }
    
    if ([newName isEqualToString:name]){
        NSLog(@"libman tried to rename an album to the same name");
        return NO;
    }
    
    //check if the album name already exists
    if([self getPathOfAlbumNamed:newName inAlbum:parentAlbumFilePath]){
        _errorCode =  1;
        return NO;
    }

    // load parent album
    NSMutableDictionary *parentAlbum = [FileUtils newDictionaryFromFileInDataDir:parentAlbumFilePath];
    
    if (!parentAlbum){
        NSLog(@"libman did not find requested parent album");
        return NO;
    }
    
    
    NSString *albumFile = [self getPathOfAlbumNamed:name inAlbum:parentAlbumFilePath];
    if(!albumFile){
        NSLog(@"libman did not find requested album");
        [parentAlbum release];
        return NO;
    }
    
    // load album
    NSMutableDictionary *album = [FileUtils newDictionaryFromFileInDataDir:albumFile];
    
    if (!album){
        NSLog(@"libman could not load the requested album for rename");
        [parentAlbum release];
        return NO;
    }
    
    [album setObject:newName forKey:keyAlbumName];
    
    //save album
    if(![FileUtils saveDictionaryInDataDir:album]){
        [parentAlbum release];
        [album release];
        NSLog(@"libman could not save the album after rename");
        return NO;
    }
    
    //rebuild index
    [self rebuildIndexInAlbum:parentAlbum];
    
    //save parent album
    if(![FileUtils saveDictionaryInDataDir:parentAlbum]){
        [parentAlbum release];
        [album release];
        return NO;
    }
    
    [parentAlbum release];
    [album release];
	
    return YES;
}



- (BOOL)isAlbum:(NSString *)childAlbumFilePath aChildOfAlbum:(NSString *)parentAlbumFilePath
{
    //it's the same album so, yes
    if ( [parentAlbumFilePath isEqualToString:childAlbumFilePath] ){
        return true;
    }
    
    // load parent album
    NSMutableDictionary *parentAlbum = [FileUtils newDictionaryFromFileInDataDir:parentAlbumFilePath];
    
    //assets album - no children
    if ( [[parentAlbum objectForKey:keyAlbumContentType] isEqualToString:kContentTypeAssets] ){
        [parentAlbum release];
        return NO;
    }
    
    BOOL result = NO;
    NSMutableArray *childAlbums = [parentAlbum objectForKey:keyAlbumItemsArray];
    for (NSString * album in childAlbums){
        if ( [album isEqualToString:childAlbumFilePath] ){
            result = YES;
            break;
        }
        result |= [self isAlbum:childAlbumFilePath aChildOfAlbum:album];
    }
    
    [parentAlbum release];
    return result;
}



#pragma mark - asset ops

- (BOOL)addAsset:(Asset *)asset inAlbum:(NSString *)parentAlbumFilePath{
//    
//    NSLog(@"Adding asset %@ to album %@", [asset.properties objectForKey:albumItemMediaFileKey],albumName);
//    
//    NSMutableDictionary *albumEntry = [self getAlbumNamed:albumName];
//    if(!albumEntry){
//        NSLog(@"Assing asset failed : album does not exist");
//        return NO;
//    }
//
//    NSString *albumFile = [albumEntry objectForKey:libraryAlbumFileKey];
//    
//    NSLog(@"albumFile is: %@",albumFile);
//    
//    NSMutableArray *album = [[NSMutableArray alloc ]initWithContentsOfFile:albumFile];
//   
//    //add a new item to the album 
//    [album addObject:asset.properties];
//    [album writeToFile:albumFile atomically:YES];
//    
//    //update the number of items in the album entry
//    [albumEntry setValue:[NSNumber numberWithUnsignedInteger:album.count] forKey:libraryAlbumNumberOfItemsKey];
//    [album release];
//    return [self saveCurrentUserLibrary];
    return YES;
}



- (BOOL)removeAsset:(Asset *)asset inAlbum:(NSString *)parentAlbumFilePath{
	
	NSLog(@"Removing asset: %@...",asset.mediaFilePath);
    
    //check if the parent album name is nil, or an empty string
    if(!parentAlbumFilePath || [parentAlbumFilePath isEqualToString:@""]){
        return NO;
    }
    
    // load parent album
    NSMutableDictionary *parentAlbum = [FileUtils newDictionaryFromFileInDataDir:parentAlbumFilePath];
    
    if (!parentAlbum){
        return NO;
    }
    
    // get the assets array 	
	NSMutableArray *itemsArray = [parentAlbum objectForKey:keyAlbumItemsArray];
	if(!itemsArray){
		[parentAlbum release];
        return NO;
    }
	
	//remove asset from array
    NSUInteger index = [itemsArray indexOfObject:asset.properties];
    if (index == NSNotFound){
        [parentAlbum release];
        return NO; 
    }
	[itemsArray removeObjectAtIndex:index];
	
	//rebuild index - but there is no index for assetgroups, for now...
    //[self rebuildIndexInAlbum:parentAlbum];
    
    //save parent album
    if(![FileUtils saveDictionaryInDataDir:parentAlbum]){
        [parentAlbum release];
        return NO;
    }
    
    [parentAlbum release];
    return YES;
}


- (NSString *) addDataDirTo:(NSString *)path
{
    return [_dataDirectory stringByAppendingPathComponent:path];
}




@end
