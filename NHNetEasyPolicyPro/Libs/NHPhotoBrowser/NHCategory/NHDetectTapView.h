//
//  NHDetectTapView.h
//  LFStreetLifeProject
//
//  Created by Nanhu on 13-4-10.
//  Copyright (c) 2013年 Nanhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NHDetectTapViewDelegate;
@interface NHDetectTapView : UIView

@property (nonatomic, assign)id<NHDetectTapViewDelegate> delegate;

@end

@protocol NHDetectTapViewDelegate <NSObject>

@optional
- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view tripleTapDetected:(UITouch *)touch;

@end