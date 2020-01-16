//
//  WDCUser.m
//  WDCAnalysis_Example
//
//  Created by 熊伟 on 2019/12/23.
//  Copyright © 2019 xiongwei. All rights reserved.
//

#import "WDCUser.h"

@implementation WDCUser

static id _instance;

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (instancetype)sharedUser{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone{
    return _instance;
}

@end
