//
//  WDCSqliteTool.m
//  WDRenRenTong
//
//  Created by 熊伟 on 2019/11/29.
//  Copyright © 2019 伟东人人通. All rights reserved.
//

#import "WDCSqliteTool.h"
#import "WDCSqliteBaseTool.h"
#import <objc/runtime.h>

@implementation WDCSqliteTool

///处理DML语句  uid:不同用户的数据存放在不同的db里，如"zhangsan.db"(如果传nil则在common.db中进行操作)
+ (BOOL)dealSql:(NSString *)sql withUID:(NSString *)uid{
    sqlite3 *db = [WDCSqliteBaseTool openDBWithUID:uid];
    ///打开数据库失败，返回失败
    if(db == nil){
        return NO;
    }
    ///执行sql
    BOOL result = (sqlite3_exec(db, sql.UTF8String, nil, nil, nil) == SQLITE_OK);

    ///关闭数据库
    [WDCSqliteBaseTool closeDB:db];
    
    return result;
}

///处理多条DML语句
+ (BOOL)dealSqls:(NSArray<NSString *> *)sqls withUID:(NSString *)uid{
    sqlite3 *db = [WDCSqliteBaseTool openDBWithUID:uid];
    ///打开数据库失败，返回失败
    if(db == nil){
        return NO;
    }
    ///开启事务
    [WDCSqliteBaseTool beginTransaction:db];
    
    for(NSString *sql in sqls){
        @autoreleasepool {
            BOOL result = (sqlite3_exec(db, sql.UTF8String, nil, nil, nil) == SQLITE_OK);
            ///某条语句执行失败，回滚
            if(!result){
                [WDCSqliteBaseTool rollBackTransaction:db];
                ///关闭数据库
                [WDCSqliteBaseTool closeDB:db];
                return NO;
            }
        }
    }
    ///提交事务
    [WDCSqliteBaseTool commitTransaction:db];

    ///关闭数据库
    [WDCSqliteBaseTool closeDB:db];
    return YES;
}

///处理DQL语句
+ (NSArray<NSDictionary *> *)querySql:(NSString *)sql withUID:(NSString *)uid{
    sqlite3 *db = [WDCSqliteBaseTool openDBWithUID:uid];
    ///打开数据库失败，返回失败
    if(db == nil){
        return nil;
    }
    ///创建准备语句
    sqlite3_stmt *ppStmt;
    if(sqlite3_prepare(db, sql.UTF8String, -1, &ppStmt, nil) != SQLITE_OK){
        ///预处理失败
        [self releaseStmt:ppStmt andCloseDB:db];
        return nil;
    }
    ///绑定（传入的sql不带?，不需要）
    
    NSMutableArray *rowDictArray = [NSMutableArray array];
    ///执行
    ///返回SQLITE_ROW代表下一行还有记录，读取记录中的数据装入数组
    while(sqlite3_step(ppStmt) == SQLITE_ROW){
    ///对一条记录做操作
        ///获取列数
        int columnCount = sqlite3_column_count(ppStmt);
        
        NSMutableDictionary *rowDict = [NSMutableDictionary dictionary];
        ///遍历列
        for(int i = 0; i < columnCount; i++){
            ///获取列名
            NSString *columnName = [NSString stringWithUTF8String:sqlite3_column_name(ppStmt, i)];
            ///获取列的类型
            int columnType = sqlite3_column_type(ppStmt, i);
            
            id value;
            ///根据不同类型，调用不同函数获取列中的值
            switch (columnType) {
                case SQLITE_INTEGER:{///整型
                    value = @(sqlite3_column_int(ppStmt, i));
                    break;
                }
                case SQLITE_FLOAT:{///浮点
                    value = @(sqlite3_column_double(ppStmt, i));
                    break;
                }
                case SQLITE_BLOB:{///二进制
                    const void *bytes = sqlite3_column_blob(ppStmt, i);
                    int size = sqlite3_column_bytes(ppStmt, i);
                    NSData *data = [[NSData alloc] initWithBytes:bytes length:size];
                    value = data;
                    break;
                }
                case SQLITE_NULL:{///空
                    ///对于空的情况，字典中就不设置这个键值对了。这样在转模型时也比较符合实际情况
                    break;
                }
                case SQLITE3_TEXT:{///字符串
                    value = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(ppStmt, i)];
                    break;
                }
                default:
                    break;
            }
            if(columnName){
                rowDict[columnName] = value;
            }
        }
        [rowDictArray addObject:rowDict];
    }
    ///重置（不需要）
    
    [self releaseStmt:ppStmt andCloseDB:db];
    return rowDictArray;
}

///释放准备语句并关闭数据库
+ (void)releaseStmt:(sqlite3_stmt *)stmt andCloseDB:(sqlite3 *)db{
    ///释放准备语句
    sqlite3_finalize(stmt);
    ///关闭数据库
    [WDCSqliteBaseTool closeDB:db];
}

@end
