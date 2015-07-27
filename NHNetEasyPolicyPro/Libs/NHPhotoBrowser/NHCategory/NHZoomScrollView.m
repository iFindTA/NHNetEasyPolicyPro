//
//  NHZoomScrollView.m
//  LFStreetLifeProject
//
//  Created by Nanhu on 13-4-10.
//  Copyright (c) 2013年 Nanhu. All rights reserved.
//

#import "NHZoomScrollView.h"
#import "NHPhoto.h"
#import "NHDetectTapView.h"
#import "NHDetectTapImageView.h"
#import "NHPhotoLoadingView.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

@interface NHZoomScrollView ()<UIScrollViewDelegate,NHDetectTapViewDelegate,NHDetectTapImageViewDelegate>

@property (nonatomic, assign)BOOL isDoubleTapped;
@property (nonatomic, strong)NHDetectTapView *tapBgView;
@property (nonatomic, strong)NHDetectTapImageView *photoImageView;
@property (nonatomic, strong)NHPhotoLoadingView *photoLoadingView;

@end

@implementation NHZoomScrollView

- (void)dealloc {
    _tapBgView = nil;
	_photoImageView = nil;
	_photoLoadingView = nil;
    _photo = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        // Tap view for background
		_tapBgView = [[NHDetectTapView alloc] initWithFrame:self.bounds];
		_tapBgView.delegate = self;
		_tapBgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_tapBgView.backgroundColor = [UIColor blackColor];
		[self addSubview:_tapBgView];
        
        // Image view
		_photoImageView = [[NHDetectTapImageView alloc] initWithFrame:CGRectZero];
		_photoImageView.delegate = self;
		_photoImageView.contentMode = UIViewContentModeScaleAspectFill;
		_photoImageView.backgroundColor = [UIColor blackColor];
		[self addSubview:_photoImageView];
        
        // 进度条
        _photoLoadingView = [[NHPhotoLoadingView alloc] init];
		
		// 属性
		self.backgroundColor = [UIColor clearColor];
		self.delegate = self;
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
		self.decelerationRate = UIScrollViewDecelerationRateFast;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
    }
    return self;
}

#pragma mark - photoSetter
- (void)setPhoto:(NHPhoto *)photo {
    _photo = photo;
    
    [self showImage];
}

#pragma mark 显示图片
- (void)showImage
{
    if (_photo.firstShow) { // 首次显示
        _photoImageView.image = _photo.placeholder; // 占位图片
        _photo.srcImageView.image = nil;
        
        // 不是gif，就马上开始下载
        if (![_photo.url.absoluteString hasSuffix:@"gif"]) {
            __unsafe_unretained NHZoomScrollView *photoView = self;
            __unsafe_unretained NHPhoto *photo = _photo;
            [_photoImageView setImageWithURL:_photo.url placeholderImage:_photo.placeholder options:SDWebImageRetryFailed|SDWebImageLowPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                photo.image = image;
                
                // 调整frame参数
                [photoView adjustFrame];
            }];
        }
    } else {
        [self photoStartLoad];
    }
    
    // 调整frame参数
    [self adjustFrame];
}

#pragma mark 开始加载图片
- (void)photoStartLoad
{
    if (_photo.image) {
        self.scrollEnabled = YES;
        _photoImageView.image = _photo.image;
    } else {
        self.scrollEnabled = NO;
        // 直接显示进度条
        [_photoLoadingView showLoading];
        [self addSubview:_photoLoadingView];
        
        __unsafe_unretained NHZoomScrollView *photoView = self;
        __unsafe_unretained NHPhotoLoadingView *loading = _photoLoadingView;
        [_photoImageView sd_setImageWithURL:_photo.url placeholderImage:_photo.srcImageView.image options:SDWebImageRetryFailed|SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            if (receivedSize > kMinProgress) {
                loading.progress = (float)receivedSize/expectedSize;
            }
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [photoView photoDidFinishLoadWithImage:image];
        }];
    }
}

#pragma mark 加载完毕
- (void)photoDidFinishLoadWithImage:(UIImage *)image
{
    if (image) {
        self.scrollEnabled = YES;
        _photo.image = image;
        [_photoLoadingView removeFromSuperview];
        
        if (_zoomScrollDelegate && [_zoomScrollDelegate respondsToSelector:@selector(photoViewImageFinishLoad:)]) {
            [_zoomScrollDelegate photoViewImageFinishLoad:self];
        }
    } else {
        [self addSubview:_photoLoadingView];
        [_photoLoadingView showFailure];
    }
    
    // 设置缩放比例
    [self adjustFrame];
}
#pragma mark 调整frame
- (void)adjustFrame
{
    //背景点击view
    _tapBgView.frame = self.bounds;
	if (_photoImageView.image == nil) return;
    
    // 基本尺寸参数
    CGSize boundsSize = self.bounds.size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height;
    
    CGSize imageSize = _photoImageView.image.size;
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
	
	// 设置伸缩比例
    CGFloat minScale = boundsWidth / imageWidth;
	if (minScale > 1) {
		minScale = 1.0;
	}
	CGFloat maxScale = 2.0;
	if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
		maxScale = maxScale / [[UIScreen mainScreen] scale];
	}
	self.maximumZoomScale = maxScale;
	self.minimumZoomScale = minScale;
	self.zoomScale = minScale;
    
    CGRect imageFrame = CGRectMake(0, 0, boundsWidth, imageHeight * boundsWidth / imageWidth);
    // 内容尺寸
    self.contentSize = CGSizeMake(0, imageFrame.size.height);
    
    // y值
    if (imageFrame.size.height < boundsHeight) {
        imageFrame.origin.y = floorf((boundsHeight - imageFrame.size.height) / 2.0);
	} else {
        imageFrame.origin.y = 0;
	}
    
    if (_photo.firstShow) { // 第一次显示的图片
        _photo.firstShow = NO; // 已经显示过了
        _photoImageView.frame = [_photo.srcImageView convertRect:_photo.srcImageView.bounds toView:nil];
        
        [UIView animateWithDuration:0.3 animations:^{
            _photoImageView.frame = imageFrame;
        } completion:^(BOOL finished) {
            // 设置底部的小图片
            _photo.srcImageView.image = _photo.placeholder;
            [self photoStartLoad];
        }];
    } else {
        _photoImageView.frame = imageFrame;
    }
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return _photoImageView;
}

#pragma mark - Tap Detection

- (void)handleSingleTap:(CGPoint)touchPoint {
    _isDoubleTapped = NO;
    [self performSelector:@selector(hide) withObject:nil afterDelay:0.2];
}

- (void)hide
{
    /*
     if (_isDoubleTapped) return;
     
     // 移除进度条
     [_photoLoadingView removeFromSuperview];
     self.contentOffset = CGPointZero;
     
     // 清空底部的小图
     _photo.srcImageView.image = nil;
     
     CGFloat duration = 0.15;
     if (_photo.srcImageView.clipsToBounds) {
     [self performSelector:@selector(reset) withObject:nil afterDelay:duration];
     }
     
     [UIView animateWithDuration:duration + 0.1 animations:^{
     _photoImageView.frame = [_photo.srcImageView convertRect:_photo.srcImageView.bounds toView:nil];
     
     // gif图片仅显示第0张
     if (_photoImageView.image.images) {
     _photoImageView.image = _photoImageView.image.images[0];
     }
     
     // 通知代理
     if (_zoomScrollDelegate && [_zoomScrollDelegate respondsToSelector:@selector(photoViewSingleTap:)]) {
     [_zoomScrollDelegate photoViewSingleTap:self];
     }
     } completion:^(BOOL finished) {
     // 设置底部的小图片
     _photo.srcImageView.image = _photo.placeholder;
     }];
     //*/
    
    if (_isDoubleTapped) return;
    
    // 移除进度条
    [_photoLoadingView removeFromSuperview];
    if (_zoomScrollDelegate &&[_zoomScrollDelegate respondsToSelector:@selector(photoViewSingleTap:)] ) {
        [_zoomScrollDelegate photoViewSingleTap:self];
    }
}

- (void)reset
{
    _photoImageView.image = _photo.capture;
    _photoImageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)handleDoubleTap:(CGPoint)touchPoint {
	_isDoubleTapped = YES;
	// Zoom
	if (self.zoomScale == self.maximumZoomScale) {
		
		// Zoom out
		[self setZoomScale:self.minimumZoomScale animated:YES];
		
	} else {
		
		// Zoom in
		[self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
		
	}
}

// Image View
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch {
    [self handleSingleTap:[touch locationInView:imageView]];
}
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch {
    [self handleDoubleTap:[touch locationInView:imageView]];
}

// Background View
- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch {
    [self handleSingleTap:[touch locationInView:view]];
}
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch {
    [self handleDoubleTap:[touch locationInView:view]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
