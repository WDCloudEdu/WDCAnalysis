# WDCAnalysis

[![CI Status](https://img.shields.io/travis/xiongwei/WDCAnalysis.svg?style=flat)](https://travis-ci.org/xiongwei/WDCAnalysis)
[![Version](https://img.shields.io/cocoapods/v/WDCAnalysis.svg?style=flat)](https://cocoapods.org/pods/WDCAnalysis)
[![License](https://img.shields.io/cocoapods/l/WDCAnalysis.svg?style=flat)](https://cocoapods.org/pods/WDCAnalysis)
[![Platform](https://img.shields.io/cocoapods/p/WDCAnalysis.svg?style=flat)](https://cocoapods.org/pods/WDCAnalysis)

# 伟东云统计SDK使用说明

> `tips:所有的接口在WDCAnalysisSDK.h文件中。`

## 一.sdk初始化
在`application:didFinishLaunchingWithOptions:`方法中进行初始化
* 1.设置debug模式（统计记录不上传服务器、打印日志。release环境需去除。）
* 2.设置userId (统计记录的userId，如果不用统计userId可以不设置。如果除了userId外还需要统计locationCode，可以调用`setupUserId:locationCode:`方法设置)
* 3.页面统计初始化（不用页面统计可以不设置）
* 4.崩溃统计初始化（不用崩溃统计可以不设置）

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    // Override point for customization after application launch.
    [self setupAnalysis];
    return YES;
}

/// 统计sdk设置
- (void)setupAnalysis{
    /// 设置为调试模式（统计记录不上传服务器，打印日志）
//    [WDCAnalysisSDK setupDebug:YES];
    
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
```

## 二.关于设置userId
设置的userId为统计记录的userId属性。
建议调用时机：
* 1.sdk初始化时
* 2.登录成功（获取到了新userId）时
* 3.退出登录（清空userId，setupUserId:nil）时

## 三.关于上传统计记录
本sdk默认每3分钟进行一次统计记录上传，调用`uploadAnalysisRecords`方法可以立刻上传本地存储的统计记录到服务器。
为了让统计记录的上传更加及时，建议调用时机：
* 1.`applicationWillResignActive:`方法
* 2.退出登录时

```objc
- (void)applicationWillResignActive:(UIApplication *)application{    
    /// 建议应用程序挂起前上传一下统计记录
    [WDCAnalysisSDK uploadAnalysisRecords];
}
```

## 四.页面统计
#### 1.自动统计
本sdk自动在每个UIViewController对象出现和消失时进行页面统计记录的处理。
然而只能自动获取到是哪个UIViewController对象出现/消失，至于这个UIViewController对象生成的页面统计记录中的pageId、pageName叫什么，需要调用者来告知。
`setupMapForClassNameAndPageInfo:`方法用来设置UIViewController类名与pageId、pageName的映射关系。

> `tips:没有在映射关系中设置的UIViewController不会进行自动统计。`

```objc
    /// 设置页面统计的UIViewController类名与pageId、pageName的对应关系
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
```

#### 2.手动统计
有时候会有单个UIViewController类对应多个页面的情况，自动统计无法进行区分，可以使用手动统计。在进入页面和离开页面时调用以下两个方法。

```objc
/// 进入某个页面
+ (void)enterPageWithPageId:(NSString *)pageId pageName:(NSString *)pageName;
/// 离开某个页面
+ (void)leavePageWithPageId:(NSString *)pageId;
```

> `tips:手动统计的页面就不能设置自动统计的映射关系了，否则会统计两次，生成两条统计记录`


> `tips:建议能使用自动统计的情况都使用自动统计，手动统计代码量比较大，万不得已才使用`

下面是一个UIViewController使用手动统计的示例：

```objc
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAnalysis];
}
- (void)setupAnalysis{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
///注：当一个控制器对应多个界面的情况下,使用这种方式的页面统计可以进行区分(对映关系里面就不能再设置这个控制器了，否则会重复统计)
///注：如果不是万不得已，最好使用设置对映关系的方式进行页面统计。这种方式建议只用于处理个别特例。
static NSString *const pageId = @"WDCAnalysisExample.home.itemDetail";
static NSString *const pageName = @"Item详情";
static NSString *const pageId1 = @"WDCAnalysisExample.home.itemDetailNew";
static NSString *const pageName1 = @"Item详情New";
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(1){
        [WDCAnalysisSDK enterPageWithPageId:pageId pageName:pageName];
    }else{
        [WDCAnalysisSDK enterPageWithPageId:pageId1 pageName:pageName1];
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(1){
        [WDCAnalysisSDK leavePageWithPageId:pageId];
    }else{
        [WDCAnalysisSDK leavePageWithPageId:pageId1];
    }
}
- (void)applicationDidBecomeActive:(UIApplication *)application{
    if(1){
        [WDCAnalysisSDK enterPageWithPageId:pageId pageName:pageName];
    }else{
        [WDCAnalysisSDK enterPageWithPageId:pageId1 pageName:pageName1];
    }
}
- (void)applicationWillResignActive:(UIApplication *)application{
    if(1){
        [WDCAnalysisSDK leavePageWithPageId:pageId];
    }else{
        [WDCAnalysisSDK leavePageWithPageId:pageId1];
    }
}
```

## 五.自定义事件统计
#### 1.瞬时事件
当一个事件发生时，我们可以生成一条自定义事件统计记录。这个事件可以是任意你想统计的业务。
你需要设置事件的eventId和eventName。
事件可以附带一个props字典来存储一些相关属性。
设置isRealTime为YES的话该事件就是一个实时事件，实时事件的统计记录会即时上传到服务器。

```objc
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.enterItem = self.itemArray[indexPath.row];
    [self performSegueWithIdentifier:@"itemListToItemDetail" sender:nil];
    
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    props[@"itemTitle"] = self.enterItem.itemTitle;
    props[@"itemId"] = self.enterItem.itemId;
    [WDCAnalysisSDK trackCustomEventWithEventId:@"WDCAnalysisExample.home.clickItemList" eventName:@"点击item列表" props:props isRealTime:YES];
}
```

#### 2.持续事件
有时我们想统计一些持续性的事件。在事件开始时调用`trackCustomEventBeginWithEventId:eventName:`方法，在事件结束时`trackCustomEventEndWithEventId:`方法。
可以统计到事件发生的时长。

```objc
- (void)applicationDidBecomeActive:(UIApplication *)application{
    [WDCAnalysisSDK trackCustomEventBeginWithEventId:kDurationOfUseEventId eventName:@"使用时长统计"];
}
- (void)applicationWillResignActive:(UIApplication *)application{
    [WDCAnalysisSDK trackCustomEventEndWithEventId:kDurationOfUseEventId];
}
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

WDCAnalysis is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'WDCAnalysis'
```

## Author

xiongwei, xiongwei@wdcloud.cc

## License

WDCAnalysis is available under the MIT license. See the LICENSE file for more info.
