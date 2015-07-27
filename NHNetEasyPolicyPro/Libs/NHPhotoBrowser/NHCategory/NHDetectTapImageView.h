//
//  NHDetectTapImageView.h
//  LFStreetLifeProject
//
//  Created by Nanhu on 13-4-10.
//  Copyright (c) 2013年 Nanhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NHDetectTapImageViewDelegate;
@interface NHDetectTapImageView : UIImageView

@property (nonatomic, assign)id<NHDetectTapImageViewDelegate> delegate;

@end

@protocol NHDetectTapImageViewDelegate <NSObject>

@optional
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView tripleTapDetected:(UITouch *)touch;

@end