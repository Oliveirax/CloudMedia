 //
//  Asset.m
//  Xmedia
//
//  Created by Luis Filipe Oliveira on 11/23/10.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "Asset.h"
#import "LibraryManager.h"



@implementation Asset

@synthesize properties = _properties;
@synthesize isALAsset = _isALAsset;
@synthesize selected = _selected;
@synthesize theALAsset = _theALAsset;
@synthesize thumbnail = _thumbnail;




#pragma mark -
#pragma mark Init and dealloc



//take an asset nsdict as input
- (id)initWithDictionary:(NSMutableDictionary *)dict
{
    if ((self = [super init])){
        _properties = [dict retain];
		_thumbnail = nil;
        _theALAsset = nil;
		_isALAsset = NO;
		_selected = NO;
        
    }
	return self;
    
}



- (id)initWithAsset:(ALAsset *)asset
{
	if ((self = [super init])){
		_theALAsset = [asset retain];
        _properties = [[NSMutableDictionary alloc ]init ];
        _thumbnail = nil;
		_isALAsset = YES;
		_selected = NO;
        
        //save size
        long long size = [[_theALAsset defaultRepresentation]size];
        [_properties setValue:@(size) forKey:keyAssetSize];
        
        //save type and duration
        NSString *type = [_theALAsset valueForProperty:ALAssetPropertyType];
        if ([type isEqualToString:ALAssetTypePhoto]){
            [_properties setValue:kAssetTypeImage forKey:keyAssetType];
            [_properties setValue:@-1.0 forKey:keyAssetDuration];
        }
        else if ([type isEqualToString:ALAssetTypeVideo]){
            [_properties setValue:kAssetTypeVideo forKey:keyAssetType];
            [_properties setValue:[_theALAsset valueForProperty:ALAssetPropertyDuration] forKey:keyAssetDuration];

        }
        else{
            //unknown type
            [_properties setValue:type forKey:keyAssetType];
        }
    }
	return self;	
}



- (void)dealloc 
{
	if (_thumbnail) [_thumbnail release];
	if (_theALAsset) [_theALAsset release];
    [_properties release];
    [super dealloc];
}



#pragma mark -
#pragma mark Accessor methods

- (UIImage *)thumbnail
{    
	if (_thumbnail == nil){
		
		if(_isALAsset){
			CGImageRef thumbnailImageRef = [_theALAsset thumbnail];
			_thumbnail = [[UIImage imageWithCGImage:thumbnailImageRef]retain];
			
		}
		else{
            NSString *path = [[LibraryManager getInstance] addDataDirTo:_properties[keyAssetThumbFilePath]];
            UIImage *temp  = [UIImage imageWithContentsOfFile:path];
            _thumbnail = [[UIImage alloc] initWithCGImage:temp.CGImage scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
           // thumbnailImage = [[UIImage imageWithContentsOfFile:path]retain];
		}
    }
	return _thumbnail;
}



- (UIImage *)image
{		
	//if (fsImage == nil){
    UIImage *fsImage1 = nil;
    
        if(_isALAsset){
            ALAssetRepresentation *assetRepresentation = [_theALAsset defaultRepresentation];
            fsImage1 = [UIImage imageWithCGImage:[assetRepresentation fullResolutionImage] 
                                           scale:[assetRepresentation scale] 
                                     orientation:(UIImageOrientation)[assetRepresentation orientation]];
        }
        else{
            if ([[self type] isEqualToString:kAssetTypeImage]){
                NSString *path = [[LibraryManager getInstance] addDataDirTo:_properties[keyAssetMediaFilePath]];
                NSLog(@"Asset retrieving image: %@",_properties[keyAssetMediaFilePath]);
                fsImage1 = [UIImage imageWithContentsOfFile:path];
            }
            else if ([[self type]isEqualToString:kAssetTypeVideo]){
                NSString *path = [[LibraryManager getInstance] addDataDirTo:_properties[keyAssetFullScreenFilePath]];
                NSLog(@"Asset retrieving vidcap: %@",_properties[keyAssetFullScreenFilePath]);
                fsImage1 = [UIImage imageWithContentsOfFile:path];
            }
            else{
                NSLog(@"Asset type Unknown!!! - returning Error Image!");
                fsImage1 = [UIImage imageNamed:@"empty"];
            }
        }
    
    //[fsImage retain]; //memory will expire shortly
    //}
	return fsImage1;
}



- (NSString *)mediaFilePath
{
    return _properties[keyAssetMediaFilePath];
}



- (void)setMediaFilePath:(NSString *)mediaFilePath
{
    _properties[keyAssetMediaFilePath] = mediaFilePath;
}



- (NSString *)fullScreenFilePath
{
    return _properties[keyAssetFullScreenFilePath];
}



- (void)setFullScreenFilePath:(NSString *)fullScreenFilePath
{
    _properties[keyAssetFullScreenFilePath] = fullScreenFilePath;
}


- (NSString *)vidCapFilePath
{
    return _properties[keyAssetVidcapFilePath];
}



- (void)setVidCapFilePath:(NSString *)vidCapFilePath
{
    _properties[keyAssetVidcapFilePath] = vidCapFilePath;
}



- (NSString *)thumbFilePath
{
    return _properties[keyAssetThumbFilePath];
}



- (void)setThumbFilePath:(NSString *)thumbFilePath
{
    _properties[keyAssetThumbFilePath] = thumbFilePath;
}



- (NSString *)type
{
    return _properties[keyAssetType];
}



- (long long)size
{
    return [_properties[keyAssetSize]longLongValue];
}



- (NSURL *)url
{
	NSURL *url = nil;
	if (_isALAsset){
		ALAssetRepresentation *assetRepresentation = [_theALAsset defaultRepresentation];
		url = [assetRepresentation url];
	}
	else {
        NSString *path = [[LibraryManager getInstance] addDataDirTo:_properties[keyAssetMediaFilePath]];
        url = [NSURL fileURLWithPath:path isDirectory:NO];
	}

	return url;
}

- (CGFloat)duration
{
    if ( _properties[keyAssetDuration]){
        return [_properties[keyAssetDuration]floatValue];
    }
    return -1;
}

@end
