//
//  WDCSqliteTool.h
//  WDRenRenTong
//
//  Created by 熊伟 on 2019/11/29.
//  Copyright © 2019 伟东人人通. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDCSqliteTool : NSObject

///处理DML语句  
+ (BOOL)dealSql:(NSString *)sql withUID:(NSString *)uid;
///处理多条DML语句
+ (BOOL)dealSqls:(NSArray<NSString *> *)sqls withUID:(NSString *)uid;
///处理DQL语句
+ (NSArray<NSDictionary *> *)querySql:(NSString *)sql withUID:(NSString *)uid;

@end
