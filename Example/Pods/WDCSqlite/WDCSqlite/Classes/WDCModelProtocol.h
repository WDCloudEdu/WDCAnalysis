//
//  WDCModelProtocol.h
//  WDRenRenTong
//
//  Created by 熊伟 on 2019/11/29.
//  Copyright © 2019 伟东人人通. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WDCModelProtocol <NSObject>

///返回建表时需要忽略的成员变量名
+ (NSArray<NSString *> *)ignoredColumnNames;

///新表字段名与旧表字段名的对映关系（用于字段改名时数据迁移）
+ (NSDictionary *)newNameToOldNameDic;

@end
