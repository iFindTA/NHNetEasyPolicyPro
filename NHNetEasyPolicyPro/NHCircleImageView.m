//
//  NHCircleImageView.m
//  NHNetEasyPolicyPro
//
//  Created by hu jiaju on 15/7/24.
//  Copyright (c) 2015年 Nanhu. All rights reserved.
//

#import "NHCircleImageView.h"

@interface NHCircleImageView ()

@property (nonatomic, strong)UIImage *originImg;

@end

@implementation NHCircleImageView

-(id)initWithFrame:(CGRect)frame withImage:(UIImage *)image{
    self = [super initWithFrame:frame];
    if (self) {
        _originImg = image;
        [self setDefaultParams];
    }
    return self;
}

-(void)setDefaultParams{
    _pathColor = _borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.65];
    _borderWidth = 10;
}

-(void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    [self setNeedsDisplay];
}

-(void)setPathColor:(UIColor *)pathColor{
    _pathColor = pathColor;
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect{
    CGRect imgRect = rect;
    imgRect.origin.x += _borderWidth;
    imgRect.origin.y += _borderWidth;
    imgRect.size.width -= _borderWidth*2;
    imgRect.size.height -= _borderWidth*2;
    
    UIGraphicsBeginImageContextWithOptions(rect.size, 0, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClip(ctx);
    [_originImg drawInRect:imgRect];
    
    imgRect = rect;
    CGContextSetStrokeColorWithColor(ctx, _borderColor.CGColor);
    CGContextSetLineWidth(ctx, _borderWidth);
    CGContextStrokeEllipseInRect(ctx, imgRect);
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
