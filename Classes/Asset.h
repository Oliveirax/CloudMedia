//
//  Asset.h
//  Xmedia
//
// An Assets (photo or video)
//
//  Created by Luis Filipe Oliveira on 11/23/10.
//


@class ALAsset;


@interface Asset : NSObject 


@property(nonatomic, assign) BOOL selected;
@property (nonatomic,assign)BOOL isALAsset;
@property (nonatomic, readonly)NSMutableDictionary* properties;
@property (nonatomic,readonly)UIImage *thumbnail;
@property (nonatomic,readonly)NSString *type;
@property (nonatomic,readonly)UIImage *image;
@property (nonatomic,readonly)NSURL *url;
@property (nonatomic,readonly)long long size;
@property (nonatomic, assign)NSString *mediaFilePath;
@property (nonatomic, assign)NSString *fullScreenFilePath;
@property (nonatomic, assign)NSString *vidCapFilePath;
@property (nonatomic, assign)NSString *thumbFilePath;
@property (nonatomic, readonly)ALAsset *theALAsset;
@property (nonatomic, readonly)CGFloat duration;

- (id)initWithDictionary:(NSMutableDictionary *)dict;
- (id)initWithAsset:(ALAsset *)asset;



@end
