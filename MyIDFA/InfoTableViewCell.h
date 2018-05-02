//
//  InfoTableViewCell.h
//  MyIDFA
//
//  Created by SuGuocai on 2018/4/22.
//  Copyright © 2018年 魔方. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface InfoTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *subTitleLabel;
@property (nonatomic, weak) IBOutlet UIButton *copybutton;

@end
