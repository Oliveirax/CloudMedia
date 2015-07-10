//
//  Constants.m
//  Xmedia
//
//  Created by Luis Oliveira on 11/8/11.
//

#import "Constants.h"

//media file types (file extensions)
NSUInteger const kImageTypesSize = 4;
NSString *const kImageTypes[] = {@"PNG",@"JPG",@"JPEG",@"BMP"};
NSUInteger const kVideoTypesSize = 5;
NSString *const kVideoTypes[] = {@"M4V",@"MOV",@"MP4",@"MPG",@"MPEG"};


// constants
NSString *const kGuestUsername = @"Guest";
NSString *const kRootAlbumName = @"Home";
NSString *const kNewAlbumName = @"New Album";
NSString *const kContentTypeAlbums = @"Albums";
NSString *const kContentTypeAssets = @"Assets";
NSString *const kAssetTypeVideo = @"Video";
NSString *const kAssetTypeImage = @"Image";
NSString *const kTransitionRandom = @"Random";

//Directories and files
NSString *const kAlbumFilePrefix = @"ALB";
NSString *const kUserDirectoryPrefix = @"USR";
NSString *const kVideoFilePrefix = @"VID";
NSString *const kImageFilePrefix = @"IMG";
NSString *const kDataDirectoryName = @"DATA";
NSString *const kMediaDirectoryName = @"MEDIA";
NSString *const kThumbsDirectoryName = @"THUMBS";
NSString *const kVidcapsDirectoryName = @"VIDCAPS";
NSString *const kFullScreenDirectoryName = @"FSCREEN";
NSString *const kAlbumsDirectoryName = @"ALBUMS";
NSString *const kUsersFileName = @"Users.plist";
NSString *const kLibraryFileName = @"Library.plist";

NSString *const keySelfFilePath = @"SelfPath"; 

//USERS - users.plist
NSString *const keyUsersUsername = @"Username";
NSString *const keyUsersPassword = @"Password";
NSString *const keyUsersUserDirectoryPath = @"UserDir";
NSString *const keyUsersUserLibraryFilePath = @"Library";


//LIBRARY - library.plist
NSString *const keyLibraryUsername = @"Username";
NSString *const keyLibraryPassword = @"Password";
NSString *const keyLibraryRootAlbumPath = @"RootAlbum";
NSString *const keyLibraryAlbumsDirectoryPath = @"AlbumsDir";
NSString *const keyLibraryVidcapsDirectoryPath = @"VidcapsDir";
NSString *const keyLibraryFullScreenDirectoryPath = @"FullScreenDir";
NSString *const keyLibraryMediaDirectoryPath = @"MediaDir";
NSString *const keyLibraryThumbsDirectoryPath = @"ThumbsDir";
NSString *const keyLibraryAssetReferenceDict = @"AssetsRef";
NSString *const keyLibraryKeywordAlbumDict = @"Keywords";

//ALBUM - ALB0000.plist
NSString *const keyAlbumName = @"Name"; 
NSString *const keyAlbumThumbFilePath = @"Thumb";
NSString *const keyAlbumContentType = @"ContentType"; 
NSString *const keyAlbumItemsArray = @"Items";
NSString *const keyAlbumKeywordsArray = @"Keywords"; 
NSString *const keyAlbumItemsIndexDict = @"Index";
NSString *const keyAlbumSlideDuration = @"SlideDuration";
NSString *const keyAlbumSlideTransition = @"SlideTransition";
NSString *const keyAlbumTransitionDuration = @"TransitionDuration";
NSString *const keyAlbumRepeat = @"Repeat";
NSString *const keyAlbumShuffle = @"Shuffle";

//album item = asset
NSString *const keyAssetMediaFilePath = @"File";
NSString *const keyAssetSize = @"Size";
NSString *const keyAssetDuration = @"Duration";
NSString *const keyAssetThumbFilePath = @"Thumb";
NSString *const keyAssetVidcapFilePath = @"VidCap";
NSString *const keyAssetFullScreenFilePath = @"FullScreen";
NSString *const keyAssetType = @"Type";

NSString *const keyAlbumItemSlideDuration = @"SlideDuration";
NSString *const keyAlbumItemTransition = @"Transition";
NSString *const keyAlbumItemTransitionDuration = @"TransitionDuration";
