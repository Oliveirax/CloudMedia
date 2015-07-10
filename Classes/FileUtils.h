//
//  FileManager.h
//  Xmedia
//
//  Created by Luis Oliveira on 7/12/11.
//

@class Asset;

@interface FileUtils : NSObject

+ (NSString *)getDocumentsDirectory;
+ (NSString *)getLibraryDirectory;
+ (NSString *)getDataDirectory;



// receives an absolute directory path
+ (BOOL)createDirectoryAtPath:(NSString *)path;
+ (BOOL)removeItemAtPath:(NSString *)path;


//receives a path relative to data
+ (BOOL)createDirectoryInDataDir:(NSString *)path;
+ (BOOL)removeItemInDataDir:(NSString *)path;


//returns USRXXXX
+ (NSString *)getNextUserDirectory;



//receives USRXXXX
//returns USRXXXX/ALBUMS/ALBXXXX.plist
+ (NSString *)getNextAlbumNameInUserDir:(NSString *)userDir;



+ (BOOL)saveALAsset:(Asset *)asset inUserDir:(NSString *)userDir
                    withTaskProgressDelegate:(id <TaskProgressDelegate>)taskProgressDelegate
                          andProgressPerByte:(CGFloat)progressPerByte;


// move a media file to MEDIA dir. creates its thumb and fsimage. returns an asset
// used when importing files from itunes
+ (Asset *)saveFileAsset:(NSString *)file inUserDir:(NSString *)userDir;




//load an asset in a user's dir. the name is the filename
//used by trashVC
+ (Asset *)loadAssetInUserDir:(NSString *)userDir withName:(NSString *)name;




//save a dictionary, its path should be relative to DATA
+ (BOOL)saveDictionaryInDataDir:(NSMutableDictionary *)dict;



//save a thumbnail in THUMBS dir. returns its path relative to DATA.
//Used for generated thumbs in AssetsGroup
+ (NSString *)saveThumb:(UIImage *)thumb inUserDir:(NSString *)userDir withName:(NSString *)name;



// save a capture of a video in FSCREEN dir. returns its path relative to DATA.
// used when importing files from itunes
+ (NSString *)saveFSImage:(UIImage *)thumb inUserDir:(NSString *)userDir withName:(NSString *)name;







//load a dictionary, its path should be relative to DATA, receiver should retain return value
+ (NSMutableDictionary *)newDictionaryFromFileInDataDir:(NSString *)path;



//exclude a url from icloud backup
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;


//zip and unzip
+ (BOOL)createZippedArchive:(NSString *)archivePath fromPath:(NSString *)sourcePath;
+ (BOOL)unzipArchive:(NSString *)archivePath intoPath:(NSString *)destinationPath;


//test media file type
+ (BOOL) isVideoFile:(NSString *)file;
+ (BOOL) isImageFile:(NSString *)file;


//used by trashViewController to load unreferenced assets
//+ (Asset *)loadAssetAtPath:(NSString *)path withName:(NSString *)name;


//+ (BOOL)saveDictionary:(NSMutableDictionary *)dict;




//+ (NSString *)getNextImgFileNameAtPath:(NSString *)path;                       //file name
//+ (NSString *)getNextVidFileNameAtPath:(NSString *)path;                       //file name
@end
