//
//  NHCircleImageView.m
//  NHNetEasyPolicyPro
//
//  Created by hu jiaju on 15/7/24.
//  Copyright (c) 2015年 Nanhu. All rights reserved.
//

#import "NHCircleImageView.h"

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight){
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;
    
    CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

@interface UIImage (circle)
- (id)roundCornerImageWithsize:(CGSize)size radius:(float)radius;
@end

@implementation UIImage(circle)

/**
 *  @brief  创建圆角图片
 *
 *  @param  size    优化后的图片大小
 *  @param  radius  圆角半径
 *
 *  @return 返回圆角图片
 */
- (id)roundCornerImageWithsize:(CGSize)size radius:(float)radius
{
    // the size of CGContextRef
    int w = size.width;
    int h = size.height;
    CGRect rect = CGRectMake(0, 0, w, h);
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
    {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0); // 0.0 for scale means "scale for device's main screen".
    }
#else
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0)
    {
        UIGraphicsBeginImageContext([image size]);
    }
#endif
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextBeginPath(contextRef);
    addRoundedRectToPath(contextRef, rect, radius, radius);
    CGContextClosePath(contextRef);
    CGContextClip(contextRef);
    
    [self drawInRect:rect];
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newPic;
}
@end

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
    
    UIGraphicsBeginImageContextWithOptions(rect.size, 0, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat wh = _borderWidth;
    //addRoundedRectToPath(ctx, rect, wh, wh);
    [_originImg drawInRect:rect];
    
//    imgRect = rect;
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
