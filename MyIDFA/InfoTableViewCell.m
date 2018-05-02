//
//  InfoTableViewCell.m
//  MyIDFA
//
//  Created by SuGuocai on 2018/4/22.
//  Copyright © 2018年 魔方. All rights reserved.
//

#import "InfoTableViewCell.h"


@interface InfoTableViewCell ()

@end

@implementation InfoTableViewCell

- (IBAction)copy:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = _subTitleLabel.text;
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"Copied to your clipboard"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alter show];
}

@end
