//
//  WDCAnalysisSDK.h
//  WDRenRenTong
//
//  Created by 熊伟 on 2019/11/27.
//  Copyright © 2019 伟东人人通. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDCAnalysisSDK : NSObject

#pragma mark - 初始化
/// 设置AccessKey（由后台分配）(在didFinishLaunchingWithOptions中最先调用)
+ (void)setupAccessKey:(NSString *)accessKey;
/// 设置统计记录中的用户Id（在didFinishLaunchingWithOptions、登录获取用户Id成功时、退出登录清空用户Id时（这时setupUserId:nil）调用）
+ (void)setupUserId:(NSString *)userId;
/// 设置统计记录中的用户Id和用户地区码（在需要统计地区码的情况下使用）
+ (void)setupUserId:(NSString *)userId locationCode:(NSString *)locationCode;
/// 设置崩溃分析（在didFinishLaunchingWithOptions中调用）(调用时要确保已设置过userId)
+ (void)setupCrashAnalysis;

#pragma mark - 统计记录上传
/// 将数据库中的统计记录上传（建议在applicationWillResignActive时、退出登录时调用本方法）(调用时要确保已设置过userId)
+ (void)uploadAnalysisRecords;

#pragma mark - 页面统计
/// 设置控制器类名与页面信息的对映关系。key：控制器类名 value：页面Id、页面名称 例如: @{@"HomeViewController": @{@"pageName": @"首页", @"pageId": @"rrtApp.homeModule.homePage"}} (未设置对映关系的控制器不会被统计，只需设置想统计的页面)(在didFinishLaunchingWithOptions中调用)
+ (void)setupMapForClassNameAndPageInfo:(NSDictionary *)map;

/// 进入某个页面(有时候会有单个控制器类名对应多个页面的情况，设置对映关系无法进行区分。如果想要进行区分，调用这两个方法进行页面统计。注：调用这两个方法进行统计的页面,就不能设置映射关系了，否则会统计两次)
+ (void)enterPageWithPageId:(NSString *)pageId pageName:(NSString *)pageName;
/// 离开某个页面
+ (void)leavePageWithPageId:(NSString *)pageId;


#pragma mark - 自定义事件统计
/// 添加瞬时事件（非实时）
+ (void)trackCustomEventWithEventId:(NSString *)eventId eventName:(NSString *)eventName;
/// 添加瞬时事件 (非实时、props设置自定义属性)
+ (void)trackCustomEventWithEventId:(NSString *)eventId eventName:(NSString *)eventName props:(NSDictionary *)props;
/// 添加瞬时事件（isRealTime设置是否实时上传）
+ (void)trackCustomEventWithEventId:(NSString *)eventId eventName:(NSString *)eventName isRealTime:(BOOL)isRealTime;
/// 添加瞬时事件（props设置自定义属性、isRealTime设置是否实时上传）
+ (void)trackCustomEventWithEventId:(NSString *)eventId eventName:(NSString *)eventName props:(NSDictionary *)props isRealTime:(BOOL)isRealTime;


/// 持续事件开始
+ (void)trackCustomEventBeginWithEventId:(NSString *)eventId eventName:(NSString *)eventName;
/// 持续事件结束
+ (void)trackCustomEventEndWithEventId:(NSString *)eventId;

#pragma mark - 其他
///设置调试模式（默认是NO）
+ (void)setupDebug:(BOOL)isDebug;
///设置上传记录失败回调（可用于捕获上传记录失败的情况）
+ (void)setupUploadRecordsFailure:(void(^)(NSDictionary *failureInfo))uploadRecordsFailure;

@end
