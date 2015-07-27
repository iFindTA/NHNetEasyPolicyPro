//
//  imageInfo.h
//  webViewDemo
//
//  Created by 徐坤 on 15/6/2.
//  Copyright (c) 2015年 xukun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONModel.h"

@interface imageInfo : JSONModel

@property(nonatomic,copy)NSString<Optional> *alt;
@property(nonatomic,copy)NSString<Optional> *pixel;
@property(nonatomic,copy)NSString<Optional> *ref;
@property(nonatomic,copy)NSString<Optional> *src;
@property(nonatomic,strong)UIImage<Optional> *imageData;
@property(nonatomic,strong)NSNumber<Optional> *index;

- (id)initWithInfo:(NSDictionary *)dic;


@end
