//
//  NHCircleImageView.h
//  NHNetEasyPolicyPro
//
//  Created by hu jiaju on 15/7/24.
//  Copyright (c) 2015年 Nanhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NHCircleImageView : UIView

@property (nonatomic, strong)UIColor *borderColor,*pathColor;
@property (nonatomic, assign)float borderWidth;

-(id)initWithFrame:(CGRect)frame withImage:(UIImage *)image;

@end
