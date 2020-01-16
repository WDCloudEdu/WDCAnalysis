//
//  WDCSqliteModelTool.h
//  Pods-WDCSqlite_Example
//
//  Created by 熊伟 on 2019/12/18.
//

#import <Foundation/Foundation.h>
#import "WDCSqliteConditionMaker.h"

@interface WDCSqliteModelTool : NSObject

///插入模型到数据库
+ (BOOL)insertModel:(id)model uid:(NSString *)uid;
///批量插入模型到数据库(注：models中的对象，类必须相同)
+ (BOOL)insertModels:(NSArray *)models uid:(NSString *)uid;

///根据条件查询数据库记录(不传条件时查询表中所有记录)
+ (NSArray *)queryModels:(Class)cls uid:(NSString *)uid condition:(void(^)(WDCSqliteConditionMaker *maker))block;
///根据条件字符串查询数据库记录
+ (NSArray *)queryModels:(Class)cls whereStr:(NSString *)whereStr uid:(NSString *)uid;

///根据条件删除数据库记录(不传条件时删除表中所有记录)
+ (BOOL)deleteModels:(Class)cls uid:(NSString *)uid condition:(void(^)(WDCSqliteConditionMaker *maker))block;
///根据条件条件字符串删除数据库记录
+ (BOOL)deleteModels:(Class)cls whereStr:(NSString *)whereStr uid:(NSString *)uid;
///从数据库中删除queryModels方法查出来的记录
+ (BOOL)deleteModels:(NSArray *)models uid:(NSString *)uid;

@end

