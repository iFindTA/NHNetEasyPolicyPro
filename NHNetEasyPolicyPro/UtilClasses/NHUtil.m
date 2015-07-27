//
//  NHUtil.m
//  NHNetEasyPolicyPro
//
//  Created by hu jiaju on 15-7-23.
//  Copyright (c) 2015年 Nanhu. All rights reserved.
//

#import "NHUtil.h"

@implementation NHUtil

+(NSString *)documentPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    return [paths firstObject];
}
+(NSString *)filePath:(NSString *)fileName{
    return [[self documentPath] stringByAppendingPathComponent:fileName];
}

@end
