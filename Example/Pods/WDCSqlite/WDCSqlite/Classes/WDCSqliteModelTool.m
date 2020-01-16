//
//  WDCSqliteModelTool.m
//  Pods-WDCSqlite_Example
//
//  Created by 熊伟 on 2019/12/18.
//

#import "WDCSqliteModelTool.h"
#import "WDCModelTool.h"
#import "WDCTableTool.h"
#import "WDCSqliteBaseTool.h"
#import "WDCSqliteTool.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@implementation WDCSqliteModelTool

#pragma mark - 接口
///插入模型到数据库
+ (BOOL)insertModel:(id)model uid:(NSString *)uid{
    Class cls = [model class];
    NSArray<NSString *> *columnNames = [WDCModelTool tableSortedColumnNames:cls];
    
    sqlite3 *db = [WDCSqliteBaseTool openDBWithUID:uid];
    ///打开数据库失败，返回失败
    if(db == nil){
        return NO;
    }
    ///获取准备语句
    sqlite3_stmt *ppStmt = [self insertPrepareWithClass:cls uid:uid columnNames:columnNames db:db];
    if(ppStmt == nil){
        return NO;
    }
    ///准备语句绑定并执行
    if([self ppStmt:ppStmt bindAndStepWithColumnNames:columnNames model:model] == NO){
        ///失败
        [self releaseStmt:ppStmt andCloseDB:db];
        return NO;
    }
    ///释放准备语句并关闭数据库
    [self releaseStmt:ppStmt andCloseDB:db];
    return YES;
}

///批量插入模型到数据库(注：models中的对象，类必须相同)
+ (BOOL)insertModels:(NSArray *)models uid:(NSString *)uid{
    id model = [models firstObject];
    if(model == nil){
        return NO;
    }
    
    Class cls = [model class];
    NSArray<NSString *> *columnNames = [WDCModelTool tableSortedColumnNames:cls];
    
    sqlite3 *db = [WDCSqliteBaseTool openDBWithUID:uid];
    ///打开数据库失败，返回失败
    if(db == nil){
        return NO;
    }
    ///获取准备语句
    sqlite3_stmt *ppStmt = [self insertPrepareWithClass:cls uid:uid columnNames:columnNames db:db];
    ///获取准备语句
    if(ppStmt == nil){
        return NO;
    }
    
    ///开启事务
    [WDCSqliteBaseTool beginTransaction:db];
    
    for(id model in models){
        @autoreleasepool {
            ///准备语句绑定并执行失败
            if([self ppStmt:ppStmt bindAndStepWithColumnNames:columnNames model:model] == NO){
                ///回滚
                [WDCSqliteBaseTool rollBackTransaction:db];
                [self releaseStmt:ppStmt andCloseDB:db];
                return NO;
            }
            ///重置
            if(sqlite3_reset(ppStmt) != SQLITE_OK){
                ///回滚
                [WDCSqliteBaseTool rollBackTransaction:db];
                [self releaseStmt:ppStmt andCloseDB:db];
                return NO;
            }
        }
    }
    ///提交事务
    [WDCSqliteBaseTool commitTransaction:db];
    
    [self releaseStmt:ppStmt andCloseDB:db];
    return YES;
}

///根据条件查询数据库记录(不传条件时查询表中所有记录)
+ (NSArray *)queryModels:(Class)cls uid:(NSString *)uid condition:(void(^)(WDCSqliteConditionMaker *maker))block{
    NSString *whereString;
    if(block){
        WDCSqliteConditionMaker *conditionMaker = [[WDCSqliteConditionMaker alloc] init];
        block(conditionMaker);
        whereString = conditionMaker.result;
    }
    return [self queryModels:cls whereStr:whereString uid:uid];
}

///根据条件字符串查询数据库记录
+ (NSArray *)queryModels:(Class)cls whereStr:(NSString *)whereStr uid:(NSString *)uid{
    NSString *tableName = [WDCModelTool tableName:cls];
    NSString *querySql = [NSString stringWithFormat:@"select * from %@", tableName];
    if(whereStr.length > 0){
        querySql = [querySql stringByAppendingFormat:@" where %@", whereStr];
    }
    NSArray<NSDictionary *> *dictArray = [WDCSqliteTool querySql:querySql withUID:uid];
    NSMutableArray *modelArray = [NSMutableArray array];
    
    NSDictionary *classIvarNameTypeDic = [WDCModelTool classIvarNameTypeDic:cls];
    for(NSDictionary *dict in dictArray){
        @autoreleasepool {
            id model = [[cls alloc] init];
            
            [classIvarNameTypeDic enumerateKeysAndObjectsUsingBlock:^(NSString *ivarName, NSString *ivarType, BOOL * _Nonnull stop) {
                id value = dict[ivarName];
                if(value != nil){
                    if([ivarType isEqualToString:@"NSArray"] || [ivarType isEqualToString:@"NSDictionary"]){
                        if([value isKindOfClass:[NSData class]]){
                            NSData *data = value;
                            ///模型中是不可变容器，解析为不可变容器
                            value = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        }else{
                            value = nil;
                        }
                    }else if ([ivarType isEqualToString:@"NSMutableArray"] || [ivarType isEqualToString:@"NSMutableDictionary"]){
                        if([value isKindOfClass:[NSData class]]){
                            NSData *data = value;
                            ///模型中是可变容器，解析为可变容器
                            value = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                        }else{
                            value = nil;
                        }
                    }else if([ivarType isEqualToString:@"NSData"]){
                        if(![value isKindOfClass:[NSData class]]){
                            value = nil;
                        }
                    }else if([ivarType isEqualToString:@"UIImage"]){
                        if ([value isKindOfClass:[NSData class]]){
                            NSData *imageData = value;
                            UIImage *image = [UIImage imageWithData:imageData];
                            value = image;
                        }else{
                            value = nil;
                        }
                    }else if([ivarType isEqualToString:@"NSDate"]){
                        if([value isKindOfClass:[NSNumber class]]){
                            NSNumber *num = value;
                            NSTimeInterval timeInterval = [num doubleValue];
                            value = [NSDate dateWithTimeIntervalSince1970:timeInterval];
                        }else{
                            value = nil;
                        }
                    }
                    [model setValue:value forKeyPath:ivarName];
                }
            }];
            if(dict[@"id"]){
                ///模型对象绑定主键
                objc_setAssociatedObject(model, @"id", dict[@"id"], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
            [modelArray addObject:model];
        }
    }
    return modelArray;
}


///根据条件删除数据库记录(不传条件时删除表中所有记录)
+ (BOOL)deleteModels:(Class)cls uid:(NSString *)uid condition:(void(^)(WDCSqliteConditionMaker *maker))block{
    NSString *whereString;
    if(block){
        WDCSqliteConditionMaker *conditionMaker = [[WDCSqliteConditionMaker alloc] init];
        block(conditionMaker);
        whereString = conditionMaker.result;
    }
    return [self deleteModels:cls whereStr:whereString uid:uid];
}

///根据条件条件字符串删除数据库记录
+ (BOOL)deleteModels:(Class)cls whereStr:(NSString *)whereStr uid:(NSString *)uid{
    
    NSString *tableName = [WDCModelTool tableName:cls];
    NSString *deleteSql = [NSString stringWithFormat:@"delete from %@", tableName];
    if(whereStr.length > 0){
        deleteSql = [deleteSql stringByAppendingFormat:@" where %@", whereStr];
    }
    return [WDCSqliteTool dealSql:deleteSql withUID:uid];
}

///从数据库中删除queryModels方法查出来的记录
+ (BOOL)deleteModels:(NSArray *)models uid:(NSString *)uid{
    
    NSMutableArray<NSString *> *sqls = [NSMutableArray array];
    for(id model in models){
        @autoreleasepool {
            ///获取模型上绑定的主键
            NSNumber *Id = objc_getAssociatedObject(model, @"id");
            if(Id){
                Class cls = [model class];
                NSString *tableName = [WDCModelTool tableName:cls];
                [sqls addObject:[NSString stringWithFormat:@"delete from %@ where id = %@", tableName, Id]];
            }else{
                return NO;
            }
        }
    }
    return [WDCSqliteTool dealSqls:sqls withUID:uid];
}

#pragma mark - 私有
///准备插入
+ (sqlite3_stmt *)insertPrepareWithClass:(Class)cls uid:(NSString *)uid columnNames:(NSArray<NSString *> *)columnNames db:(sqlite3 *)db{
    ///自动建表/自动更新失败，不插入
    if(![WDCTableTool tableCanInsert:cls uid:uid]){
        return nil;
    }
    NSString *tableName = [WDCModelTool tableName:cls];
    NSMutableArray<NSString *> *placeholderValues = [NSMutableArray array];
    for(NSInteger i = 0; i < columnNames.count; i++){
        [placeholderValues addObject:@"?"];
    }
    NSString *insertSql = [NSString stringWithFormat:@"insert into %@(%@) values (%@)", tableName, [columnNames componentsJoinedByString:@","], [placeholderValues componentsJoinedByString:@","]];

    ///创建准备语句
    sqlite3_stmt *ppStmt;
    ///预处理
    if(sqlite3_prepare(db, insertSql.UTF8String, -1, &ppStmt, nil) != SQLITE_OK){
        ///失败
        return nil;
    }
    return ppStmt;
}

///准备语句绑定并执行
+ (BOOL)ppStmt:(sqlite3_stmt *)ppStmt bindAndStepWithColumnNames:(NSArray<NSString *> *)columnNames model:(id)model{
    ///问号个数与属性个数不同，失败
    if(sqlite3_bind_parameter_count(ppStmt) != columnNames.count){
        return NO;
    }
    ///绑定
    int index = 1;
    for(NSString *columnName in columnNames){
        id value = [model valueForKeyPath:columnName];
        [self bindObject:value toIndex:index inStatement:ppStmt];
        index ++;
    }
    ///执行
    if(sqlite3_step(ppStmt) != SQLITE_DONE){
        return NO;
    }
    return YES;
}

///绑定值到准备语句
+ (void)bindObject:(id)obj toIndex:(int)idx inStatement:(sqlite3_stmt*)pStmt{
    ///空
    if ((!obj) || ((NSNull *)obj == [NSNull null])) {
        sqlite3_bind_null(pStmt, idx);
    }
    ///数字
    else if ([obj isKindOfClass:[NSNumber class]]) {
        if (strcmp([obj objCType], @encode(char)) == 0) {
            sqlite3_bind_int(pStmt, idx, [obj charValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned char)) == 0) {
            sqlite3_bind_int(pStmt, idx, [obj unsignedCharValue]);
        }
        else if (strcmp([obj objCType], @encode(short)) == 0) {
            sqlite3_bind_int(pStmt, idx, [obj shortValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned short)) == 0) {
            sqlite3_bind_int(pStmt, idx, [obj unsignedShortValue]);
        }
        else if (strcmp([obj objCType], @encode(int)) == 0) {
            sqlite3_bind_int(pStmt, idx, [obj intValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned int)) == 0) {
            sqlite3_bind_int64(pStmt, idx, (long long)[obj unsignedIntValue]);
        }
        else if (strcmp([obj objCType], @encode(long)) == 0) {
            sqlite3_bind_int64(pStmt, idx, [obj longValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned long)) == 0) {
            sqlite3_bind_int64(pStmt, idx, (long long)[obj unsignedLongValue]);
        }
        else if (strcmp([obj objCType], @encode(long long)) == 0) {
            sqlite3_bind_int64(pStmt, idx, [obj longLongValue]);
        }
        else if (strcmp([obj objCType], @encode(unsigned long long)) == 0) {
            sqlite3_bind_int64(pStmt, idx, (long long)[obj unsignedLongLongValue]);
        }
        else if (strcmp([obj objCType], @encode(float)) == 0) {
            sqlite3_bind_double(pStmt, idx, [obj floatValue]);
        }
        else if (strcmp([obj objCType], @encode(double)) == 0) {
            sqlite3_bind_double(pStmt, idx, [obj doubleValue]);
        }
        else if (strcmp([obj objCType], @encode(BOOL)) == 0) {
            sqlite3_bind_int(pStmt, idx, ([obj boolValue] ? 1 : 0));
        }
        else {
            sqlite3_bind_text(pStmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
        }
    }
    ///容器（转为data存储）
    else if([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDictionary class]]){
        NSData *data;
        @try {
            ///如果字典/数组内装的内容包含自定义类型，那么json解析，会抛出异常,data为nil
            data = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:nil];
        } @catch (NSException *exception) {
        } @finally {
        }
        if(data){
            const void *bytes = [data bytes];
            if (bytes) {
                sqlite3_bind_blob(pStmt, idx, bytes, (int)[data length], SQLITE_STATIC);
            }else{
                sqlite3_bind_null(pStmt, idx);
            }
        }else{
            sqlite3_bind_null(pStmt, idx);
        }
    }
    ///二进制
    else if ([obj isKindOfClass:[NSData class]]) {
        const void *bytes = [obj bytes];
        if (bytes) {
            sqlite3_bind_blob(pStmt, idx, bytes, (int)[obj length], SQLITE_STATIC);
        }else{
            ///没有数据的Data，比如：[NSData data]
            sqlite3_bind_null(pStmt, idx);
        }
    }
    ///图片（转为data存储）
    else if([obj isKindOfClass:[UIImage class]]){
        NSData *imageData = UIImageJPEGRepresentation(obj, 1.0f);
        const void *bytes = [imageData bytes];
        if (bytes) {
            sqlite3_bind_blob(pStmt, idx, bytes, (int)[imageData length], SQLITE_STATIC);
        }else{
            sqlite3_bind_null(pStmt, idx);
        }
    }
    ///时间
    else if ([obj isKindOfClass:[NSDate class]]) {
        sqlite3_bind_double(pStmt, idx, [obj timeIntervalSince1970]);
    }
    ///字符串
    else {
        sqlite3_bind_text(pStmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
    }
}

///释放准备语句并关闭数据库
+ (void)releaseStmt:(sqlite3_stmt *)stmt andCloseDB:(sqlite3 *)db{
    ///释放准备语句
    sqlite3_finalize(stmt);
    ///关闭数据库
    [WDCSqliteBaseTool closeDB:db];
}

@end
