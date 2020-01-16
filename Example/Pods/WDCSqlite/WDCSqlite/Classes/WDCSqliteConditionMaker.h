//
//  WDCSqliteConditionMaker.h
//  Pods-WDCSqlite_Example
//
//  Created by 熊伟 on 2019/12/19.
//

#import <Foundation/Foundation.h>

@interface WDCSqliteConditionMaker : NSObject

/// 构造的sql条件字符串
@property (nonatomic, copy, readonly) NSString *result;

/// 开始构造一个子条件（子条件间是"或"的关系, orderBy、limit除外）
- (WDCSqliteConditionMaker *)begin;
/// "与"
- (WDCSqliteConditionMaker *)and;
/// 结束构造一个子条件 (注：每个子条件构造结束后一定要调用end())
@property (nonatomic, copy, readonly) void(^end)(void);

/// 属性名
@property (nonatomic, copy, readonly) WDCSqliteConditionMaker *(^prop)(NSString *propName);
/// 等于(value传NSNumber或NSString)
@property (nonatomic, copy, readonly) WDCSqliteConditionMaker *(^equalTo)(id value);
/// 小于
@property (nonatomic, copy, readonly) WDCSqliteConditionMaker *(^lessThan)(NSNumber *value);
/// 小于或等于
@property (nonatomic, copy, readonly) WDCSqliteConditionMaker *(^lessOrEqualTo)(NSNumber *value);
/// 大于
@property (nonatomic, copy, readonly) WDCSqliteConditionMaker *(^moreThan)(NSNumber *value);
/// 大于或等于
@property (nonatomic, copy, readonly) WDCSqliteConditionMaker *(^moreOrEqualTo)(NSNumber *value);

/// 排序
@property (nonatomic, copy, readonly) WDCSqliteConditionMaker *(^orderBy)(NSString *propName, BOOL isAsc);

/// 限制
@property (nonatomic, copy, readonly) WDCSqliteConditionMaker *(^limit)(NSInteger ignoreCount, NSInteger count);
@end
