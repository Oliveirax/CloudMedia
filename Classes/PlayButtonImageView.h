//
//  PlayButtonImageView.h
//  Xmedia
//
//  Created by Luis Filipe Oliveira on 3/21/11.
//

@interface PlayButtonImageView : UIImageView {
	
    id <TapDelegate> delegate;
	UIImage *normalImage;
	UIImage *highlightImage;
}

@property (nonatomic, assign) id <TapDelegate> delegate;

@end
