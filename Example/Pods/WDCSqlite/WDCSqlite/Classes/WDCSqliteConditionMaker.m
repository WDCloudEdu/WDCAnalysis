//
//  WDCSqliteConditionMaker.m
//  Pods-WDCSqlite_Example
//
//  Created by 熊伟 on 2019/12/19.
//

#import "WDCSqliteConditionMaker.h"

@interface WDCSqliteConditionMaker ()

/// 条件数组(数组中的条件是"或"的关系)
@property (nonatomic, strong) NSMutableArray<NSMutableString *> *conditions;

/// 当前正在拼接的条件
@property (nonatomic, strong) NSMutableString *currentCondition;

@end

@implementation WDCSqliteConditionMaker

#pragma mark - 接口

- (NSString *)result{
    if(self.conditions.count == 0){
        return nil;
    }
    
    ///'或'关系的子条件
    NSMutableArray *orConditions = [NSMutableArray array];
    ///特殊条件
    NSMutableArray *otherConditions = [NSMutableArray array];
    for(NSMutableString *condition in self.conditions){
        if(([condition containsString:@"order by"] || [condition containsString:@"limit"]) && ![condition containsString:@"'"]){
            ///去除特殊条件两端的括号
            [otherConditions addObject:[condition stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"()"]]];
        }else{
            [orConditions addObject:condition];
        }
    }
    
    NSMutableString *res = [[orConditions componentsJoinedByString:@" or "] mutableCopy];
    for(NSMutableString *condition in otherConditions){
        [res appendString:condition];
    }
    return res;
}


- (WDCSqliteConditionMaker *)begin{
    ///重置当前正在拼接的条件
    self.currentCondition = [NSMutableString stringWithString:@"("];
    return self;
}

- (WDCSqliteConditionMaker *)and{
    [self.currentCondition appendString:@" and "];
    return self;
}

- (void (^)(void))end{
    return ^{
        [self.currentCondition appendString:@")"];
        [self.conditions addObject:self.currentCondition];
        self.currentCondition = nil;
    };
}

- (WDCSqliteConditionMaker *(^)(NSString *))prop{
    return ^(NSString *propName){
        [self.currentCondition appendString:propName];
        return self;
    };
}

- (WDCSqliteConditionMaker *(^)(id))equalTo{
    return ^(id value){
        if([value isKindOfClass:[NSNumber class]]){
            [self.currentCondition appendFormat:@" = %@", value];
        }else if ([value isKindOfClass:[NSString class]]){
            if([(NSString *)value containsString:@"'"]){
                value = [(NSString *)value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            }
            [self.currentCondition appendFormat:@" = '%@'", value];
        }
        return self;
    };
}

- (WDCSqliteConditionMaker *(^)(NSNumber *))lessThan{
    return [self compareBlockWithSymbol:@"<"];
}

- (WDCSqliteConditionMaker *(^)(NSNumber *))lessOrEqualTo{
    return [self compareBlockWithSymbol:@"<="];
}

- (WDCSqliteConditionMaker *(^)(NSNumber *))moreThan{
    return [self compareBlockWithSymbol:@">"];
}

- (WDCSqliteConditionMaker *(^)(NSNumber *))moreOrEqualTo{
    return [self compareBlockWithSymbol:@">="];
}

- (WDCSqliteConditionMaker *(^)(NSString *, BOOL))orderBy{
    return ^(NSString *propName, BOOL isAsc){
        [self.currentCondition appendFormat:@" order by %@ %@", propName, isAsc?@"asc":@"desc"];
        return self;
    };
}

- (WDCSqliteConditionMaker *(^)(NSInteger, NSInteger))limit{
    return ^(NSInteger ignoreCount, NSInteger count){
        [self.currentCondition appendFormat:@" limit %zd, %zd", ignoreCount, count];
        return self;
    };
}

#pragma mark - 私有

- (NSMutableArray<NSMutableString *> *)conditions{
    if(_conditions == nil){
        _conditions = [NSMutableArray array];
    }
    return _conditions;
}

- (NSMutableString *)currentCondition{
    if(_currentCondition == nil){
        _currentCondition = [NSMutableString string];
    }
    return _currentCondition;
}

- (WDCSqliteConditionMaker *(^)(NSNumber *))compareBlockWithSymbol:(NSString *)symbol{
    return ^(NSNumber *value){
        if([value isKindOfClass:[NSNumber class]]){
            [self.currentCondition appendFormat:@" %@ %@", symbol, value];
        }
        return self;
    };
}
@end
