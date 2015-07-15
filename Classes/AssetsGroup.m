//
//  AssetsGroup.m
//  Xmedia
//
//  Created by Luis Filipe Oliveira on 11/23/10.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "AssetsGroup.h"
#import "Asset.h"
#import "LibraryManager.h"
#import "FileUtils.h"
#import "UIImage+FX.h"


#pragma mark - Private interface
@interface AssetsGroup()

//-(UIImage *)resizeImage:(UIImage *)originalImage width:(CGFloat)resizedWidth height:(CGFloat)resizedHeight;

@end

@implementation AssetsGroup

@synthesize name;
@synthesize isALAsset;
@synthesize selfFilePath;
@synthesize thumbFilePath;
@synthesize selected;
@synthesize posterImage;
@synthesize numberOfItems;


#pragma mark -
#pragma mark Init and dealloc

- (id)initWithDictionary:(NSMutableDictionary *)dict
{
    if ((self = [super init])){
        selfFilePath = [dict[keySelfFilePath]copy];
        thumbFilePath = [dict[keyAlbumThumbFilePath]copy];
        name = [dict[keyAlbumName]copy];
        numberOfAssets = [dict[keyAlbumItemsArray]count];
        
		deviceGroup = nil;
		image = nil;
		isALAsset = NO;
        selected = NO;
	}
	return self;

}

- (id)initWithPath:(NSString *)path
{
    NSMutableDictionary *dict = [FileUtils newDictionaryFromFileInDataDir:path];
    AssetsGroup *ag = [self initWithDictionary:dict];
    [dict release];
    return ag;
}

/*
- (id)initWithPath:(NSString *)path{
	
    if ((self = [super init])){
        NSMutableDictionary *dict = [[NSMutableDictionary alloc ]initWithContentsOfFile:path];
		selfFilePath = [[dict objectForKey:keySelfFilePath]copy];
        thumbFilePath = [[dict objectForKey:keyAlbumThumbFilePath]copy];
        name = [[dict objectForKey:keyAlbumName]copy];
        numberOfAssets = [[dict objectForKey:keyAlbumItemsArray]count];
        [dict release];
        
		deviceGroup = nil;
		image = nil;
		isALAsset = NO;
        selected = NO;	
    }
	return self;
}
*/

- (id)initWithGroup:(ALAssetsGroup *)group{
	if ((self = [super init])){
		deviceGroup = [group retain];
		name = [[group valueForProperty:ALAssetsGroupPropertyName]copy];
        
        ALAssetsFilter *allAssetsFilter = [ALAssetsFilter allAssets];
		[deviceGroup setAssetsFilter:allAssetsFilter];
        numberOfAssets = [deviceGroup numberOfAssets];
         
        selfFilePath = nil;
        thumbFilePath = nil;
        
		image = nil;
		isALAsset = YES;
        selected = NO;	
	}
	return self;
}


- (void)dealloc {
	
	//NSLog(@"AssetsGroup release");
	[name release];
	if (image) [image release];
    if (selfFilePath) [selfFilePath release];
	if (thumbFilePath) [thumbFilePath release];
	if (deviceGroup ) [deviceGroup release];
    [super dealloc];
}



- (NSUInteger)numberOfItems
{
    return numberOfAssets;
}


- (void)updateNumberOfItems
{ 	
	if (isALAsset) {
        ALAssetsFilter *allAssetsFilter = [ALAssetsFilter allAssets];
		[deviceGroup setAssetsFilter:allAssetsFilter];
		numberOfAssets =  [deviceGroup numberOfAssets];
	}
	else {
        NSMutableDictionary *album = [FileUtils newDictionaryFromFileInDataDir:selfFilePath];
        NSMutableArray *items = album[keyAlbumItemsArray];
        numberOfAssets = [items count];
        [album release];
	}
}



- (NSMutableArray *)enumerateAssets{
	
	NSLog(@"AssetsGroup: EnumerateAssets");
	NSMutableArray *assets = [[NSMutableArray alloc]init];
	
	if (isALAsset){
	
		ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
			
			if (result) {
                NSLog(@"Creating device Asset: %@",[result valueForProperty:ALAssetPropertyType]);
				Asset *newAsset = [[Asset alloc]initWithAsset:result];
				[assets addObject:newAsset];
				[newAsset release];
			}
            else{
                NSLog(@"processing of device Assets finished"); 
            }
		};
		
		// ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
		//[assetsGroup setAssetsFilter:onlyPhotosFilter];

		ALAssetsFilter *allAssetsFilter = [ALAssetsFilter allAssets];
		[deviceGroup setAssetsFilter:allAssetsFilter];
		[deviceGroup enumerateAssetsUsingBlock:assetsEnumerationBlock];
		
	}
	else {
        NSMutableDictionary *album = [FileUtils newDictionaryFromFileInDataDir:selfFilePath];
		NSMutableArray *items = album[keyAlbumItemsArray];
        for (NSMutableDictionary *item in items){
            
            NSLog(@"Creating Normal Asset");
            Asset *asset = [[Asset alloc] initWithDictionary:item];
			//NSLog(@"Created Normal Asset: %@",asset.mediaFilePath);
            [assets addObject:asset];
            [asset release];
        }
        [album release];
	}
    
	return [assets autorelease];
}



- (UIImage *)posterImage{
	if (image == nil) {
		
		if (isALAsset){
			CGImageRef posterImageRef = [deviceGroup posterImage];
			image = [[UIImage imageWithCGImage:posterImageRef]retain];
		}
		else {
            
            //we already have a poster image? load it!
            if ( thumbFilePath != nil && [thumbFilePath length] != 0){
                NSString *path = [[LibraryManager getInstance] addDataDirTo:thumbFilePath];
                //image = [[UIImage imageWithContentsOfFile:path] retain];
                UIImage *temp  = [UIImage imageWithContentsOfFile:path];
                image = [[UIImage alloc] initWithCGImage:temp.CGImage scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
            }
            else{
                //get an image from this library's contents
                if ( self.numberOfItems > 0){
                    NSMutableArray *assets = [[self enumerateAssets] retain];
                    Asset *asset = assets[0];
                    
                    //scale it
                    image = [[[asset image] imageCroppedAndScaledToSize:CGSizeMake(55, 55)
                                                            contentMode:UIViewContentModeScaleAspectFill
                                                               padToFit:NO]retain];
                    
                    [assets release];
                    
                    //save the image
                    NSString *userDir = [[LibraryManager getInstance] currentUserDir];
                    NSString *thumbName = [selfFilePath lastPathComponent];
                    thumbName = [thumbName stringByDeletingPathExtension]; //remove .plist
                    thumbName = [thumbName stringByAppendingPathExtension:@"JPG"];
                    thumbFilePath = [[FileUtils saveThumb:image inUserDir:userDir withName:thumbName]copy];
                    
                    //add the thumb to this library
                    NSMutableDictionary *library = [FileUtils newDictionaryFromFileInDataDir:selfFilePath];
                    library[keyAlbumThumbFilePath] = thumbFilePath;
                    [FileUtils saveDictionaryInDataDir:library];
                    [library release];
                }
                else{
                    //return empty album image
                    image = [[UIImage imageNamed:@"sunflower0"]retain];
                }
            }
		}
	}
	return image;
}


/*
-(UIImage *)resizeImage:(UIImage *)originalImage width:(CGFloat)resizedWidth height:(CGFloat)resizedHeight
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


@end
