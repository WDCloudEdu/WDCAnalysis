//
//  WDCSqliteAPI.h
//  WDRenRenTong
//
//  Created by 熊伟 on 2019/12/3.
//  Copyright © 2019 伟东人人通. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDCSqliteConditionMaker.h"

@interface WDCSqliteAPI : NSObject

///插入模型到数据库
+ (void)insertModel:(id)model uid:(NSString *)uid completionHandler:(void(^)(BOOL res))completionHandler;
///批量插入模型到数据库(注：models中的对象，类必须相同)
+ (void)insertModels:(NSArray *)models uid:(NSString *)uid completionHandler:(void(^)(BOOL res))completionHandler;

///根据条件查询数据库记录(不传条件时查询表中所有记录)
+ (void)queryModels:(Class)cls uid:(NSString *)uid condition:(void(^)(WDCSqliteConditionMaker *maker))block completionHandler:(void(^)(NSArray *models))completionHandler;
///根据条件字符串查询数据库记录
+ (void)queryModels:(Class)cls whereStr:(NSString *)whereStr uid:(NSString *)uid completionHandler:(void(^)(NSArray *models))completionHandler;

///根据条件删除数据库记录(不传条件时删除表中所有记录)
+ (void)deleteModels:(Class)cls uid:(NSString *)uid condition:(void(^)(WDCSqliteConditionMaker *maker))block completionHandler:(void(^)(BOOL res))completionHandler;
///根据条件条件字符串删除数据库记录
+ (void)deleteModels:(Class)cls whereStr:(NSString *)whereStr uid:(NSString *)uid completionHandler:(void(^)(BOOL res))completionHandler;
///从数据库中删除queryModels方法查出来的记录
+ (void)deleteModels:(NSArray *)models uid:(NSString *)uid completionHandler:(void(^)(BOOL res))completionHandler;

@end
