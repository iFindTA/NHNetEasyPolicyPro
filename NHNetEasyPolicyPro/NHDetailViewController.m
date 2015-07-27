//
//  NHDetailViewController.m
//  NHNetEasyPolicyPro
//
//  Created by hu jiaju on 15-7-23.
//  Copyright (c) 2015年 Nanhu. All rights reserved.
//

#import "NHDetailViewController.h"
#import "SVProgressHUD.h"
#import "SDWebImageManager.h"
#import "WebViewJavascriptBridge.h"
#import "imageInfo.h"
#import "JSONKit.h"
#import "NHUtil.h"
#import "NSDictionary+write.h"
#import "NHPhoto.h"
#import "NHPhotoBrowser.h"

@interface NHDetailViewController ()<UIWebViewDelegate>

@property (nonatomic, strong)WebViewJavascriptBridge *t_bridge;
@property (nonatomic, strong)UIWebView *t_webview;
@property (nonatomic, strong)NSMutableArray *imageSources;
@property (nonatomic, strong)NSDictionary *sourceData;
@property (nonatomic, assign)BOOL pict_mode_true;

@end
static NSString *fileName = @"testInfo.json";
@implementation NHDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Web Detail";
    _pict_mode_true = true;
    
    CGRect infoBounds = self.view.bounds;
    _t_webview = [[UIWebView alloc] initWithFrame:infoBounds];
    _t_webview.opaque = NO;
    _t_webview.backgroundColor = [UIColor colorWithWhite:0.95 alpha:0.95];
    [self.view addSubview:_t_webview];
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"template" ofType:@"html"];
    NSMutableString *appHtml = [NSMutableString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [_t_webview loadHTMLString:appHtml baseURL:baseURL];
    
    [WebViewJavascriptBridge enableLogging];
    _t_bridge = [WebViewJavascriptBridge bridgeForWebView:_t_webview webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"ObjC received message from JS: %@", data);
        responseCallback(@"Response for message from ObjC");
        [self handleWebViewTouchEvent:data];
    }];
   
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self loadSavedInfo];
}

-(void)loadSavedInfo{
    NSString *filePath = [NHUtil filePath:fileName];
    NSDictionary *dic = [NSDictionary readFromPlistFile:filePath];
    //NSLog(@"saved info counts:%ld",[savedInfo count]);
    if (dic != nil) {
        [self renderBody:dic];
    }else{
        [self loadTestData];
    }
}

-(void)loadTestData{
    [SVProgressHUD showWithStatus:@"wating..."];
    
    NSURL *url = [NSURL URLWithString:@"https://api.gongshidai.com/cj_v1/testarticle"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"GET" forHTTPHeaderField:@"METHOD"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [SVProgressHUD dismiss];
        NSLog(@"result:%@----data:%@",response,[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *dic = [responseStr objectFromJSONString];
        [self renderBody:dic];
        [self saveInfo:dic];
    }];
}
-(void)saveInfo:(id)info{
    NSString *filePath = [NHUtil filePath:fileName];
    [info writeToPlistFile:filePath];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSLog(@"webview jump:%@",request.URL.absoluteString);
    
    return YES;
}

-(void)renderBody:(NSDictionary *)data{
    if (data != nil) {
        NSDictionary *dic = data;
        //NSMutableString *bodyStr = [NSMutableString stringWithString:[dic objectForKey:@"body"]];
        //NSMutableDictionary *tempData = [NSMutableDictionary dictionaryWithDictionary:dic];
        NSArray *imgArr = [dic objectForKey:@"img"];
        if (imgArr&&[imgArr count]) {
            NSLog(@"该咨询有图片");
            if (_imageSources && _imageSources.count) {
                [_imageSources removeAllObjects];_imageSources = nil;
            }
            _imageSources = [[NSMutableArray alloc] initWithCapacity:0];
            for (int i = 0;i<[imgArr count];i++) {
                NSDictionary *d = [imgArr objectAtIndex:i];
                NSNumber *index = [NSNumber numberWithInt:i];
                imageInfo *info = [[imageInfo alloc] initWithDictionary:d error:nil];
                info.index =(NSNumber<Optional>*) index;
                [_imageSources addObject:info];
            }
        }
        
        //{data:xx,template:"tpl.normal.js",pict:1,defaultimg:""}
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:dic forKey:@"data"];
        [params setObject:_pict_mode_true?@"tpl.normal.js":@"tpl.nopic.js" forKey:@"template"];
        [params setObject:[NSNumber numberWithBool:_pict_mode_true] forKey:@"pict"];
        NSString *localImgPath = [[NSBundle mainBundle] pathForResource:@"placeholder" ofType:@"jpg"];
        [params setObject:localImgPath forKey:@"defaultimg"];
        [_t_bridge callHandler:@"buildHtmlHandler" data:params responseCallback:^(id responseData) {
            //NSLog(@"response:%@",responseData);
            if (_pict_mode_true) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self loadImages];
                });
            }
        }];
    }
}

-(void)loadImageForIndex:(NSNumber *)number{
    int index = [number intValue];
    imageInfo *info = [_imageSources objectAtIndex:index];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [[SDWebImageManager sharedManager] setCacheKeyFilter:^(NSURL *url) {
        url = [[NSURL alloc] initWithScheme:url.scheme host:url.host path:url.path];
        //NSString *str = [self replaceUrlSpecialString:[url absoluteString]];
        NSString *str = [url absoluteString];
        return str;
    }];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths firstObject];
    NSString *filePath = [path stringByAppendingPathComponent:@"com.hackemist.SDWebImageCache.default"];
    NSURL *imageUrl = [NSURL URLWithString:info.src];
    if ([manager diskImageExistsForURL:imageUrl]) {
        NSString *cachekey = [manager cacheKeyForURL:imageUrl];
        NSString *imagePath = [NSString stringWithFormat:@"%@/%@",filePath,[manager.imageCache cachedFileNameForKey:cachekey]];
        UIImage *imageData = [manager.imageCache imageFromDiskCacheForKey:cachekey];
        info.imageData = (UIImage<Optional>*)imageData;
        NSLog(@"cache imagepath:%@",imagePath);
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:imagePath,@"src",info.index,@"index", nil];
        [_t_bridge callHandler:@"callLoadImage" data:data responseCallback:^(id responseData) {
            NSLog(@"callLoadImage response data:%@",responseData);
        }];
    }else{
        [manager downloadImageWithURL:imageUrl options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (image && finished) {
                NSString *cachekey = [manager cacheKeyForURL:imageUrl];
                NSString *imagePath = [NSString stringWithFormat:@"%@/%@",filePath,[manager.imageCache cachedFileNameForKey:cachekey]];
                info.imageData = (UIImage<Optional>*)image;
                NSLog(@"download imagepath:%@",imagePath);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:imagePath,@"src",info.index,@"index", nil];
                    [_t_bridge callHandler:@"callLoadImage" data:data responseCallback:^(id responseData) {
                        NSLog(@"callLoadImage response data:%@",responseData);
                    }];
                });
            }
        }];
    }
}

-(void)loadImages{
    if (!_imageSources) {
        return;
    }
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [[SDWebImageManager sharedManager] setCacheKeyFilter:^(NSURL *url) {
        url = [[NSURL alloc] initWithScheme:url.scheme host:url.host path:url.path];
        //NSString *str = [self replaceUrlSpecialString:[url absoluteString]];
        NSString *str = [url absoluteString];
        return str;
    }];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths firstObject];
    NSString *filePath = [path stringByAppendingPathComponent:@"com.hackemist.SDWebImageCache.default"];
    for (imageInfo *info in _imageSources) {
        NSURL *imageUrl = [NSURL URLWithString:info.src];
        if ([manager diskImageExistsForURL:imageUrl]) {
            NSString *cachekey = [manager cacheKeyForURL:imageUrl];
            NSString *imagePath = [NSString stringWithFormat:@"%@/%@",filePath,[manager.imageCache cachedFileNameForKey:cachekey]];
            UIImage *imageData = [manager.imageCache imageFromDiskCacheForKey:cachekey];
            info.imageData = (UIImage<Optional>*)imageData;
            NSLog(@"cache imagepath:%@",imagePath);
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:imagePath,@"src",info.index,@"index", nil];
            [_t_bridge callHandler:@"callLoadImage" data:data responseCallback:^(id responseData) {
                NSLog(@"callLoadImage response data:%@",responseData);
            }];
        }else{
            [manager downloadImageWithURL:imageUrl options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                if (image && finished) {
                    NSString *cachekey = [manager cacheKeyForURL:imageUrl];
                    NSString *imagePath = [NSString stringWithFormat:@"%@/%@",filePath,[manager.imageCache cachedFileNameForKey:cachekey]];
                    info.imageData = (UIImage<Optional>*)image;
                    NSLog(@"download imagepath:%@",imagePath);
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:imagePath,@"src",info.index,@"index", nil];
                        [_t_bridge callHandler:@"callLoadImage" data:data responseCallback:^(id responseData) {
                            NSLog(@"callLoadImage response data:%@",responseData);
                        }];
                    });
                }
            }];
        }
    }
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"webViewDidFinishLoad");
}

-(void)handleWebViewTouchEvent:(id)data{
    if (data != nil) {
        NSDictionary *dic = (NSDictionary *)data;
        NSNumber *index;
        NSString *type = [dic objectForKey:@"type"];
        if ([type isEqualToString:@"relate"]) {
            index = [dic objectForKey:@"id"];
            NSLog(@"点击相关阅读:%@",index);
        }else if ([type isEqualToString:@"img"]){
            index = [dic objectForKey:@"index"];
            NSLog(@"点击图片:%@",index);
            [self dealWithImageEvent:index];
            BOOL shouldLoad = [[dic objectForKey:@"loadImg"] boolValue];
            if (shouldLoad) {
                //下载图片
                NSLog(@"赶快去下载图片");
            }else{
                //图集轮播
                NSLog(@"赶快轮播图片");
            }
        }
    }
}

-(void)dealWithImageEvent:(NSNumber *)index{
    BOOL shouldLoad = false;imageInfo *t_dest_info;
    @synchronized(_imageSources){
        for (imageInfo *info in _imageSources) {
            if ([info.index isEqualToNumber:index]) {
                shouldLoad = info.imageData==nil;
                t_dest_info = info;
                break;
            }
        }
    }
    
    if (shouldLoad) {
        [self loadImageForIndex:index];
    }else{
        // see the images with a browser
        NSMutableArray *photos = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i<[_imageSources count]; i++){
            imageInfo *info = [_imageSources objectAtIndex:i];
            if (info.imageData==nil) continue;
            NSString *url = info.src;
            NHPhoto *photo = [[NHPhoto alloc] init];
            photo.url = [NSURL URLWithString:url]; // 图片路径
            [photos addObject:photo];
        }
        NHPhotoBrowser *browser = [[NHPhotoBrowser alloc] init];
        browser.currentPhotoIndex = [index integerValue];
        browser.photos = photos; // 设置所有的图片
        [browser show];
    }
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
