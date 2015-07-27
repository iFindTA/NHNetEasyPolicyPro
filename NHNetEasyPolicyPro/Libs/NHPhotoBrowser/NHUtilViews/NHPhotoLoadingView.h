//
//  NHPhotoLoadingView.h
//  LFStreetLifeProject
//
//  Created by Nanhu on 13-4-10.
//  Copyright (c) 2013年 Nanhu. All rights reserved.
//
#define kMinProgress 0.0001

#import <UIKit/UIKit.h>

@interface NHPhotoLoadingView : UIView

@property (nonatomic) float progress;
- (void)showLoading;
- (void)showFailure;

@end
