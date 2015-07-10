//
//  PlayButtonImageView.m
//  Xmedia
//
//  Created by Luis Filipe Oliveira on 3/21/11.
//

#import "PlayButtonImageView.h"

@interface PlayButtonImageView()

- (void)callDelegate;

@end



@implementation PlayButtonImageView

@synthesize delegate;

#pragma mark -
#pragma mark init and dealloc

- (id)init {
    self = [super initWithImage:[UIImage imageNamed:@"PlayOverlay"]];
    if (self) {
        [self setUserInteractionEnabled:YES];
		
		normalImage = [self.image retain];
		highlightImage = [[UIImage imageNamed:@"PlayOverlayHighlight"]retain];
    }
    return self;
}


- (void)dealloc {
	[normalImage release];
	[highlightImage release];
    [super dealloc];
}


#pragma mark -
#pragma mark Touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.image = highlightImage;
	NSLog(@"TOCA");
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self performSelector:@selector(callDelegate) withObject:nil afterDelay:0.1];
}



- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.image = normalImage;
}

#pragma mark -
#pragma mark helper methods

- (void)callDelegate{
	self.image = normalImage;
	
	// call the delegate, using our tag as argument, so that the delegate recognizes this view
	if ([delegate respondsToSelector:@selector(gotSingleTapAtPoint:)])
		[delegate gotSingleTapAtPoint:CGPointMake(self.tag, self.tag)];	
}

@end
