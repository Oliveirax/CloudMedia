//
//  XmediaAppDelegate.h
//  Xmedia
//
//  Created by Luis Filipe Oliveira on 11/4/10.
//



@class AssetAlbumsViewController;
@class AlbumsViewController;

@interface XmediaAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UINavigationController *navigationController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;

@end

