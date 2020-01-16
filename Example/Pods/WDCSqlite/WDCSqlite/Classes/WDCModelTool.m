//
//  WDCModelTool.m
//  WDRenRenTong
//
//  Created by 熊伟 on 2019/11/29.
//  Copyright © 2019 伟东人人通. All rights reserved.
//

#import "WDCModelTool.h"
#import "WDCModelProtocol.h"
#import <objc/runtime.h>

@implementation WDCModelTool

#pragma mark - 接口

///获取cls类对应的表名
+ (NSString *)tableName:(Class)cls{
    return NSStringFromClass(cls);
}

///获取cls类对应的临时表名(更新表时使用)
+ (NSString *)tmpTableName:(Class)cls{
    return [[self tableName:cls] stringByAppendingString:@"Tmp"];
}

///获取cls类对应表的列名及类型字符串 (如: @"name text, score real, age integer, ....")
+ (NSString *)columnNamesAndTypesStr:(Class)cls{
    
    NSDictionary *ivarNameSqliteTypeDic = [self classIvarNameSqliteTypeDic:cls];
    NSMutableArray *result = [NSMutableArray array];
    [ivarNameSqliteTypeDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull ivarName, id  _Nonnull sqliteType, BOOL * _Nonnull stop) {
        [result addObject:[NSString stringWithFormat:@"%@ %@",ivarName, sqliteType]];
    }];
    return [result componentsJoinedByString:@","];
}

///获取cls类对应表的所有字段
+ (NSArray<NSString *> *)tableSortedColumnNames:(Class)cls{
    ///注：这里不能使用classIvarNameTypeDic,因为有些oc类型无法转换为sqlite类型，所以classIvarNameSqliteTypeDic的范围是小于或等于classIvarNameTypeDic的。但是建表是以classIvarNameSqliteTypeDic为准的。
    NSDictionary *dic = [self classIvarNameSqliteTypeDic:cls];
    NSArray *keys = dic.allKeys;
    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull ivarName1, id  _Nonnull ivarName2) {
        return [ivarName1 compare:ivarName2];
    }];
    return keys;
}

///获取cls类中有效的（未被忽略的）的成员变量及类型
+ (NSDictionary *)classIvarNameTypeDic:(Class)cls{
    ///成员变量个数
    unsigned int outCount = 0;
    ///获取成员变量列表(ivarList:指向数组首元素的指针)
    Ivar *ivarList = class_copyIvarList(cls, &outCount);
    
    ///被忽略的成员变量列表
    NSArray<NSString *> *ignoredNames;
    if([cls respondsToSelector:@selector(ignoredColumnNames)]){
        ignoredNames = [cls ignoredColumnNames];
    }
    
    NSMutableDictionary *ivarNameTypeDict = [NSMutableDictionary dictionary];
    for(int i = 0; i < outCount; i++){
        Ivar ivar = ivarList[i];
        ///获取成员变量名
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        ///去除"_"
        if([ivarName hasPrefix:@"_"]){
            ivarName = [ivarName substringFromIndex:1];
        }
        
        ///成员变量被忽略
        if([ignoredNames containsObject:ivarName]){
            continue;
        }
        
        NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        ///去除获取到类型中的"@"和"""符号 (如 @"@\"NSString\"")
        type = [type stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\""]];
        if(ivarName){
            ivarNameTypeDict[ivarName] = type;
        }
    }
    return ivarNameTypeDict;
}

#pragma mark - 私有
///获取cls类中所有的成员变量及对应的sqlite类型
+ (NSDictionary *)classIvarNameSqliteTypeDic:(Class)cls{
    NSMutableDictionary *dic = [[self classIvarNameTypeDic:cls] mutableCopy];
    NSDictionary *ocTypeToSqliteTypeDic = [self ocTypeToSqliteTypeDic];
    
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull ivarName, id  _Nonnull ocType, BOOL * _Nonnull stop) {
        dic[ivarName] = ocTypeToSqliteTypeDic[ocType];
    }];
    
    return dic;
}

///oc类型转sqlite类型对映关系字典
+ (NSDictionary *)ocTypeToSqliteTypeDic {
    return @{
             @"d": @"real", // double
             @"f": @"real", // float
             
             @"i": @"integer",  // int
             @"q": @"integer", // long
             @"Q": @"integer", // long long
             @"B": @"integer", // bool
             
             @"NSString": @"text",
             @"NSMutableString": @"text",
             @"NSDictionary": @"blob",
             @"NSMutableDictionary": @"blob",
             @"NSArray": @"blob",
             @"NSMutableArray": @"blob",
             
             @"NSData": @"blob",
             @"UIImage": @"blob",
             
             @"NSDate": @"real"
             };
    
}

@end
