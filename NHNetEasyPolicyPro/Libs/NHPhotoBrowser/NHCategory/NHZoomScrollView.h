//
//  NHZoomScrollView.h
//  LFStreetLifeProject
//
//  Created by Nanhu on 13-4-10.
//  Copyright (c) 2013年 Nanhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NHPhotoBrowser,NHPhoto;
@protocol NHZoomScrollViewDelegate;
@interface NHZoomScrollView : UIScrollView

@property (nonatomic, strong)NHPhoto *photo;
@property (nonatomic, assign)id<NHZoomScrollViewDelegate> zoomScrollDelegate;

@end

@protocol NHZoomScrollViewDelegate <NSObject>
@optional
- (void)photoViewImageFinishLoad:(NHZoomScrollView *)photoView;
- (void)photoViewSingleTap:(NHZoomScrollView *)photoView;

@end