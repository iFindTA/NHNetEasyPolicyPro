//
//  NSDictionary+write.m
//  NHNetEasyPolicyPro
//
//  Created by hu jiaju on 15/7/27.
//  Copyright (c) 2015年 Nanhu. All rights reserved.
//

#import "NSDictionary+write.h"

@implementation NSDictionary (write)

-(BOOL)writeToPlistFile:(NSString*)filepath{
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:self];
    BOOL didWriteSuccessfull = [data writeToFile:filepath atomically:YES];
    return didWriteSuccessfull;
}

+(NSDictionary*)readFromPlistFile:(NSString*)filepath{
    NSData * data = [NSData dataWithContentsOfFile:filepath];
    return  [NSKeyedUnarchiver unarchiveObjectWithData:data];
}


@end
