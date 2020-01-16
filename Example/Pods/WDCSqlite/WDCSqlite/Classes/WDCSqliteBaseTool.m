//
//  WDCSqliteBaseTool.m
//  Pods-WDCSqlite_Example
//
//  Created by 熊伟 on 2019/12/18.
//

#import "WDCSqliteBaseTool.h"

#define kCachePath NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject
//#define kCachePath @"/Users/xiongwei/Desktop/testDB"

@implementation WDCSqliteBaseTool

///打开数据库（如果不存在，自动创建）
+ (sqlite3 *)openDBWithUID:(NSString *)uid{
    NSString *dbPath;
    if(uid.length == 0){
        dbPath = [kCachePath stringByAppendingPathComponent:@"common.db"];
    }else{
        dbPath = [kCachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db", uid]];
    }
    sqlite3 *db;
    if(sqlite3_open(dbPath.UTF8String, &db) != SQLITE_OK){
        ///打开数据库失败
        return nil;
    }
    return db;
}

///关闭数据库
+ (void)closeDB:(sqlite3 *)db{
    sqlite3_close(db);
}

///开启事务
+ (void)beginTransaction:(sqlite3 *)db{
    sqlite3_exec(db, "begin transaction", nil, nil, nil);
}

///回滚
+ (void)rollBackTransaction:(sqlite3 *)db{
    sqlite3_exec(db, "rollback transaction", nil, nil, nil);
}

///提交事务
+ (void)commitTransaction:(sqlite3 *)db{
    sqlite3_exec(db, "commit transaction", nil, nil, nil);
}

@end
