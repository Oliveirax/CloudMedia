//
//  FileManager.m
//  Xmedia
//
//  Created by Luis Oliveira on 7/12/11.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import "FileUtils.h"
#import "LibraryManager.h"
#import "Asset.h"
#import "ZipArchive.h"
#import "UIImage+FX.h"

//#import <AVFoundation/AVFoundation.h>
//#import <AVFoundation/AVAsset.h>


//compression ratio for jpeg encoding - only valid for thumbs
#define kJPEGCompression 0.8

//buffer size to copy files
//#define kBufferSize 8192 //8k
//#define kBufferSize 16384 //16k
//#define kBufferSize 131072 //128k
#define kBufferSize 1048576 // 1Mb

// private stuff
@interface FileUtils()

+ (NSString *)getNextAlbumNameInUserDir:(NSString *) userDir;
+ (NSString *)getNextVidFileNameInUserDir:(NSString *)userDir;
+ (NSString *)getNextImgFileNameInUserDir:(NSString *)userDir;

@end


@implementation FileUtils

static  NSString *documentsDirectory; //Documents - this directory is used for itunes file sharing
static  NSString *libraryDirectory;  //Library
static  NSString *dataDirectory;     //DATA is inside Library. It holds all the user data


+ (NSString *)getDocumentsDirectory
{
    if (!documentsDirectory){
        documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    }
    return documentsDirectory;
}


+ (NSString *)getLibraryDirectory
{
    if (!libraryDirectory){
        libraryDirectory = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    }
    return libraryDirectory;
}


+ (NSString *)getDataDirectory
{
    if (!dataDirectory){
        dataDirectory = [[FileUtils getLibraryDirectory] stringByAppendingPathComponent:kDataDirectoryName];
    }
    return dataDirectory;
}


// creates a directory with the absolute path given
+ (BOOL)createDirectoryAtPath:(NSString *)path
{    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return success;
}


//receives a path relative to data
+ (BOOL)createDirectoryInDataDir:(NSString *)path
{
    NSString *fullPath = [[FileUtils getDataDirectory] stringByAppendingPathComponent:path];
    return [FileUtils createDirectoryAtPath:fullPath];
}



// removes a file with the absolute path given
+ (BOOL)removeItemAtPath:(NSString *)path
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
	BOOL success =  [fileManager removeItemAtPath:path error:&error];
	    
    if (!success){
        NSLog(@"Error removing: %@",path);
        NSLog(@"Error code %d",[error code]);
    }
	return success;
}


//receives a path relative to data
+ (BOOL)removeItemInDataDir:(NSString *)path
{
    if ( path == nil || [path length] == 0) return false;
    
    NSString *fullPath = [[FileUtils getDataDirectory] stringByAppendingPathComponent:path];
    return [FileUtils removeItemAtPath:fullPath];
    return true;
}


//returns USRXXXX
+ (NSString *)getNextUserDirectory
{    
    NSInteger counter = 0;
	NSInteger temp;
	
	// list contents of data directory
   	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *files = [fileManager contentsOfDirectoryAtPath:[FileUtils getDataDirectory] error:NULL];
	    
	for (NSString *filename in files){
		
		if ( [[filename substringWithRange:NSMakeRange(0,3)] isEqualToString:kUserDirectoryPrefix ]){
			temp = [[filename substringWithRange:NSMakeRange(3,4)] intValue ];
			if ( temp > counter)
				counter = temp;
		}
	}
    counter++;
    return [NSString stringWithFormat:@"%@%.4d",kUserDirectoryPrefix,counter];
}


//receives USRXXXX
//returns USRXXXX/ALBUMS/ALBXXXX.plist
+ (NSString *)getNextAlbumNameInUserDir:(NSString *) userDir
{    
    NSInteger counter = 0;
	NSInteger temp;
    
    // list contents of albums directory
    NSString *relPath = [userDir stringByAppendingPathComponent:kAlbumsDirectoryName];
    NSString *albumsPath = [[FileUtils getDataDirectory] stringByAppendingPathComponent:relPath];
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: albumsPath error: NULL];
    
    // iterate
	for (NSString *filename in files){
		
		if ( [[filename substringWithRange:NSMakeRange(0,3)] isEqualToString:kAlbumFilePrefix]){
			temp = [[filename substringWithRange:NSMakeRange(3,4)] intValue ];
			if ( temp > counter)
				counter = temp;
		}
	}
    counter++;
    return [relPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%.4d.plist",kAlbumFilePrefix,counter]];
}



//receives USRXXXX
//returns VIDXXXX.M4V
+ (NSString *)getNextVidFileNameInUserDir:(NSString *)userDir
{    
	NSInteger counter = 0;
	NSInteger temp;
    
    // list contents of media directory
    NSString *userDirPath = [[FileUtils getDataDirectory] stringByAppendingPathComponent:userDir];
    NSString *mediaPath = [userDirPath stringByAppendingPathComponent:kMediaDirectoryName];
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: mediaPath error: NULL];
	
	for (NSString *filename in files){
		if ( [[filename substringWithRange:NSMakeRange(0,3)] isEqualToString:kVideoFilePrefix ]){
			temp = [[filename substringWithRange:NSMakeRange(3,4)] intValue ];
			if ( temp > counter)
				counter = temp;
		}
	}
	counter++;
	return [NSString stringWithFormat:@"%@%.4d.M4V",kVideoFilePrefix,counter];
}



//receives USRXXXX
//returns IMGXXXX.JPG
+ (NSString *)getNextImgFileNameInUserDir:(NSString *)userDir
{    
	NSInteger counter = 0;
	NSInteger temp;
	
	// list contents of media directory
    NSString *userDirPath = [[FileUtils getDataDirectory] stringByAppendingPathComponent:userDir];
    NSString *mediaPath = [userDirPath stringByAppendingPathComponent:kMediaDirectoryName];
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: mediaPath error: NULL];
	
	for (NSString *filename in files){
		if ( [[filename substringWithRange:NSMakeRange(0,3)] isEqualToString:kImageFilePrefix ]){
			temp = [[filename substringWithRange:NSMakeRange(3,4)] intValue ];
			if ( temp > counter)
				counter = temp;
		}
	}
	counter++;
	return [NSString stringWithFormat:@"%@%.4d.JPG",kImageFilePrefix,counter];
}



+ (BOOL)saveALAsset:(Asset *)asset inUserDir:(NSString *)userDir
                    withTaskProgressDelegate:(id <TaskProgressDelegate>)taskProgressDelegate
                          andProgressPerByte:(CGFloat)progressPerByte
{
    NSString *relPath; //path, relative to DATA
    NSString *name;
	NSString *file;
	NSData *data;
    
	BOOL success = YES;
    
        // generate a file name
    if ([asset.type isEqualToString:kAssetTypeImage]){
        name = [FileUtils getNextImgFileNameInUserDir:userDir];
    }
    else if ([asset.type isEqualToString:kAssetTypeVideo]){
        name = [FileUtils getNextVidFileNameInUserDir:userDir];
        
        //save a video capture, in case of a video file
        data = [NSData dataWithData:UIImageJPEGRepresentation([asset image],kJPEGCompression)];
        relPath = [userDir stringByAppendingPathComponent:kFullScreenDirectoryName];
        relPath = [relPath stringByAppendingPathComponent:name];
		file = [[FileUtils getDataDirectory] stringByAppendingPathComponent:relPath];
		success &= [data writeToFile:file atomically:NO];
        asset.fullScreenFilePath = relPath;
    }
    else{
        NSLog(@"FileManager tried to save an unknown asset type");
        return NO;
    }
    
	// save the thumb
    data = [NSData dataWithData:UIImageJPEGRepresentation([asset thumbnail],kJPEGCompression)];
    relPath = [userDir stringByAppendingPathComponent:kThumbsDirectoryName];
    relPath = [relPath stringByAppendingPathComponent:name];
    file = [[FileUtils getDataDirectory] stringByAppendingPathComponent:relPath];
    success &= [data writeToFile:file atomically:NO];
    asset.thumbFilePath = relPath;
    
    //save the media
    ALAssetRepresentation *assetRepresentation = [asset.theALAsset defaultRepresentation];
	
	//create a new file and open it for writing
    relPath = [userDir stringByAppendingPathComponent:kMediaDirectoryName];
    relPath = [relPath stringByAppendingPathComponent:name];
    file = [[FileUtils getDataDirectory] stringByAppendingPathComponent:relPath];
	NSFileManager *fm = [NSFileManager defaultManager];
	[fm createFileAtPath:file contents:nil attributes:nil];
	NSFileHandle *outFile = [NSFileHandle fileHandleForWritingAtPath:file];
	
	NSUInteger bytes;
	NSUInteger counter = 0;
	//NSLog(@"allocating buffer...");
	uint8_t *buffer = (uint8_t *)(malloc(kBufferSize * sizeof(uint8_t)));
	
		
	do{
        @autoreleasepool {
        		
            bytes = [assetRepresentation getBytes:buffer fromOffset:counter*kBufferSize length:kBufferSize error:nil];
            data = [NSData dataWithBytesNoCopy:buffer length:bytes freeWhenDone:NO];
		
            //success &= [data writeToFile:file atomically:YES];
            [outFile writeData:data];
            counter++;
		
            //update the progress bar
            [taskProgressDelegate taskProgressed:bytes*progressPerByte];
        } //[pool drain];
		
	} while (bytes == kBufferSize);
	
	free(buffer);
   	[outFile closeFile];
    
    asset.mediaFilePath = relPath;
    asset.isALAsset = NO;  //turn ALAsset into a regular asset

    return success;
}


+ (Asset *)saveFileAsset:(NSString *)file inUserDir:(NSString *)userDir
{
    NSString *relPath; //path, relative to DATA
    NSString *name;
    NSMutableDictionary *properties = [[NSMutableDictionary alloc]init];
    NSFileManager *fileManager = [NSFileManager defaultManager];
	//NSData *data;
    
    if (![fileManager fileExistsAtPath:file]){
        NSLog(@"FileUtils tried to save a file asset that does not exist");
        return nil;
    }
    
	// image or video?
    if ([FileUtils isImageFile:file]){
        name = [FileUtils getNextImgFileNameInUserDir:userDir];
        [properties setValue:kAssetTypeImage forKey:keyAssetType];
        
        // save thumbnail
        UIImage *temp  = [UIImage imageWithContentsOfFile:file];
        UIImage *thumb = [temp imageCroppedAndScaledToSize:CGSizeMake(55, 55)
                                                contentMode:UIViewContentModeScaleAspectFill
                                                   padToFit:NO];
        relPath = [FileUtils saveThumb:thumb inUserDir:userDir withName:name];
        [properties setValue:relPath forKey:keyAssetThumbFilePath];
        
    }
    else if ([FileUtils isVideoFile:file]){
        name = [FileUtils getNextVidFileNameInUserDir:userDir];
        [properties setValue:kAssetTypeVideo forKey:keyAssetType];
        
        //save a video capture, thumbnail and duration,
        MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:file]];
        player.shouldAutoplay = NO;
        [player prepareToPlay];
        UIImage *fscap = [player thumbnailImageAtTime:1.5 timeOption:MPMovieTimeOptionNearestKeyFrame];
        relPath = [FileUtils saveFSImage:fscap inUserDir:userDir withName:name];
        [properties setValue:relPath forKey:keyAssetFullScreenFilePath];
        
        UIImage *thumb = [fscap imageCroppedAndScaledToSize:CGSizeMake(55, 55)
                                                 contentMode:UIViewContentModeScaleAspectFill
                                                    padToFit:NO];
        relPath = [FileUtils saveThumb:thumb inUserDir:userDir withName:name];
        [properties setValue:relPath forKey:keyAssetThumbFilePath];
        
        NSTimeInterval duration = [player duration];
        NSLog(@"MPMVPLAYER duration: %.2f", duration);
        [properties setValue:@(duration) forKey:keyAssetDuration];
        [player stop];
        [player release];
        
        /*
        //get the duration with a different method
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:file]];
        
        
        CMTime duration2 = playerItem.duration;
        float seconds = CMTimeGetSeconds(duration2);
        NSLog(@"AVPLAYER duration: %.2f", seconds);
         */
    }
    else{
        NSLog(@"FileUtils tried to save a file asset of unknown type");
        return nil;
    }
    
    //size
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:file error:NULL];
    [properties setValue:[NSNumber numberWithLongLong:[fileAttributes fileSize]] forKey:keyAssetSize];
    
    
    //move the media
    relPath = [userDir stringByAppendingPathComponent:kMediaDirectoryName];
    relPath = [relPath stringByAppendingPathComponent:name];
    NSString *target  = [[FileUtils getDataDirectory] stringByAppendingPathComponent:relPath];
    [fileManager moveItemAtPath:file toPath:target error:NULL];
    [properties setValue:relPath forKey:keyAssetMediaFilePath];
    
    //create asset
    Asset *asset = [[Asset alloc] initWithDictionary:properties];
    [properties release];
    return asset;
}




+ (NSString *)saveThumb:(UIImage *)thumb inUserDir:(NSString *)userDir withName:(NSString *)name
{
    NSString *relPath; //path, relative to DATA
	NSString *file;
	NSData *data;
    
    relPath = [userDir stringByAppendingPathComponent:kThumbsDirectoryName];
    relPath = [relPath stringByAppendingPathComponent:name];
    file = [[FileUtils getDataDirectory] stringByAppendingPathComponent:relPath];
    data = [NSData dataWithData:UIImageJPEGRepresentation(thumb,kJPEGCompression)];
    if ( [data writeToFile:file atomically:NO] ){
        return relPath;
    }
    return nil;
}


+ (NSString *)saveFSImage:(UIImage *)image inUserDir:(NSString *)userDir withName:(NSString *)name
{
    NSString *relPath; //path, relative to DATA
	NSString *file;
	NSData *data;
    
    relPath = [userDir stringByAppendingPathComponent:kFullScreenDirectoryName];
    relPath = [relPath stringByAppendingPathComponent:name];
    file = [[FileUtils getDataDirectory] stringByAppendingPathComponent:relPath];
    data = [NSData dataWithData:UIImageJPEGRepresentation(image,kJPEGCompression)];
    if ( [data writeToFile:file atomically:NO] ){
        return relPath;
    }

    return nil;
}


+ (NSString *)moveMedia:(NSString *)path toUserDir:(NSString *)userDir withName:(NSString *)name
{
    NSString *relPath; //path, relative to DATA
	NSString *file;
    BOOL result;
    
    relPath = [userDir stringByAppendingPathComponent:kFullScreenDirectoryName];
    relPath = [relPath stringByAppendingPathComponent:name];
    file = [[FileUtils getDataDirectory] stringByAppendingPathComponent:relPath];
    result = [[NSFileManager defaultManager] moveItemAtPath:path toPath:file error:nil];
    if ( result ){
        return relPath;
    }
    return nil;
}



//save a dictionary, its path should be relative to DATA
+ (BOOL)saveDictionaryInDataDir:(NSMutableDictionary *)dict
{
    NSString *path = [[FileUtils getDataDirectory] stringByAppendingPathComponent:dict[keySelfFilePath]];
    return [dict writeToFile:path atomically:YES];
}



//load a dictionary, its path should be relative to DATA, receiver should NOT retain return value, but should release it
+ (NSMutableDictionary *)newDictionaryFromFileInDataDir:(NSString *)path
{
    NSString *fullPath = [[FileUtils getDataDirectory] stringByAppendingPathComponent:path];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc ]initWithContentsOfFile:fullPath];
    return dict;
}



//load an asset in a user's dir. the name is the filename 
+ (Asset *)loadAssetInUserDir:(NSString *)userDir withName:(NSString *)name
{
	NSString *relPath;
	NSString *file;
	NSMutableDictionary *properties = [[NSMutableDictionary alloc]init];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	//media , size
	relPath =[userDir stringByAppendingPathComponent:kMediaDirectoryName];
	relPath = [relPath stringByAppendingPathComponent:name];
	file = [[FileUtils getDataDirectory] stringByAppendingPathComponent:relPath];
	if ([fileManager fileExistsAtPath:file]){
		[properties setValue:relPath forKey:keyAssetMediaFilePath];
		NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:file error:NULL];
		[properties setValue:[NSNumber numberWithLongLong:[fileAttributes fileSize]] forKey:keyAssetSize];
	}
	
	//thumb
	relPath =[userDir stringByAppendingPathComponent:kThumbsDirectoryName];
	relPath = [relPath stringByAppendingPathComponent:name];
	file = [[FileUtils getDataDirectory] stringByAppendingPathComponent:relPath];
	if ([fileManager fileExistsAtPath:file]){
		[properties setValue:relPath forKey:keyAssetThumbFilePath];
	}

	
	//fullScreen
	relPath =[userDir stringByAppendingPathComponent:kFullScreenDirectoryName];
	relPath = [relPath stringByAppendingPathComponent:name];
	file = [[FileUtils getDataDirectory] stringByAppendingPathComponent:relPath];
	if ([fileManager fileExistsAtPath:file]){
		[properties setValue:relPath forKey:keyAssetFullScreenFilePath];
	}
	
	//vidcap
	relPath =[userDir stringByAppendingPathComponent:kVidcapsDirectoryName];
	relPath = [relPath stringByAppendingPathComponent:name];
	file = [[FileUtils getDataDirectory] stringByAppendingPathComponent:relPath];
	if ([fileManager fileExistsAtPath:file]){
		[properties setValue:relPath forKey:keyAssetVidcapFilePath];
	}
	
	//type and duration
	if ([name hasPrefix:kImageFilePrefix ]){
		[properties setValue:kAssetTypeImage forKey:keyAssetType];
        [properties setValue:@-1.0 forKey:keyAssetDuration];
	}
	else if ([name hasPrefix:kVideoFilePrefix]){
		[properties setValue:kAssetTypeVideo forKey:keyAssetType];
        [properties setValue:@0.0 forKey:keyAssetDuration];
	}
	
	Asset *asset = [[Asset alloc ]initWithDictionary:properties];
	[properties release];
	return [asset autorelease];
}



// this is used to mark files that are to be excluded from iCloud backup
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
 
    NSError *error = nil;
    BOOL success = [URL setResourceValue: @YES
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}



+ (BOOL)createZippedArchive:(NSString *)archivePath fromPath:(NSString *)sourcePath {
    return YES;
}



+ (BOOL)unzipArchive:(NSString *)archivePath intoPath:(NSString *)destinationPath {
    
    ZipArchive* zip = [[ZipArchive alloc] init];
    if([zip UnzipOpenFile:archivePath] )
    {
        BOOL ret = [zip UnzipFileTo:destinationPath overWrite:YES];
        if(ret == NO)
        {
            NSLog(@"Error unzipping file");
        }
        [zip UnzipCloseFile];
    }
    [zip release];
    NSLog(@"The file has been unzipped");
    return YES;
}


+ (BOOL) isVideoFile:(NSString *)file
{
    NSString *extension = [[file pathExtension] uppercaseString];
    
    for (int i = 0; i < kVideoTypesSize; i++){
        if ([extension isEqualToString:kVideoTypes[i]]) return YES;
    }
    return NO;
}


+ (BOOL) isImageFile:(NSString *)file
{
    NSString *extension = [[file pathExtension] uppercaseString];
    
    for (int i = 0; i < kImageTypesSize; i++){
        if ([extension isEqualToString:kImageTypes[i]]) return YES;
    }
    return NO;
}



/*
+ (UIImage *)resizeImage:(UIImage *)originalImage width:(CGFloat)resizedWidth height:(CGFloat)resizedHeight
{
    CGImageRef imageRef = [originalImage CGImage];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmap = CGBitmapContextCreate(NULL, resizedWidth, resizedHeight, 8, 4 * resizedWidth, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(bitmap, CGRectMake(0, 0, resizedWidth, resizedHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage *result = [UIImage imageWithCGImage:ref];
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return result;
}
*/




/*
+ (Asset *)loadAssetAtPath:(NSString *)path withName:(NSString *)name
{
	NSString *dirPath;
	NSString *file;
	NSMutableDictionary *properties = [[NSMutableDictionary alloc]init];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	//media, size
	dirPath = [path stringByAppendingPathComponent:kMediaDirectoryName];
	file = [dirPath stringByAppendingPathComponent:name];
	if ([fileManager fileExistsAtPath:file]){
		[properties setValue:file forKey:keyAssetMediaFilePath];
		NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:file error:NULL];
		[properties setValue:[NSNumber numberWithLongLong:[fileAttributes fileSize]] forKey:keyAssetSize];
	}
	
	//thumb
	dirPath = [path stringByAppendingPathComponent:kThumbsDirectoryName];
	file = [dirPath stringByAppendingPathComponent:name];
	if ([fileManager fileExistsAtPath:file]){
		[properties setValue:file forKey:keyAssetThumbFilePath];
	}

	
	//fullScreen
	dirPath = [path stringByAppendingPathComponent:kFullScreenDirectoryName];
	file = [dirPath stringByAppendingPathComponent:name];
	if ([fileManager fileExistsAtPath:file]){
		[properties setValue:file forKey:keyAssetFullScreenFilePath];
	}
	
	//vidcap
	dirPath = [path stringByAppendingPathComponent:kVidcapsDirectoryName];
	file = [dirPath stringByAppendingPathComponent:name];
	if ([fileManager fileExistsAtPath:file]){
		[properties setValue:file forKey:keyAssetVidcapFilePath];
	}
	
	//type
	if ([name hasPrefix:kImageFilePrefix ]){
		[properties setValue:kAssetTypeImage forKey:keyAssetType];
	}
	else if ([name hasPrefix:kVideoFilePrefix]){
		[properties setValue:kAssetTypeVideo forKey:keyAssetType];
	}
	
	Asset *asset = [[Asset alloc ]initWithDictionary:properties];
	[properties release];
	return [asset autorelease];
}
 */




@end