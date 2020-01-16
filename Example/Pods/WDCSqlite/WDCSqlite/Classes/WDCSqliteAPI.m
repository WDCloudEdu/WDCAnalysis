//
//  WDCSqliteAPI.m
//  WDRenRenTong
//
//  Created by 熊伟 on 2019/12/3.
//  Copyright © 2019 伟东人人通. All rights reserved.
//

#import "WDCSqliteAPI.h"
#import "WDCSqliteModelTool.h"

@implementation WDCSqliteAPI

///由于WDCSqliteTool内部使用同一个句柄_ppDb操作数据库，所以本层使用串行队列来确保线程安全。
static dispatch_queue_t _sqliteQueue;
+ (void)load {
    _sqliteQueue = dispatch_queue_create("com.xw.sqlite.queue", DISPATCH_QUEUE_SERIAL);
}

///插入模型到数据库
+ (void)insertModel:(id)model uid:(NSString *)uid completionHandler:(void(^)(BOOL res))completionHandler{
    dispatch_async(_sqliteQueue, ^{
        BOOL res = [WDCSqliteModelTool insertModel:model uid:uid];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completionHandler){
                completionHandler(res);
            }
        });
    });
}

///批量插入模型到数据库(注：models中的对象，类必须相同)
+ (void)insertModels:(NSArray *)models uid:(NSString *)uid completionHandler:(void(^)(BOOL res))completionHandler{
    dispatch_async(_sqliteQueue, ^{
        BOOL res = [WDCSqliteModelTool insertModels:models uid:uid];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completionHandler){
                completionHandler(res);
            }
        });
    });
}

///根据条件查询数据库记录(不传条件时查询表中所有记录)
+ (void)queryModels:(Class)cls uid:(NSString *)uid condition:(void(^)(WDCSqliteConditionMaker *maker))block completionHandler:(void(^)(NSArray *models))completionHandler{
    dispatch_async(_sqliteQueue, ^{
        NSArray *models = [WDCSqliteModelTool queryModels:cls uid:uid condition:block];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completionHandler){
                completionHandler(models);
            }
        });
    });
}

///根据条件字符串查询数据库记录
+ (void)queryModels:(Class)cls whereStr:(NSString *)whereStr uid:(NSString *)uid completionHandler:(void(^)(NSArray *models))completionHandler{
    dispatch_async(_sqliteQueue, ^{
        NSArray *models = [WDCSqliteModelTool queryModels:cls whereStr:whereStr uid:uid];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completionHandler){
                completionHandler(models);
            }
        });
    });
}

///根据条件删除数据库记录(不传条件时删除表中所有记录)
+ (void)deleteModels:(Class)cls uid:(NSString *)uid condition:(void(^)(WDCSqliteConditionMaker *maker))block completionHandler:(void(^)(BOOL res))completionHandler{
    dispatch_async(_sqliteQueue, ^{
        BOOL res = [WDCSqliteModelTool deleteModels:cls uid:uid condition:block];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completionHandler){
                completionHandler(res);
            }
        });
    });
}

///根据条件条件字符串删除数据库记录
+ (void)deleteModels:(Class)cls whereStr:(NSString *)whereStr uid:(NSString *)uid completionHandler:(void(^)(BOOL res))completionHandler{
    dispatch_async(_sqliteQueue, ^{
        BOOL res = [WDCSqliteModelTool deleteModels:cls whereStr:whereStr uid:uid];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completionHandler){
                completionHandler(res);
            }
        });
    });
}
///从数据库中删除queryModels方法查出来的记录
+ (void)deleteModels:(NSArray *)models uid:(NSString *)uid completionHandler:(void(^)(BOOL res))completionHandler{
    dispatch_async(_sqliteQueue, ^{
        BOOL res = [WDCSqliteModelTool deleteModels:models uid:uid];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completionHandler){
                completionHandler(res);
            }
        });
    });
}

@end
