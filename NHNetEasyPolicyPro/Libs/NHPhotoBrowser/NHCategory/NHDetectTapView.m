//
//  NHDetectTapView.m
//  LFStreetLifeProject
//
//  Created by Nanhu on 13-4-10.
//  Copyright (c) 2013年 Nanhu. All rights reserved.
//

#import "NHDetectTapView.h"

@implementation NHDetectTapView

- (id)init {
	if ((self = [super init])) {
		self.userInteractionEnabled = YES;
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.userInteractionEnabled = YES;
	}
	return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	NSUInteger tapCount = touch.tapCount;
	switch (tapCount) {
		case 1:
			[self handleSingleTap:touch];
			break;
		case 2:
			[self handleDoubleTap:touch];
			break;
		case 3:
			[self handleTripleTap:touch];
			break;
		default:
			break;
	}
	// Doesnt work in iOS 3
	//	switch (tapCount) {
	//		case 1:
	//			[self performSelector:@selector(handleSingleTap:) withObject:touch afterDelay:0.2];
	//			break;
	//		case 2:
	//			[NSObject cancelPreviousPerformRequestsWithTarget:self];
	//			[self performSelector:@selector(handleDoubleTap:) withObject:touch afterDelay:0.2];
	//			break;
	//		case 3:
	//			[NSObject cancelPreviousPerformRequestsWithTarget:self];
	//			[self performSelector:@selector(handleTripleTap:) withObject:touch afterDelay:0.2];
	//			break;
	//		default:
	//			break;
	//	}
	[[self nextResponder] touchesEnded:touches withEvent:event];
}

- (void)handleSingleTap:(UITouch *)touch {
	if (_delegate && [_delegate respondsToSelector:@selector(view:singleTapDetected:)])
		[_delegate view:self singleTapDetected:touch];
}

- (void)handleDoubleTap:(UITouch *)touch {
	if (_delegate && [_delegate respondsToSelector:@selector(view:doubleTapDetected:)])
		[_delegate view:self doubleTapDetected:touch];
}

- (void)handleTripleTap:(UITouch *)touch {
	if (_delegate && [_delegate respondsToSelector:@selector(view:tripleTapDetected:)])
		[_delegate view:self tripleTapDetected:touch];
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
