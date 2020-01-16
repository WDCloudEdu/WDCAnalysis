//
//  WDCItemDetailViewController.m
//  WDCAnalysis_Example
//
//  Created by 熊伟 on 2019/12/23.
//  Copyright © 2019 xiongwei. All rights reserved.
//

#import "WDCItemDetailViewController.h"
#import "WDCAnalysisSDK.h"

@interface WDCItemDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *itemTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemSubTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemTimeLabel;

@end

@implementation WDCItemDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupItem];
    [self setupAnalysis];
}

- (void)setupItem{
    self.itemTitleLabel.text = self.item.itemTitle;
    self.itemSubTitleLabel.text = self.item.itemSubTitle;
    self.itemContentLabel.text = self.item.itemContent;
    self.itemTimeLabel.text = self.item.itemTimeDesc;
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

@end
