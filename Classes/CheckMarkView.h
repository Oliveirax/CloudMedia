//
//  CheckMarkImageView.h
//  Xmedia
//
//  Created by Luis Filipe Oliveira on 8/4/11.
//

#import "TapView.h"

@interface CheckMarkView : TapView 

@property (nonatomic, assign) BOOL selected;


- (id)initWithIndex:(NSUInteger)index;

@end
