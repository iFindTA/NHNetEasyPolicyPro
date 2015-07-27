//
//  NHPhotoBrowser.h
//  LFStreetLifeProject
//
//  Created by Nanhu on 13-4-10.
//  Copyright (c) 2013年 Nanhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NHPhotoBrowserDelegate;
@interface NHPhotoBrowser : UIViewController

@property (nonatomic, assign)id<NHPhotoBrowserDelegate> delegate;

// 所有的图片对象
@property (nonatomic, strong) NSArray *photos;
// 当前展示的图片索引
@property (nonatomic, assign) NSUInteger currentPhotoIndex;

// 显示
- (void)show;

@end

@protocol NHPhotoBrowserDelegate <NSObject>
@optional
- (void)willDismissPhotoBrowser:(NHPhotoBrowser *)photobrowser;
// 切换到某一页图片
- (void)photoBrowser:(NHPhotoBrowser *)photoBrowser didChangedToPageAtIndex:(NSUInteger)index;
@end