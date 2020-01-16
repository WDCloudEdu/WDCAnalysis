//
//  WDCItemListViewController.m
//  WDCAnalysis_Example
//
//  Created by 熊伟 on 2019/12/23.
//  Copyright © 2019 xiongwei. All rights reserved.
//

#import "WDCItemListViewController.h"
#import "WDCItem.h"
#import "WDCItemCell.h"
#import "WDCItemDetailViewController.h"
#import "WDCAnalysisSDK.h"

static NSString *const itemCellId = @"WDCItemCell";
@interface WDCItemListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray<WDCItem *> *itemArray;
@property (nonatomic, strong) WDCItem *enterItem;


@end

@implementation WDCItemListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createItems];
}

#pragma mark - <UITableViewDataSource, UITableViewDelegate>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.itemArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WDCItemCell *cell = [tableView dequeueReusableCellWithIdentifier:itemCellId];
    [self bindEntity:self.itemArray[indexPath.row] toCell:cell];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.enterItem = self.itemArray[indexPath.row];
    [self performSegueWithIdentifier:@"itemListToItemDetail" sender:nil];
    
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    props[@"itemTitle"] = self.enterItem.itemTitle;
    props[@"itemId"] = self.enterItem.itemId;
    [WDCAnalysisSDK trackCustomEventWithEventId:@"WDCAnalysisExample.home.clickItemList" eventName:@"点击item列表" props:props];
}

#pragma mark - 其他
- (NSMutableArray<WDCItem *> *)itemArray{
    if(_itemArray == nil){
        _itemArray = [NSMutableArray array];
    }
    return _itemArray;
}

- (void)createItems{
    for(NSInteger i = 1; i < 100; i++){
        WDCItem *item = [[WDCItem alloc] init];
        item.itemTitle = [NSString stringWithFormat:@"这是标题%zd",i];
        item.itemSubTitle = [NSString stringWithFormat:@"这是子标题%zd",i];
        item.itemContent = [NSString stringWithFormat:@"这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容这是内容%zd",i];
        item.itemTime = [[NSDate date] timeIntervalSince1970] - 1000*i;
        item.itemId = [NSString stringWithFormat:@"%08zd",i];
        [self.itemArray addObject:item];
    }
}

- (void)bindEntity:(WDCItem *)item toCell:(WDCItemCell *)cell{
    cell.itemTitleLabel.text = item.itemTitle;
    cell.itemSubTitleLabel.text = item.itemSubTitle;
    cell.itemTimeLabel.text = item.itemTimeDesc;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"itemListToItemDetail"] && [segue.destinationViewController isKindOfClass:[WDCItemDetailViewController class]]){
        WDCItemDetailViewController *detailVC = segue.destinationViewController;
        detailVC.item = self.enterItem;
    }
}

@end
