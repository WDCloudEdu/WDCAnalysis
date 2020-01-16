//
//  WDCTableTool.h
//  WDRenRenTong
//
//  Created by 熊伟 on 2019/12/2.
//  Copyright © 2019 伟东人人通. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDCTableTool : NSObject

///判断cls对应的表是否能插入数据（对表做一些前置准备）
+ (BOOL)tableCanInsert:(Class)cls uid:(NSString *)uid;

@end
