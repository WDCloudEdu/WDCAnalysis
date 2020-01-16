//
//  WDCModelTool.h
//  WDRenRenTong
//
//  Created by 熊伟 on 2019/11/29.
//  Copyright © 2019 伟东人人通. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDCModelTool : NSObject

///获取cls类对应的表名
+ (NSString *)tableName:(Class)cls;
///获取cls类对应的临时表名(更新表时使用)
+ (NSString *)tmpTableName:(Class)cls;

///获取cls类对应表的列名及类型字符串 (如: @"name text, score real, age integer, ....")
+ (NSString *)columnNamesAndTypesStr:(Class)cls;

///获取cls类对应表的所有字段
+ (NSArray<NSString *> *)tableSortedColumnNames:(Class)cls;

///获取cls类中有效的（未被忽略的）的成员变量及类型
+ (NSDictionary *)classIvarNameTypeDic:(Class)cls;

@end
