//
//  CliupboardManager.m
//  Xmedia
//
//  Created by Luis Oliveira on 7/13/11.
//

#import "ClipboardManager.h"
#import "LibraryManager.h"
#import "FileUtils.h"
#import "AssetsLibrary.h"
#import "AssetsGroup.h"
#import "Asset.h"


NSUInteger const contentTypeGroups  = 0;
NSUInteger const contentTypeAssets  = 1;
NSUInteger const contentTypeFiles  = 2;
//NSUInteger const operationModeCopy = 0;
//NSUInteger const operationModeMove = 1;
//NSUInteger const operationModeLink = 2;


#pragma mark - private interface
@interface ClipboardManager()

- (id)init; // private constructor
- (long long)calculateSizeOfAssetsLibrary:(AssetsLibrary *)library;
- (long long)calculateSizeOfAssetsGroup:(AssetsGroup *)group;
- (void)saveLibrary:(AssetsLibrary*)objectLib inLibrary:(NSString *)targetLibFilePath;
- (void)saveAssetsGroup:(AssetsGroup *)group inLibrary:(NSString *)libraryFilePath;
- (void)saveLibrary:(AssetsLibrary*)library inAssetsGroup:(NSString *)groupFilePath;
- (void)saveAssetsGroup:(AssetsGroup*)objectGroup inAssetsGroup:(NSString *)targetGroupFilePath;
- (void)saveAssets:(NSMutableArray *)assets inAlbum:(NSString *)albumFilePath;

@end



@implementation ClipboardManager

@synthesize taskProgressDelegate;


#pragma mark - init and dealloc

static ClipboardManager* instance;

+ (ClipboardManager *)getInstance{
	
	@synchronized(self) {
		if(!instance) {
			instance = [[ClipboardManager alloc] init];
		}
	}
	return instance;
}

- (id)init{
	
	if ((self = [super init])){
        clipboard = [[NSMutableArray alloc ]init];
        [self resetClipboard];
    }
    return self;
}



- (void)dealloc{
    [clipboard release];
    [super dealloc];
}



#pragma mark - Set clipboard mode

- (void)setModeToGroups
{
    contentType = contentTypeGroups;
    //operationMode = operationModeCopy;
}

/*
- (void)setModeToGroupsLink
{
    contentType = contentTypeGroups;
    //operationMode = operationModeLink;
}


- (void)setModeToGroupsMove
{
    contentType = contentTypeGroups;
    //operationMode = operationModeMove;
}
*/

- (void)setModeToAssets
{
    contentType = contentTypeAssets;
    //operationMode = operationModeCopy;
}

/*
- (void)setModeToAssetsLink
{
    contentType = contentTypeAssets;
    //operationMode = operationModeLink;
}


- (void)setModeToAssetsMove
{
    contentType = contentTypeAssets;
    //operationMode = operationModeMove;
}
*/

- (void)setModeToFiles
{
    contentType = contentTypeFiles;
    //operationMode = operationModeMove;
}

/*
- (void)setModeToFilesCopy
{
    contentType = contentTypeFiles;
    //operationMode = operationModeCopy;
}
*/

#pragma mark - Add items to clipboard

- (void)addAssetsLibrary:(AssetsLibrary *)library
{
    if ( contentType != contentTypeGroups ){
        NSLog(@"Error: trying to add AssetsLibrary to a clipboard not set for that");
        return;
    }
    
    itemsInClipboard++;
    bytesInClipboard += [self calculateSizeOfAssetsLibrary:library];
    [clipboard addObject:library];
}



- (void)addAssetsGroup:(AssetsGroup *)group
{
    if ( contentType != contentTypeGroups ){
        NSLog(@"Error: trying to add AssetsGroup to a clipboard not set for that");
        return;
    }
    
    itemsInClipboard++;
    bytesInClipboard += [self calculateSizeOfAssetsGroup:group];
	[clipboard addObject:group];
}


- (void)addAsset:(Asset *)asset
{
    if ( contentType != contentTypeAssets ){
        NSLog(@"Error: trying to add Asset to a clipboard not set for that");
        return;
    }
    
    itemsInClipboard++;
    bytesInClipboard += asset.size;
	[clipboard addObject:asset];
}

- (void)addFile:(NSString *)file
{
    if ( contentType != contentTypeFiles ){
        NSLog(@"Error: trying to add File to a clipboard not set for that");
        return;
    }
    
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDirectory;
    BOOL exists = [ fm fileExistsAtPath:file isDirectory:&isDirectory];
    
    if ( exists && !isDirectory){ //TODO take care of directories
        
        NSDictionary *fileAttributes = [fm attributesOfItemAtPath:file error:NULL];
        bytesInClipboard += [fileAttributes fileSize];
        itemsInClipboard++;
        [clipboard addObject:file];
    }
    else{
        NSLog(@"Error: trying to add non-existant File or a Directory to clipboard");
    }
}


#pragma mark - Paste clipboard

- (void)pasteInAssetsLibrary:(AssetsLibrary *)library
{    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc ]init];
    progressPerByte = 1.0f/bytesInClipboard;
    
    if(contentType == contentTypeGroups){
        for (id<Group> a in clipboard){
            
            if ([a isMemberOfClass:[AssetsLibrary class]]){
               
				NSLog(@"paste AssetsLibrary: %@ in Library: %@",a.name , library.name);
				[self saveLibrary:a inLibrary:library.selfFilePath];
			}
            else if ([a isMemberOfClass:[AssetsGroup class]]){
                
				NSLog(@"paste AssetsGroup: %@ in Library: %@",a.name , library.name);
				[self saveAssetsGroup:a inLibrary:library.selfFilePath];
            }
        }   
    }
	
	//cannot paste assets directly inside a library - create an album for them
    else if(contentType == contentTypeAssets){ 
		
		NSLog(@"paste Assets in Library: %@", library.name);
		NSString *newAlbumPath = [[LibraryManager getInstance] createAlbumWithName:kNewAlbumName inAlbum:library.selfFilePath];
		if( !newAlbumPath){
			newAlbumPath = [[LibraryManager getInstance] createAlbumWithGeneratedName:kNewAlbumName inAlbum:library.selfFilePath];
		}
		
		// set the album as assets album
		NSMutableDictionary *album = [FileUtils newDictionaryFromFileInDataDir:newAlbumPath];
		[album setObject:kContentTypeAssets forKey:keyAlbumContentType];
		[FileUtils saveDictionaryInDataDir:album];
		[album release];
		
		[self saveAssets:clipboard inAlbum:newAlbumPath];
    }
    else if(contentType == contentTypeFiles){
        
        NSLog(@"paste Files in Library: %@", library.name);
		NSString *newAlbumPath = [[LibraryManager getInstance] createAlbumWithName:kNewAlbumName inAlbum:library.selfFilePath];
		if( !newAlbumPath){
			newAlbumPath = [[LibraryManager getInstance] createAlbumWithGeneratedName:kNewAlbumName inAlbum:library.selfFilePath];
		}
		
		// set the album as assets album
		NSMutableDictionary *album = [FileUtils newDictionaryFromFileInDataDir:newAlbumPath];
		[album setObject:kContentTypeAssets forKey:keyAlbumContentType];
		[FileUtils saveDictionaryInDataDir:album];
		[album release];
        
        //turn the files into assets
        NSString *userDir = [[LibraryManager getInstance].currentUser objectForKey:keyUsersUserDirectoryPath ];
        NSMutableArray *assets = [[NSMutableArray alloc] init];
        Asset *asset;
        
        for ( NSString *file in clipboard){
            if ((asset = [FileUtils saveFileAsset:file inUserDir:userDir])){
                [assets addObject:asset];
                [asset release];
                [taskProgressDelegate taskProgressed:asset.size*progressPerByte];
            }
        }
        [self saveAssets:assets inAlbum:newAlbumPath];
        [assets release];
    }
    
    [taskProgressDelegate taskCompleted];
    taskProgressDelegate = nil;
    [pool drain];
}



- (void)pasteInAssetsGroup:(AssetsGroup *)group
{    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc ]init];
    progressPerByte = 1.0f/bytesInClipboard;
	
	if(contentType == contentTypeGroups){
        for (id<Group> a in clipboard){
            
            if ([a isMemberOfClass:[AssetsLibrary class]]){
				
				NSLog(@"paste AssetsLibrary: %@ in group: %@",a.name , group.name);
				[self saveLibrary:a inAssetsGroup:group.selfFilePath];
			}
            else if ([a isMemberOfClass:[AssetsGroup class]]){
                
				NSLog(@"paste AssetsGroup: %@ in group: %@",a.name , group.name);
				[self saveAssetsGroup:a inAssetsGroup:group.selfFilePath];
            }
        }   
    }
	
    else if(contentType == contentTypeAssets){
		
		NSLog(@"paste Assets in group: %@", group.name);
		[self saveAssets:clipboard inAlbum:group.selfFilePath];
    }
    else if(contentType == contentTypeFiles){
        
        //turn the files into assets
        NSString *userDir = [[LibraryManager getInstance].currentUser objectForKey:keyUsersUserDirectoryPath ];
        NSMutableArray *assets = [[NSMutableArray alloc] init];
        Asset *asset;
        
        for ( NSString *file in clipboard){
            if ((asset = [FileUtils saveFileAsset:file inUserDir:userDir])){
                [assets addObject:asset];
                [asset release];
                [taskProgressDelegate taskProgressed:asset.size*progressPerByte];
            }
        }
        
        [self saveAssets:assets inAlbum:group.selfFilePath];
        [assets release];
    }


    [taskProgressDelegate taskCompleted];
    taskProgressDelegate = nil;
    [pool drain];
}




#pragma mark - Calculate sizes

- (long long)calculateSizeOfAssetsLibrary:(AssetsLibrary *)library
{
    long long size = 0;
    NSMutableArray *items = [[library enumerateGroups]retain];
    
    for (id<Group> a in items){
        if ([a isMemberOfClass:[AssetsLibrary class]]){
            size += [self calculateSizeOfAssetsLibrary:a];
        }
        else if ([a isMemberOfClass:[AssetsGroup class]]){
            size += [self calculateSizeOfAssetsGroup:a];
        }
    }
    [items release];
    return size;
}



- (long long)calculateSizeOfAssetsGroup:(AssetsGroup *)group
{
    long long size = 0;
    NSMutableArray *assets = [[group enumerateAssets]retain];
    for (Asset *a in assets){
        size +=a.size;
    }
    [assets release];
    return size;
}


/*
- (long long)calculateSizeOfDirectory:(NSString *)file
{
    long long size = 0;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if ([ fm fileExistsAtPath:file]){
    
        NSDictionary *fileAttributes = [fm attributesOfItemAtPath:file error:NULL];
        size = fileAttributes fileSize;
        }
    return size;
}
*/



#pragma mark - Save 

- (void)saveLibrary:(AssetsLibrary*)objectLib inLibrary:(NSString *)targetLibFilePath
{
    //verify if we are pasting a library onto itself - it will result in an infinite loop
    if ( [[LibraryManager getInstance] isAlbum:targetLibFilePath aChildOfAlbum:objectLib.selfFilePath] ){
        NSLog(@"ERROR: Cannot paste an album onto itself");
        return;
    }
    
	NSString *newLibraryPath = [[LibraryManager getInstance] createAlbumWithName:objectLib.name inAlbum:targetLibFilePath];
	if( !newLibraryPath){
		newLibraryPath = [[LibraryManager getInstance] createAlbumWithGeneratedName:objectLib.name inAlbum:targetLibFilePath];
	}
	
	NSMutableArray *groups = [[objectLib enumerateGroups]retain];
	for (id<Group> a in groups){
		if ([a isMemberOfClass:[AssetsLibrary class]]){
			[self saveLibrary:a inLibrary:newLibraryPath];
		}
		else if ([a isMemberOfClass:[AssetsGroup class]]){
			[self saveAssetsGroup:a inLibrary:newLibraryPath];
		}
	}
	[groups release];
}



- (void)saveAssetsGroup:(AssetsGroup *)group inLibrary:(NSString *)libraryFilePath
{
	NSString *newAlbumPath = [[LibraryManager getInstance] createAlbumWithName:group.name inAlbum:libraryFilePath];
	if( !newAlbumPath){
		newAlbumPath = [[LibraryManager getInstance] createAlbumWithGeneratedName:group.name inAlbum:libraryFilePath];
	}
	
	// set the album as assets album
	NSMutableDictionary *album = [FileUtils newDictionaryFromFileInDataDir:newAlbumPath];
	[album setObject:kContentTypeAssets forKey:keyAlbumContentType];
    [FileUtils saveDictionaryInDataDir:album];
    [album release];

	
	NSMutableArray *assets = [[group enumerateAssets]retain];
	[self saveAssets:assets inAlbum:newAlbumPath];
	[assets release];
}



- (void)saveLibrary:(AssetsLibrary*)library inAssetsGroup:(NSString *)groupFilePath
{
	NSMutableArray *groups = [[library enumerateGroups]retain];
	for (id<Group> a in groups){
		if ([a isMemberOfClass:[AssetsLibrary class]]){
			[self saveLibrary:a inAssetsGroup:groupFilePath];
		}
		else if ([a isMemberOfClass:[AssetsGroup class]]){
			[self saveAssetsGroup:a inAssetsGroup:groupFilePath];
		}
	}
	[groups release];
}



- (void)saveAssetsGroup:(AssetsGroup*)objectGroup inAssetsGroup:(NSString *)targetGroupFilePath
{
	NSMutableArray *assets = [[objectGroup enumerateAssets]retain];
	[self saveAssets:assets inAlbum:targetGroupFilePath];
	[assets release];
}



//this method assumes the given album exists
- (void)saveAssets:(NSMutableArray *)assets inAlbum:(NSString *)albumFilePath
{
    NSMutableDictionary *album = [FileUtils newDictionaryFromFileInDataDir:albumFilePath];
    
	
    NSMutableArray *itemsArray = [album objectForKey:keyAlbumItemsArray];

    for (Asset *asset in assets){
        
       // if (operationMode == operationModeCopy){
            // save ALAsset to disk
            if (asset.isALAsset){
				NSString *path = [[LibraryManager getInstance].currentUser objectForKey:keyUsersUserDirectoryPath ];
                [FileUtils saveALAsset:asset inUserDir:path withTaskProgressDelegate:taskProgressDelegate andProgressPerByte:progressPerByte];
                NSLog(@"Saved Asset: %@", [asset  mediaFilePath]);
            }
            else{
                //save file asset to disk (copy)
            }
      //  }
		
		[itemsArray addObject:asset.properties];
		//[taskProgressDelegate taskProgressed:asset.size*progressPerByte];
    }
    
    // rebuild index and save album   
    //NSLog(@"SaveAssets : rebuilding index");
    //[[LibraryManager getInstance]rebuildIndexInAlbum:album];
    NSLog(@"SaveAssets : writing album to file");
//    if(![album writeToFile:albumFilePath atomically:YES]){
//        NSLog(@"SaveAssets : Error saving album plist %@!",albumFilePath);
//    }
    [FileUtils saveDictionaryInDataDir:album];
    [album release];
}



- (void) resetClipboard{
     bytesInClipboard = 0;
    itemsInClipboard = 0;
    progressPerByte = 0;
    [clipboard removeAllObjects];
}

@end

