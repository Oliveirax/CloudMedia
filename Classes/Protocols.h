//
//  protocols.h
//  Xmedia
//
//  Created by Luis Filipe Oliveira on 1/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"

@class ThumbnailView;
@class AlbumContentsTableViewCell;
@class GenericModalViewController;
@class TapDetectingImageView;
@protocol ModalViewControllerDelegate;

// a protocol for a time-consuming assynchronous task
// delegate is informed of task progress and completion
@protocol TaskProgressDelegate <NSObject>
- (void)taskProgressed:(CGFloat)amount;
- (void)taskCompleted;
@end

// Since the alassetGroups enumeration is done in another thread, delegate must be 
// informed when it is complete, so that it can reload data.
@protocol AssetsLibraryGroupsEnumerationDelegate <NSObject>
- (void)groupsEnumerationDidFinish;
@end

// a protocol used by thumbnailImageView to inform a delegate that a thumb has been selected
@protocol ThumbnailImageViewSelectionDelegate <NSObject>
- (void)thumbnailImageViewWasSelected:(ThumbnailView *)thumbnailImageView;
@end

// a protocol used by AlbumContentsTableViewCell to inform a delegate which one of its thumbs has been selected
@protocol AlbumContentsTableViewCellSelectionDelegate <NSObject>
- (void)albumContentsTableViewCell:(AlbumContentsTableViewCell *)cell selectedPhotoAtIndex:(NSUInteger)index;
@end

// a protocol to be implemented by the modal view controllers
@protocol ModalViewController<NSObject>
@property(nonatomic, readonly)BOOL cancelled;
@property(nonatomic, assign)ModalViewControllerType type;
@property(nonatomic, assign)id<ModalViewControllerDelegate> modalDelegate;
@end

// a protocol used by a modal view controller to inform its delegate it has finished
@protocol ModalViewControllerDelegate <NSObject>
- (void)modalViewFinished:(id<ModalViewController>) controller;
@end

// Protocol for the tap-detecting views delegate.
@protocol TapDelegate <NSObject>
@optional
- (void)gotSingleTapAtPoint:(CGPoint)tapPoint;
- (void)gotDoubleTapAtPoint:(CGPoint)tapPoint;
- (void)gotTwoFingerTapAtPoint:(CGPoint)tapPoint;
- (void)gotSwipeLeft;
- (void)gotSwipeRight;
@end

//A cell with multiple items must implement this protocol
@protocol MultipleItemTableViewCell <NSObject>
@property(nonatomic, assign)NSUInteger row;
-(void)select:(BOOL)selected itemWithIndex:(NSUInteger)index;
@end

//protocol to receive tap events from a cell item, e.g. a checkmark or a thumb
@protocol CellItemTapDelegate <NSObject>
- (void)tappedItemWithIndex:(NSUInteger)index;
- (void)doubleTappedItemWithIndex:(NSUInteger)index;
- (void)longTappedItemWithIndex:(NSUInteger)index;
@end

// a protocol used by AlbumContentsTableViewCell to inform a delegate which one of its thumbs has been tapped
@protocol MultipleItemTableViewCellTapDelegate <NSObject>
- (void)multipleItemTableViewCell:(id<MultipleItemTableViewCell>)cell tappedItemWithIndex:(NSUInteger)index;
- (void)multipleItemTableViewCell:(id<MultipleItemTableViewCell>)cell doubleTappedItemWithIndex:(NSUInteger)index;
- (void)multipleItemTableViewCell:(id<MultipleItemTableViewCell>)cell longTappedItemWithIndex:(NSUInteger)index;
@end

// a protocol for AssetsLibrary and AssetsGroup
@protocol Group<NSObject>
@property(nonatomic,readonly) NSString *selfFilePath;
@property(nonatomic,readonly) NSString *thumbFilePath;
@property(nonatomic,readonly) NSString *name;
@property(nonatomic,assign ) BOOL selected;
@property(nonatomic,readonly)UIImage *posterImage;
@property(nonatomic,readonly)NSUInteger numberOfItems;
@end


