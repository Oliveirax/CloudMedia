//
//  AlbumsTableViewCell.m
//  Xmedia
//
//  Created by Luis Filipe Oliveira on 6/9/11.

// item index is:
// 0 = the cell
// 1 = the checkmark
//

#import "AlbumsTableViewCell.h"
#import "AssetsGroup.h"
#import "CheckMarkView.h"
#import "TapView.h"


NSString *const AlbumsTableViewCellIdentifier = @"AlbumsTableViewCellIdentifier";
NSUInteger const AlbumsTableViewCellCheckMark = 1;
NSUInteger const AlbumsTableViewCellImage = 2;
NSUInteger const AlbumsTableViewCellTitle = 3;



#pragma mark - private interface

@interface AlbumsTableViewCell()

@property(nonatomic, retain)CheckMarkView* checkMark;
@property(nonatomic, retain)TapView* imageTapView;
//@property(nonatomic, retain)TapView* titleTapView;

@end



@implementation AlbumsTableViewCell


@synthesize row = _row; //property from multipleItemTableViewCell
@synthesize tapDelegate = _delegate;
//@synthesize checked =_checked;
@synthesize checkMark = _checkMark;
@synthesize imageTapView = _imageTapView;
//@synthesize titleTapView = _titleTapView;



#pragma mark - init & dealloc

- (id)init
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:AlbumsTableViewCellIdentifier];
    if (self) {
        
        _checkMark = [[CheckMarkView alloc ]initWithIndex:AlbumsTableViewCellCheckMark];
        [_checkMark setCenter:CGPointMake(-20,30)];
        _checkMark.alpha = 0.0;
        _checkMark.tapDelegate = self;
        [self addSubview:_checkMark];
        
        _imageTapView = [[TapView alloc]initWithFrame:CGRectMake(40,1,55,55) andIndex:AlbumsTableViewCellImage];
        //_imageTapView.alpha = 0.0;
        _imageTapView.hidden = YES;
        _imageTapView.tapDelegate = self;
        [self addSubview:_imageTapView];
//
//        _titleTapView = [[TapView alloc]initWithFrame:CGRectMake(95,8, 300, 26) andIndex:AlbumsTableViewCellTitle];
//        _titleTapView.alpha = 0.0;
//        _titleTapView.tapDelegate = self;
//        [self addSubview:_titleTapView];

                
        //long press gesture recognizing overrides the reorder control, 
		//ie, holding the reorder control is intercepted by gesture recognizers.
		//do not implement gesture recgs in this view, only in subViews

    }
    return self;
}


- (void)dealloc{
	self.checkMark = nil;
	self.imageTapView = nil;
    [super dealloc];
}



#pragma mark - Set contents

- (void)setPosterImage:(UIImage *)image{
    self.imageView.image = image;
}



- (void)setTitle:(NSString *)text{
    self.textLabel.text = text; 
}



// choose one of these, either albums or items

- (void)setNumberOfItems:(NSUInteger)items{
    if(items == 0)
		self.detailTextLabel.text = @"No Items";
	else if (items == 1)
		self.detailTextLabel.text = @"1 Item";
	else
		self.detailTextLabel.text = [NSString stringWithFormat:@"%d Items",items];

}



// choose one of these, either albums or items

- (void)setNumberOfAlbums:(NSUInteger)albums{
    if(albums == 0)
		self.detailTextLabel.text = @"No Albums";
	else if (albums == 1)
		self.detailTextLabel.text = @"1 Album";
	else
		self.detailTextLabel.text = [NSString stringWithFormat:@"%d Albums",albums];
    
}




#pragma mark - Editing and Checking


//- (void)setChecked:(BOOL)checked
//{
//    _checked = checked;
//    [_checkMark setSelected:checked];
//}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
//    if (self.editing){
//        NSLog(@"cell is in edit mode");
//    }
//    else{
//        NSLog(@"cell is NOT in edit mode");
//    }

    
    if( editing){
        
         _imageTapView.hidden = NO;
        // _titleTapView.hidden = NO;
        
        [UIView animateWithDuration:0.3 
                         animations: ^{ 
                             _checkMark.alpha = 1.0;
                             _checkMark.center = CGPointMake(20,30);
                         }
                         completion:nil];
    }
    else{
        
        _imageTapView.hidden = YES;
        // _titleTapView.hidden = YES;
        
        [UIView animateWithDuration:0.3 
                         animations: ^{ 
                             _checkMark.alpha = 0.0;
                             _checkMark.center = CGPointMake(-20,30);
                         } 
                         completion:nil];
    }
}


#pragma mark - Cell Items tap Delegate

- (void)tappedItemWithIndex:(NSUInteger)index{
    [_delegate multipleItemTableViewCell:self tappedItemWithIndex:index];
}


- (void)doubleTappedItemWithIndex:(NSUInteger)index
{
   [_delegate multipleItemTableViewCell:self doubleTappedItemWithIndex:index];
}


- (void)longTappedItemWithIndex:(NSUInteger)index{
    [_delegate multipleItemTableViewCell:self longTappedItemWithIndex:index];
}



#pragma mark - Multiple Item table view Cell implementation

-(void)select:(BOOL)selected itemWithIndex:(NSUInteger)index{
    // for now, just the checkmark can be selected, so the index is ignored
    //NSLog(@"Selecting: %d row: %d", selected, _row);
	[_checkMark setSelected:selected];
}

@end
