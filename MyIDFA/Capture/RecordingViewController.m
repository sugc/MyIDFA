//
//  RecordingViewController.m
//  MyIDFA
//
//  Created by sugc on 2019/6/15.
//  Copyright © 2019 魔方. All rights reserved.
//

#import "RecordingViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
//#import <ReplayKit/ReplayKit.h>
#import <objc/runtime.h>
#import <objc/message.h>

@class RPSystemBroadcastPickerView;

@interface RecordingViewController ()<GADBannerViewDelegate>

@property (nonatomic, strong) GADBannerView *banner;

@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UIView *broadPickerView;

@property (nonatomic, strong) UILabel *label;

@end

@implementation RecordingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self configUI];
    [self addGesture];
    [self addBanner];
}

- (void)configUI {
    
    CGFloat top = 0;
    if (@available(iOS 11.0, *)) {
        top = UIApplication.sharedApplication.delegate.window.safeAreaInsets.top;
    }
    _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, top + 5, 50, 50)];
    [_backBtn setImage:[UIImage imageNamed:@"icon_back_highlight"] forState:UIControlStateNormal];
    [_backBtn setImage:[UIImage imageNamed:@"icon_back_normal"] forState:UIControlStateHighlighted];
    [_backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backBtn];

    if (@available(iOS 12.0, *)) {
//        _broadPickerView = [[RPSystemBroadcastPickerView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
//
//        [_broadPickerView setValue:@"com.cmcc.xiaoximeeting.ScreenRecordUpload" forKey:@"preferredExtension"];
//        _broadPickerView.center =  CGPointMake(self.view.frame.size.width / 2.0,
//                                               self.view.frame.size.height / 2.0 - 30);
        
        _label = [[UILabel alloc] init];
        _label.text = @"tap to record";
        _label.font = [UIFont systemFontOfSize:14];
        _label.textColor = UIColor.lightGrayColor;
        _label.textAlignment = NSTextAlignmentCenter;
        [_label sizeToFit];
        CGFloat atop = _broadPickerView.frame.origin.y + _broadPickerView.frame.size.height + 5;
        _label.frame = CGRectMake(0, atop, UIScreen.mainScreen.bounds.size.width, _label.frame.size.height);
        [self.view addSubview:_label];
        [self.view addSubview:_broadPickerView];
    }
   
}

- (void)addGesture {
    UISwipeGestureRecognizer *rRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    rRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    UISwipeGestureRecognizer *lRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    lRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.view addGestureRecognizer:rRecognizer];
    [self.view addGestureRecognizer:lRecognizer];
}

- (void)back {
    [self backWithDreiction:UISwipeGestureRecognizerDirectionRight];
}

- (void)swipe:(UISwipeGestureRecognizer *)recognizer {
    
    if (recognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    [self backWithDreiction:recognizer.direction];
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
    [self.navigationController popViewControllerAnimated:NO];
}




- (void)addBanner {
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:@"last_banner_click_time"];
    if (obj) {
        NSDate *date = (NSDate *)obj;
        NSDate *current = [NSDate date];
        if ([current timeIntervalSinceDate:date] < 60 * 60 *2) {
            return;
        }
    }
    
    CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width, 60);
    _banner = [[GADBannerView alloc] initWithAdSize:GADAdSizeFromCGSize(size) origin:CGPointMake(0, [UIScreen mainScreen].bounds.size.height-60)];
    _banner.rootViewController = self;
    _banner.delegate = self;
    _banner.adUnitID = @"ca-app-pub-9435427819697575/4573602850";
    GADRequest *request = [GADRequest request];
    request.testDevices = @[@"E8CE0248-1963-4FF5-BC94-CDD0E9CA5040"];
    [_banner loadRequest:request];
    [self.view addSubview:_banner];
}


@end
