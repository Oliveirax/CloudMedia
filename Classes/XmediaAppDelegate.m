//
//  XmediaAppDelegate.m
//  Xmedia
//
//  Created by Luis Filipe Oliveira on 11/4/10.
//

#import "XmediaAppDelegate.h"
#import "AssetsLibrary.h"
#import "LibraryManager.h"
#import "AlbumsVC.h"

@implementation XmediaAppDelegate

@synthesize window;
@synthesize navigationController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    //******* testing
    //[[UsersManager getInstance]createUserWithName:@"Luis" withPassword:@"borundi"];
    //[[UsersManager getInstance]loadUserWithName:@"Luis" withPassword:@"borundi"];
     //**** end testing
    
    // root view controller
    LibraryManager *lm = [LibraryManager getInstance];
    NSMutableDictionary *library  = [lm currentLibrary];
    AssetsLibrary *al = [[AssetsLibrary alloc]initWithPath:library[keyLibraryRootAlbumPath]];
    //AlbumsViewController *avc = [[AlbumsViewController alloc]initWithLibrary:al];
    AlbumsVC *avc = [[AlbumsVC alloc]initWithLibrary:al];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:avc];
    [avc release],
    [al release];
    
	//navigation bar properties
	nc.navigationBarHidden = NO;
	nc.navigationBar.barStyle = UIBarStyleBlackTranslucent; //blackTranslucent provides black buttons
	//nc.navigationBar.translucent = NO;
	//nc.navigationBar.tintColor =  [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
	
	//toolbar properties
	nc.toolbarHidden = NO;
	nc.toolbar.barStyle = UIBarStyleBlackTranslucent;
	//nc.toolbar.translucent = YES;
	//nc.toolbar.tintColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
	
	self.navigationController = nc;
	[nc release];
	
	// build the window
	UIWindow *w = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window = w;
	[w release];
	
	//add rootview window
	//[window addSubview:navigationController.view];
    [self.window setRootViewController:navigationController];
	
	//make window visible
    [window makeKeyAndVisible];
	
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[navigationController release];
    [window release];
    [super dealloc];
}


@end
