//
//  ClipboardManager.h
//  Xmedia
//
//  Created by Luis Oliveira on 7/13/11.
//

@class AssetsLibrary;
@class AssetsGroup;
@class Asset;

@interface ClipboardManager : NSObject 
{
	NSMutableArray *clipboard;
	long long bytesInClipboard;
	NSUInteger itemsInClipboard;
	CGFloat progressPerByte;
	//NSUInteger operationMode;
	NSUInteger contentType;
    
    id <TaskProgressDelegate> taskProgressDelegate;
}

@property(nonatomic, assign)id <TaskProgressDelegate> taskProgressDelegate;

+ (ClipboardManager *)getInstance;

// set clipboard mode

- (void)setModeToGroups;
//- (void)setModeToGroupsLink;
//- (void)setModeToGroupsMove;
- (void)setModeToAssets;
//- (void)setModeToAssetsLink;
//- (void)setModeToAssetsMove;
- (void)setModeToFiles;
//- (void)setModeToFilesCopy;


//add items to clipboard
- (void)addAssetsLibrary:(AssetsLibrary *)library;
- (void)addAssetsGroup:(AssetsGroup *)group;
- (void)addAsset:(Asset *)asset;
- (void)addFile:(NSString *)file;

//paste items

// for these methods, whe know where we are pasting, but not WHAT we are pasting....

// if we are pasting a bunch of albums, it's straightforward. if pasting assets, create a new unnamed dir and paste the assets in it
- (void)pasteInAssetsLibrary:(AssetsLibrary *)library; 

// if we are pasting a bunch of assets, it's straightforward. if pasting albums....
// a) group existing assets in a new folder. Then paste the new albums on the side of them 
// b) expand the clipboard abums into a set of assets
- (void)pasteInAssetsGroup:(AssetsGroup *)group;

- (void)resetClipboard;

@end
