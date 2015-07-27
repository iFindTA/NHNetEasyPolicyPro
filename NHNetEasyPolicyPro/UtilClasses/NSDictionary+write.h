//
//  NSDictionary+write.h
//  NHNetEasyPolicyPro
//
//  Created by hu jiaju on 15/7/27.
//  Copyright (c) 2015年 Nanhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (write)

-(BOOL)writeToPlistFile:(NSString*)filepath;
+(NSDictionary*)readFromPlistFile:(NSString*)filepath;

@end
