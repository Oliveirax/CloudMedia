//
//  AssetsLibrary.m
//  Xmedia
//
//  Created by Luis Filipe Oliveira on 11/23/10.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "AssetsLibrary.h"
#import "AssetsGroup.h"
#import "LibraryManager.h"
#import "FileUtils.h"

//@interface AssetsLibrary()
//- (UIImage*) maskImage:(UIImage *)theImage withMask:(UIImage *)maskImage;
//CGImageRef CopyImageAndAddAlphaChannel(CGImageRef sourceImage);
//@end

@implementation AssetsLibrary

@synthesize name;
@synthesize isALAsset;
@synthesize selfFilePath;
@synthesize thumbFilePath;
@synthesize groupsEnumerationDelegate;
@synthesize selected;
@synthesize posterImage;
@synthesize numberOfItems;



#pragma mark - Init and dealloc


- (id)initWithPath:(NSString *)path
{
    NSMutableDictionary *library = [FileUtils newDictionaryFromFileInDataDir:path];
    AssetsLibrary *al = [self initWithDictionary:library];
    [library release];
    return al;
}



// the distionary is not retained because it can be really big
- (id)initWithDictionary:(NSMutableDictionary *)dict
{
    if ((self = [super init])){
        selfFilePath = [[dict objectForKey:keySelfFilePath]copy];
        thumbFilePath = [[dict objectForKey:keyAlbumThumbFilePath]copy];
        name = [[dict objectForKey:keyAlbumName]copy];
        numberOfGroups = [[dict objectForKey:keyAlbumItemsArray]count];
        
        image = nil;
		isALAsset = NO;
        selected = NO;
        deviceLibrary = nil;
    }
    return self;
}





- (id)init{
	if ((self = [super init])){
		selfFilePath = nil;
        thumbFilePath = nil;
		name = @"Device Library";
        numberOfGroups = 0;
        
		image = nil;
		isALAsset = YES;
        selected = NO;
        deviceLibrary = [[ALAssetsLibrary alloc] init];
	}
	return self;
}


- (void)dealloc {
	NSLog(@"AssetsLibrary release");
	
    if (selfFilePath) [selfFilePath release];
    if (thumbFilePath) [thumbFilePath release];
	if (name)[name release];
	if (image) [image release];
    if (deviceLibrary) [deviceLibrary release];
    [super dealloc];
}



- (NSUInteger)numberOfItems{
    return numberOfGroups;
}




- (NSMutableArray *)enumerateGroups{
	
	NSLog(@"AssetsLibrary::enumerateGroups");
	NSMutableArray *groups;
	

	if(isALAsset){
		
        groups = [[NSMutableArray alloc]init];
        
		// get assets library
		//ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
		//assetsLibrary = [[ALAssetsLibrary alloc] init];
	
		//enumerate assets from device library
        ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
			
			if (group) {
				NSLog(@"processing device group: %@",[group valueForProperty:ALAssetsGroupPropertyName]);
				AssetsGroup *newGroup = [[AssetsGroup alloc]initWithGroup:group];
				[groups addObject:newGroup];
				[newGroup release];
			}
			else {
				NSLog(@"processing device group: NULL - reloading tableview");
				[groupsEnumerationDelegate groupsEnumerationDidFinish];
			}

		};
		
		ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
			
			//AssetsDataIsInaccessibleViewController *assetsDataInaccessibleViewController = [[AssetsDataIsInaccessibleViewController alloc] initWithNibName:@"AssetsDataIsInaccessibleViewController" bundle:nil];
			
			NSString *errorMessage = nil;
			switch ([error code]) {
				case ALAssetsLibraryAccessUserDeniedError:
				case ALAssetsLibraryAccessGloballyDeniedError:
					errorMessage = @"The user has declined access to it.";
					break;
				default:
					errorMessage = @"Reason unknown.";
					break;
			}
			NSLog(@"Library access failure! %@", errorMessage);
			/*
			 assetsDataInaccessibleViewController.explanation = errorMessage;
			 [self presentModalViewController:assetsDataInaccessibleViewController animated:NO];
			 [assetsDataInaccessibleViewController release];
			 */
			
		};
		
		
		NSLog(@"enumerate groups from device");
		NSUInteger groupTypes = ALAssetsGroupAll;
		[deviceLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
		//[assetsLibrary release];
	}
	else {//not an ALAsset
        
        NSLog(@"enumerate groups from library %@",selfFilePath);
        NSMutableDictionary *library = [FileUtils newDictionaryFromFileInDataDir:selfFilePath];
        groups = [[NSMutableArray alloc]init];
        NSMutableArray *items = [library objectForKey:keyAlbumItemsArray];
        
        for(NSString *itemPath in items){
            
            NSMutableDictionary *itemDict = [FileUtils newDictionaryFromFileInDataDir:itemPath];
            
            // item is a AssetsLibrary
            if ([[itemDict objectForKey:keyAlbumContentType]isEqualToString:kContentTypeAlbums]){
                AssetsLibrary *lib = [[AssetsLibrary alloc ]initWithDictionary:itemDict];
                [groups addObject:lib];
                [lib release];
            }
            else{ // item is an AssetsGroup
                AssetsGroup *ag = [[AssetsGroup alloc] initWithDictionary:itemDict];
                [groups addObject:ag];
                [ag release];
            }
            [itemDict release];
        }
        [library release];
    }
	return [groups autorelease];
}



- (UIImage *)posterImage{ 

	if (image == nil) {
				
		if (isALAsset){
            // not really a possibility.... there is only one ALAssetsLibrary, and it is never seen as a thumbnailed item, only its contents.
			image = [[UIImage imageNamed:@"sunflower0"]retain];
		}
		else {
            
            //we already have a poster image? load it!
            if ( thumbFilePath != nil && [thumbFilePath length] != 0){
                NSString *path = [[LibraryManager getInstance] addDataDirTo:thumbFilePath];
                image = [[UIImage imageWithContentsOfFile:path] retain];
            }
            else{
                //get an image from this library's contents
                if ( self.numberOfItems > 0){
                    NSMutableArray *groups = [[self enumerateGroups] retain];
                    NSObject<Group> *group = [groups objectAtIndex:0];
                    image = [[group posterImage] retain];
                    [groups release];
                    
                    //save the image
                    NSString *userDir = [[LibraryManager getInstance] currentUserDir];
                    NSString *thumbName = [selfFilePath lastPathComponent];
                    thumbName = [thumbName substringToIndex:[thumbName length]-6];
                    thumbName = [thumbName stringByAppendingPathExtension:@"JPG"];
                    thumbFilePath = [[FileUtils saveThumb:image inUserDir:userDir withName:thumbName]copy];
                    
                    //add the thumb to this library
                    NSMutableDictionary *library = [FileUtils newDictionaryFromFileInDataDir:selfFilePath];
                    [library setObject:thumbFilePath forKey:keyAlbumThumbFilePath];
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


@end
