//
//  WDCUser.h
//  WDCAnalysis_Example
//
//  Created by 熊伟 on 2019/12/23.
//  Copyright © 2019 xiongwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDCUser : NSObject

/// 用户Id
@property (nonatomic, copy) NSString *userId;
/// 昵称
@property (nonatomic, copy) NSString *nickname;

+ (instancetype)sharedUser;

@end
