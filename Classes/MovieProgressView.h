//
//  MovieProgressView.h
//  xmedia
//
//  Created by Luis Filipe Oliveira on 6/19/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MPMoviePlayerController;

@interface MovieProgressView : UIView


@property (nonatomic, assign, readonly) CGFloat duration;
@property (nonatomic, assign, readonly) CGFloat progress;
@property (nonatomic,assign) UIInterfaceOrientation orientation;
@property (nonatomic, assign) MPMoviePlayerController *moviePlayer;



@end