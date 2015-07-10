//
//  TDOverlay.h
//  Xmedia
//
//  Created by Luis Filipe Oliveira on 1/25/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GestureRecognizerOverlayView : UIView
{

    id <TapDelegate> delegate;
}

@property (nonatomic, assign) id <TapDelegate> delegate;

@end
