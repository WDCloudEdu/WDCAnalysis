//
//  WDCItem.m
//  WDCAnalysis_Example
//
//  Created by 熊伟 on 2019/12/23.
//  Copyright © 2019 xiongwei. All rights reserved.
//

#import "WDCItem.h"

@implementation WDCItem

- (void)setItemTime:(NSTimeInterval)itemTime{
    _itemTime = itemTime;
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy.MM.dd hh:mm";
    _itemTimeDesc = [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:itemTime]];
}

@end
