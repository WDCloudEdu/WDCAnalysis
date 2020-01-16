//
//  WDCItem.h
//  WDCAnalysis_Example
//
//  Created by 熊伟 on 2019/12/23.
//  Copyright © 2019 xiongwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDCItem : NSObject

@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, copy) NSString *itemTitle;
@property (nonatomic, copy) NSString *itemSubTitle;
@property (nonatomic, copy) NSString *itemContent;
@property (nonatomic, assign) NSTimeInterval itemTime;

@property (nonatomic, copy, readonly) NSString *itemTimeDesc;

@end
