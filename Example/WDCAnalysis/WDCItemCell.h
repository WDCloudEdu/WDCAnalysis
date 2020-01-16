//
//  WDCItemCell.h
//  WDCAnalysis_Example
//
//  Created by 熊伟 on 2019/12/23.
//  Copyright © 2019 xiongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WDCItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *itemTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemSubTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemTimeLabel;

@end

