//
//  NHDrawerView.m
//  NHNetEasyPolicyPro
//
//  Created by hu jiaju on 15/7/24.
//  Copyright (c) 2015年 Nanhu. All rights reserved.
//

#import "NHDrawerView.h"
#import "NHCircleImageView.h"
#define  kDefaultLineWidth 10
@interface sectorView : UIView
@property (nonatomic, assign)CGFloat startAngle,endAngle;
/**设置画笔 颜色**/
@property (nonatomic, strong)UIColor *lineColor;
/**设置画笔 宽度**/
@property (nonatomic, assign)CGFloat lineWidth;

-(id)initWithFrame:(CGRect)frame withStartAngle:(CGFloat)start withEndAngle:(CGFloat)end;
@end
@implementation sectorView
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame withStartAngle:(CGFloat)start withEndAngle:(CGFloat)end{
    self = [super initWithFrame:frame];
    if (self) {
        _startAngle = start;
        _endAngle = end;
        _lineColor = [[UIColor whiteColor] colorWithAlphaComponent:0.65];
        _lineWidth = kDefaultLineWidth;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - setter
-(void)setLineColor:(UIColor *)lineColor{
    if (!lineColor) {
        return;
    }
    _lineColor = lineColor;
    [self setNeedsDisplay];
}

-(void)setLineWidth:(CGFloat)lineWidth{
    if (!lineWidth||lineWidth<=0) {
        return;
    }
    _lineWidth = lineWidth;
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // set the properties
    CGContextSetAlpha(ctx, 0.6);
    CGContextSetFillColorWithColor(ctx, self.lineColor.CGColor);
    CGContextFillEllipseInRect(UIGraphicsGetCurrentContext(), rect);
    
    CGContextSetAlpha(ctx, 1.f);
    CGRect rectToFill = CGRectMake(_lineWidth,_lineWidth, rect.size.width-_lineWidth*2, rect.size.width-_lineWidth*2);
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillEllipseInRect(UIGraphicsGetCurrentContext(), rectToFill);
}

@end
@interface NHDrawerView ()

@end

@implementation NHDrawerView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Drawer View";
    self.view.backgroundColor = [UIColor lightGrayColor];
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"placeholder" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:bgView];
    bgView.image = image;
    
    CGRect infoRect = CGRectMake(50, 100, 200, 200);
    sectorView *sector = [[sectorView alloc] initWithFrame:infoRect withStartAngle:0 withEndAngle:300];
    [self.view addSubview:sector];
    
    infoRect.origin.y += 200;
    
    NHCircleImageView *circleImage = [[NHCircleImageView alloc] initWithFrame:infoRect withImage:image];
    [circleImage setPathColor:[UIColor whiteColor]];
    [self.view addSubview:circleImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
