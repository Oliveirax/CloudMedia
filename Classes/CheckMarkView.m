//
//  CheckMarkImageView.m
//  Xmedia
//
//  Created by Luis Filipe Oliveira on 8/4/11.
//

#import "CheckMarkView.h"

@interface CheckMarkView()

@property (nonatomic, retain)UIImageView *checkedImageView; 
@property (nonatomic, retain)UIImageView *uncheckedImageView;
@property (nonatomic, retain)UIImageView *highlightedImageView; 

@end


@implementation CheckMarkView


@synthesize selected = _selected;
@synthesize checkedImageView = _checkedImageView;
@synthesize uncheckedImageView = _uncheckedImageView;
@synthesize highlightedImageView = _highlightedImageView;



#pragma mark - init and dealloc

- (id)initWithIndex:(NSUInteger)index{
    self = [super initWithFrame:CGRectMake(0,0,44,44) andIndex:index];
    if (self) {
        
        // touch area test
//        UIView *background = [[UIView alloc ]initWithFrame:CGRectMake(0, 0, 44,44)];
//        background.backgroundColor = [UIColor yellowColor];
//        [self addSubview:background];
        
        // the checked/unchecked/highlighted imageViews
        UIImage *image;
		
        image = [UIImage imageNamed:@"TickChecked"];
        _checkedImageView = [[UIImageView alloc ]initWithImage:image];
        _checkedImageView.alpha = 0.0;
        _checkedImageView.center = CGPointMake(22,22);
        [self addSubview:_checkedImageView];
        
        image = [UIImage imageNamed:@"TickNotChecked"];
        _uncheckedImageView = [[UIImageView alloc ]initWithImage:image];
        _uncheckedImageView.alpha = 1.0;
        _uncheckedImageView.center = CGPointMake(22,22);
        [self addSubview:_uncheckedImageView];
        
        image = [UIImage imageNamed:@"TickPressed"];
        _highlightedImageView = [[UIImageView alloc ]initWithImage:image];
        _highlightedImageView.alpha = 0.0;
        _highlightedImageView.center = CGPointMake(22,22);
        [self addSubview:_highlightedImageView];
        
        _selected = NO;
        
    }
    return self;
}



- (void)dealloc {
	self.uncheckedImageView = nil;
	self.checkedImageView = nil;
    self.highlightedImageView = nil;
    [super dealloc];
}




#pragma mark - selection and highlighting

- (void)setSelected:(BOOL)selected{
    
    if (_selected == selected) return;
    
     NSLog(@"Checkmark selected!");
    _selected = selected;
    
    if( selected){
        
        [UIView animateWithDuration:0.3 
                         animations: ^{ 
                             _checkedImageView.alpha = 1.0;
                             _uncheckedImageView.alpha = 0.0;
                         } 
                         completion:nil];
    }
    else{
        
        [UIView animateWithDuration:0.3 
                         animations: ^{ 
                             _checkedImageView.alpha = 0.0;
                             _uncheckedImageView.alpha = 1.0;
                         } 
                         completion:nil];
    }
}


//empty implementation to override tapview's 0.5 alpha highlight
-(void)setHighlighted:(BOOL)highlighted{
    
}

@end


