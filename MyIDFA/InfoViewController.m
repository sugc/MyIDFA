//
//  InfoViewController.m
//  MyIDFA
//
//  Created by SuGuocai on 2018/4/22.
//  Copyright © 2018年 魔方. All rights reserved.
//

#import "InfoViewController.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "MacAddressManager.h"

@interface InfoViewController()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addGesture];
    [self getAllInfo];
}

- (void)addGesture {
    UISwipeGestureRecognizer *rRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    rRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    UISwipeGestureRecognizer *lRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    lRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.view addGestureRecognizer:rRecognizer];
    [self.view addGestureRecognizer:lRecognizer];
}

- (void)swipe:(UISwipeGestureRecognizer *)recognizer {
    
    if (recognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    [self backWithDreiction:recognizer.direction];
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:@"InfoTableViewCell"];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 80;
}

- (IBAction)actionBack:(id)sender {
    [self backWithDreiction:UISwipeGestureRecognizerDirectionRight];
}

- (void)backWithDreiction:(UISwipeGestureRecognizerDirection)direction {
    
    if (direction != UISwipeGestureRecognizerDirectionRight &&
        direction != UISwipeGestureRecognizerDirectionLeft) {
        return;
    }
    
    NSString *subType = direction == UISwipeGestureRecognizerDirectionRight ? kCATransitionFromLeft : kCATransitionFromRight;
    CATransition *animation = [CATransition animation];
    animation.duration = 0.6;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = @"cube";
    animation.subtype = subType;
    [self.view.window.layer addAnimation:animation forKey:nil];
    [self dismissViewControllerAnimated:NO completion:nil];
}

//获取所有信息
- (void)getAllInfo {
    NSString *ipv4 = [self getIPAddress];
    NSString *macAddr = [MacAddressManager getMacAddressFromMDNS];
    
    NSLog(@"ip is...");
}

- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    success = getifaddrs(&interfaces);
    
    if (success == 0) {
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if (temp_addr->ifa_addr->sa_family == AF_INET) {
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // 得到NSString从C字符串
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return address;
}


@end
