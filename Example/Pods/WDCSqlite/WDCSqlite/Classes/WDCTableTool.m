//
//  WDCTableTool.m
//  WDRenRenTong
//
//  Created by 熊伟 on 2019/12/2.
//  Copyright © 2019 伟东人人通. All rights reserved.
//

#import "WDCTableTool.h"
#import "WDCModelTool.h"
#import "WDCSqliteTool.h"
#import "WDCModelProtocol.h"

@implementation WDCTableTool

#pragma mark - 接口
///判断cls对应的表是否能插入数据（对表做一些前置准备）
+ (BOOL)tableCanInsert:(Class)cls uid:(NSString *)uid{
    ///如果表不存在，自动建表
    if(![self isTableExists:cls uid:uid]){
        BOOL createRes = [self createTable:cls uid:uid];
        if(createRes == NO){
            return NO;
        }
    }
    ///如果表需要更新，自动更新
    if([self isTableRequireUpdate:cls uid:uid]){
        BOOL updateRes = [self updateTable:cls uid:uid];
        if(updateRes == NO){
            return NO;
        }
    }
    return YES;
}

#pragma mark - 私有
///判断类名对应的表是否存在
+ (BOOL)isTableExists:(Class)cls uid:(NSString *)uid{
    
    NSString *tableName = [WDCModelTool tableName:cls];
    
    NSString *tableInfoSql = [NSString stringWithFormat:@"select * from sqlite_master where type = 'table' and name = '%@'", tableName];
    NSArray<NSDictionary *> *tableInfoArray = [WDCSqliteTool querySql:tableInfoSql withUID:uid];
    return tableInfoArray.count > 0;
}

///根据类名在uid对应的数据库中创建表
+ (BOOL)createTable:(Class)cls uid:(NSString *)uid{
    
    ///拼接创建表格的sql语句
    ///使用某成员变量作为主键的sql:create table if not exists 表名(字段1 字段1类型, 字段2 字段2类型(约束), ..., primary key(字段))
    
    ///获取表名
    NSString *tableName = [WDCModelTool tableName:cls];
    
    ///获取字段、类型字符串
    NSString *columnNamesAndTypesStr = [WDCModelTool columnNamesAndTypesStr:cls];
    
    ///自动生成id主键，不想让外界关心主键
    NSString *createTableSql = [NSString stringWithFormat:@"create table if not exists %@(id integer primary key autoincrement,%@)",tableName, columnNamesAndTypesStr];
    
    ///执行sql语句
    return [WDCSqliteTool dealSql:createTableSql withUID:uid];
}

///判断类名对应的表是否需要更新（字段发生变化）
+ (BOOL)isTableRequireUpdate:(Class)cls uid:(NSString *)uid{
    ///获取类对应的字段列表
    NSArray<NSString *> *modelColumns = [WDCModelTool tableSortedColumnNames:cls];
    ///获取已存在表对应的字段列表
    NSArray<NSString *> *tableColumns = [self tableSortedColumnNames:cls uid:uid];
    ///如果两个字段列表不同，那么需要更新
    return ![modelColumns isEqual:tableColumns];
}

///更新类名对应的表
+ (BOOL)updateTable:(Class)cls uid:(NSString *)uid{
    
    ///一系列的步骤需要放到事务中
    NSMutableArray<NSString *> *sqls = [NSMutableArray array];
    
    NSString *tableName = [WDCModelTool tableName:cls];
    ///按新字段创建一个临时表
    NSString *tmpTableName = [WDCModelTool tmpTableName:cls];
    NSString *columnNamesAndTypesStr = [WDCModelTool columnNamesAndTypesStr:cls];
    NSString *createTableSql = [NSString stringWithFormat:@"create table if not exists %@(id integer primary key autoincrement,%@)", tmpTableName, columnNamesAndTypesStr];
    [sqls addObject:createTableSql];
    
    ///将旧表中的主键插入临时表
    NSString *insertPrimaryKeySql = [NSString stringWithFormat:@"insert into %@(id) select id from %@", tmpTableName, tableName];
    [sqls addObject:insertPrimaryKeySql];
    
    ///根据主键，把其他字段更新到临时表
    NSArray<NSString *> *oldNames = [self tableSortedColumnNames:cls uid:uid];
    NSArray<NSString *> *newNames = [WDCModelTool tableSortedColumnNames:cls];
    
    NSDictionary *newNameToOldNameDic;
    if([cls respondsToSelector:@selector(newNameToOldNameDic)]){
        newNameToOldNameDic = [cls newNameToOldNameDic];
    }
    
    for(NSString *columnName in newNames){
        ///新表中columnName字段对映旧表中的字段（默认是同名的字段）
        NSString *oldName = columnName;
        ///如果设置了对映关系，以对映关系为准
        if(newNameToOldNameDic && newNameToOldNameDic[columnName]){
            oldName = newNameToOldNameDic[columnName];
        }
        ///旧表中没有对映字段，不更新数据
        if(![oldNames containsObject:oldName]){
            continue;
        }
        ///旧表中有对映字段，更新数据
        NSString *updateSql = [NSString stringWithFormat:@"update %@ set %@ = (select %@ from %@ where %@.id = %@.id)", tmpTableName, columnName, oldName, tableName, tableName, tmpTableName];
        [sqls addObject:updateSql];
    }
    
    ///删除旧表
    NSString *deleteOldTableSql = [NSString stringWithFormat:@"drop table if exists %@", tableName];
    [sqls addObject:deleteOldTableSql];
    
    ///将临时表改名为新表
    NSString *renameTableNameSql = [NSString stringWithFormat:@"alter table %@ rename to %@", tmpTableName, tableName];
    [sqls addObject:renameTableNameSql];
    
    return [WDCSqliteTool dealSqls:sqls withUID:uid];
}

///获取已存在的cls表中所有的字段(如果表还不存在，返回nil)
+ (NSArray<NSString *> *)tableSortedColumnNames:(Class)cls uid:(NSString *)uid{
    NSString *tableName = [WDCModelTool tableName:cls];
    
    ///创建sql语句来查询sqlite_master表中cls表建表的sql语句(从而获取表中的字段)
    NSString *queryCreateSqlStr = [NSString stringWithFormat:@"select sql from sqlite_master where type = 'table' and name = '%@'", tableName];
    
    NSDictionary *dic = [WDCSqliteTool querySql:queryCreateSqlStr withUID:uid].firstObject;
    ///cls表建表的sql
    NSString *createTableSql = dic[@"sql"];
    ///cls表还没有建表
    if(createTableSql.length == 0){
        return nil;
    }
    
    ///CREATE TABLE WDCAnalysisRecord(id integer primary key autoincrement, pageName text,isRealTime integer,prefixPageId text,pageId text,longitude real,time real,latitude real,type text,eventId text,extraProperties text,eventName text,netState text,prefixPageName text,duration real)
    
    ///容错处理，去除sql中可能存在的\"、\n、\t符号（一般情况下也不会出现）
    createTableSql = [createTableSql stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    createTableSql = [createTableSql stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    createTableSql = [createTableSql stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    
    ///获取所有字段
    NSArray *cmp = [createTableSql componentsSeparatedByString:@"("];
    ///sql的格式超出预料，无法处理
    if(cmp.count < 2){
        return nil;
    }
    ///id integer primary key autoincrement, pageName text,isRealTime integer,prefixPageId text,pageId text,longitude real,time real,latitude real,type text,eventId text,extraProperties text,eventName text,netState text,prefixPageName text,duration real)
    NSString *nameTypesStr = cmp[1];
    NSArray *nameTypeArray = [nameTypesStr componentsSeparatedByString:@","];
    NSMutableArray<NSString *> *columnNames = [NSMutableArray array];
    for(NSString *nameType in nameTypeArray){
        ///主键不计
        if([nameType containsString:@"primary key"]){
            continue;
        }
        ///去除nameType字符串两端可能有的空格和最后一个nameType字符串右边的右括号（如" pageName text", "duration real)"）
        NSString *nameType2 = [nameType stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@") "]];
        ///获取字段名
        NSString *name = [nameType2 componentsSeparatedByString:@" "].firstObject;
        [columnNames addObject:name];
    }
    [columnNames sortUsingComparator:^NSComparisonResult(id  _Nonnull columnName1, id  _Nonnull columnName2) {
        return [columnName1 compare:columnName2];
    }];
    return columnNames;
}

@end
