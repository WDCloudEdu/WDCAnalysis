//
//  WDCAppDelegate.m
//  WDCAnalysis
//
//  Created by xiongwei on 12/20/2019.
//  Copyright (c) 2019 xiongwei. All rights reserved.
//

#import "WDCAppDelegate.h"
#import "WDCAnalysisSDK.h"
#import "WDCUser.h"

/// 使用时长统计事件id
static NSString *const kDurationOfUseEventId = @"WDCAnalysisExample.common.durationOfUse";
@implementation WDCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    // Override point for customization after application launch.
    
    [self setupAnalysis];
    return YES;
}

/// 统计sdk设置
- (void)setupAnalysis{
    /// 设置为调试模式（统计记录不上传服务器，打印日志）
    [WDCAnalysisSDK setupDebug:YES];
    
    /// 设置你的accessKey
    [WDCAnalysisSDK setupAccessKey:@""];
    /// 设置userId （统计记录/崩溃记录的userId）
    [WDCAnalysisSDK setupUserId:[WDCUser sharedUser].userId];
    /// 设置页面统计的控制器类名与页面名称、页面Id的对应关系
    [WDCAnalysisSDK setupMapForClassNameAndPageInfo:@{
                                                      @"WDCHomeViewController": @{
                                                              @"pageId": @"WDCAnalysisExample.home.homePage",
                                                              @"pageName": @"首页",
                                                              },
                                                      @"WDCItemListViewController": @{
                                                              @"pageId": @"WDCAnalysisExample.home.itemList",
                                                              @"pageName": @"Item列表",
                                                              },
//                                                      @"WDCItemDetailViewController": @{
//                                                              @"pageId": @"WDCAnalysisExample.home.itemDetail",
//                                                              @"pageName": @"Item详情",
//                                                              },
                                                      }];
    /// 崩溃统计初始化
    [WDCAnalysisSDK setupCrashAnalysis];
}


- (void)applicationWillResignActive:(UIApplication *)application{
    [WDCAnalysisSDK trackCustomEventEndWithEventId:kDurationOfUseEventId];
    
    /// 建议应用程序挂起前上传一下统计记录
    [WDCAnalysisSDK uploadAnalysisRecords];
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    
    [WDCAnalysisSDK trackCustomEventBeginWithEventId:kDurationOfUseEventId eventName:@"使用时长统计"];
}

@end
