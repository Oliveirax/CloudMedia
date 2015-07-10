//
//  Constants.h
//  Xmedia
//
//  Created by Luis Oliveira on 11/8/11.
//

//modal View controller types
typedef enum{
	ModalViewControllerTypeUserSettings,
	ModalViewControllerTypeLogin,
	ModalViewControllerTypeNewUser,
    ModalViewControllerTypeNewAlbum,
    ModalViewControllerTypeItemProperties,
    
	ModalViewControllerTypeImportFromDevice, // import from photos app (copy)
	ModalViewcontrollerTypeExportToDevice, // export to photos app (copy) - not implemented
	ModalViewControllerTypeImportFromItunes, // import from itunes (move)
    ModalViewControllerTypeExportToItunes, // export to itunes (copy) - not implemented
    ModalViewControllerTypeImportFromLibrary, // import from current lib (link)
	ModalViewControllerTypeExportToLibrary,  // export to current lib (link)
    ModalViewControllerTypeImportFromLibraryMove, // import from current lib (link) and delete original link
    ModalViewControllerTypeExportToLibraryMove, // export to current lib (link) and delete original link
	
} ModalViewControllerType;


//media file types (file extensions)
extern NSUInteger const kImageTypesSize;
extern NSString *const kImageTypes[];
extern NSUInteger const kVideoTypesSize;
extern NSString *const kVideoTypes[];


// constants
extern NSString *const kGuestUsername; //default username
extern NSString *const kRootAlbumName; //the name for the root album
extern NSString *const kNewAlbumName; //new album
extern NSString *const kContentTypeAlbums; //album containig albums
extern NSString *const kContentTypeAssets; //album containinga assets
extern NSString *const kAssetTypeVideo; //video asset
extern NSString *const kAssetTypeImage; //image asset
extern NSString *const kTransitionRandom;


//Directories and files
extern NSString *const kAlbumFilePrefix;
extern NSString *const kUserDirectoryPrefix;
extern NSString *const kVideoFilePrefix;
extern NSString *const kImageFilePrefix;
extern NSString *const kDataDirectoryName;
extern NSString *const kMediaDirectoryName;
extern NSString *const kThumbsDirectoryName;
extern NSString *const kVidcapsDirectoryName;
extern NSString *const kFullScreenDirectoryName;
extern NSString *const kAlbumsDirectoryName;
extern NSString *const kUsersFileName; //users.plist
extern NSString *const kLibraryFileName; //library.plist

extern NSString *const keySelfFilePath; // the path to himself, present in all plists

//USERS - users.plist
extern NSString *const keyUsersUsername;
extern NSString *const keyUsersPassword;
extern NSString *const keyUsersUserDirectoryPath;
extern NSString *const keyUsersUserLibraryFilePath;

//LIBRARY - library.plist
extern NSString *const keyLibraryUsername;
extern NSString *const keyLibraryPassword;
extern NSString *const keyLibraryRootAlbumPath;
extern NSString *const keyLibraryAlbumsDirectoryPath;
extern NSString *const keyLibraryVidcapsDirectoryPath;
extern NSString *const keyLibraryFullScreenDirectoryPath;
extern NSString *const keyLibraryMediaDirectoryPath;
extern NSString *const keyLibraryThumbsDirectoryPath;
extern NSString *const keyLibraryAssetReferenceDict;//how many references every media file has (asset-nrefs)

//this fits better in a file like keywords.plist
extern NSString *const keyLibraryKeywordAlbumDict;//keywords referenced in albums (keyword-array of albumsPaths)

//ALBUM - ALB0000.plist
//albums
extern NSString *const keyAlbumName;
extern NSString *const keyAlbumThumbFilePath;
extern NSString *const keyAlbumContentType; //contains albums or assets
extern NSString *const keyAlbumItemsArray;
extern NSString *const keyAlbumKeywordsArray; 
extern NSString *const keyAlbumItemsIndexDict; //albumName-index, (for searching). Empty for assets album?
extern NSString *const keyAlbumSlideDuration;
extern NSString *const keyAlbumSlideTransition;
extern NSString *const keyAlbumTransitionDuration;
extern NSString *const keyAlbumRepeat;
extern NSString *const keyAlbumShuffle;

//all album items

//album item = album
//extern NSString *const keyAlbumItemAlbumFilePath;
//extern NSString *const keyAlbumItemAlbumName;
//extern NSString *const keyAlbumItemAlbumThumbFilePath;
//extern NSString *const keyAlbumItemAlbumNumberOfItems;

//Asset
extern NSString *const keyAssetMediaFilePath;
extern NSString *const keyAssetSize;
extern NSString *const keyAssetDuration;
extern NSString *const keyAssetThumbFilePath;
extern NSString *const keyAssetVidcapFilePath;
extern NSString *const keyAssetFullScreenFilePath;
extern NSString *const keyAssetType;

extern NSString *const keyAssetSlideDuration;
extern NSString *const keyAssetTransition;
extern NSString *const keyAssetTransitionDuration;
