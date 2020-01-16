//
//  WDCSqliteBaseTool.h
//  Pods-WDCSqlite_Example
//
//  Created by 熊伟 on 2019/12/18.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface WDCSqliteBaseTool : NSObject

///打开数据库（如果不存在，自动创建。uid:不同用户的数据存放在不同的db里，如"zhangsan.db"(如果传nil则在common.db中进行操作)）
+ (sqlite3 *)openDBWithUID:(NSString *)uid;
///关闭数据库
+ (void)closeDB:(sqlite3 *)db;
///开启事务
+ (void)beginTransaction:(sqlite3 *)db;
///回滚
+ (void)rollBackTransaction:(sqlite3 *)db;
///提交事务
+ (void)commitTransaction:(sqlite3 *)db;

@end
