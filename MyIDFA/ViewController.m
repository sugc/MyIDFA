//
//  ViewController.m
//  MyIDFA
//
//  Created by SuGuocai on 2018/2/7.
//  Copyright © 2018年 魔方. All rights reserved.
//

#import "ViewController.h"
#import "InfoViewController.h"
#import <AdSupport/AdSupport.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "AppDelegate.h"

#define IS_IPHONE_5_8 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )812 ) < DBL_EPSILON )

#define iPhoneXSafeDistanceTop ((IS_IPHONE_5_8)?44:0)
#define iPhoneXSafeDistanceBottom ((IS_IPHONE_5_8)?34:0)
#define iPhoneXSafeDistance ((IS_IPHONE_5_8)?78:0)


@interface ViewController ()<GADBannerViewDelegate,GADInterstitialDelegate>

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *idfaLabelTop;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *btnMoreTop;

@property (nonatomic, weak) IBOutlet UILabel *idfaLabel;

@property (nonatomic, assign) BOOL forbidenAd;

@property (nonatomic, strong) GADBannerView *banner;

@property (nonatomic, strong) GADBannerView *requestBanner;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _idfaLabelTop.constant = 40 + iPhoneXSafeDistanceTop;
    NSString *idfa = [self getIDFA];
    _idfaLabel.text = idfa;
    [self checkIsIDFAUseful:idfa];
    [self addGesture];
    [self showAdBanner];
}

- (void)viewWillAppear:(BOOL)animated {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIView *foreView = [[UIView alloc] initWithFrame:self.view.bounds];
        foreView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:foreView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showFullScreenAd];
            [foreView removeFromSuperview];
            //
        });
    });
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [self showAdBanner];
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
    
    [self goToInfoViewControllerWithDirection:recognizer.direction];
}

//
- (NSString *)getIDFA {
    NSString *adid = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    return adid;
}

- (void)checkIsIDFAUseful:(NSString *)idfa {
    //检查idfa 是否可用
    if ([idfa hasPrefix:@"00000000"]) {
        [self showAlterWithMessage:@""];
    }
}

- (void)showAlterWithMessage:(NSString *)message {
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alter show];
}

- (IBAction)actionCopy:(id)sender {
    [self copyStringToClipBoard:_idfaLabel.text];
    [self showAlterWithMessage:@"IDFA copied to your clipboard"];
}

- (void)copyStringToClipBoard:(NSString *)copyString {
    //
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = copyString;
    
}

- (IBAction)actionMore:(id)sender {
    [self goToInfoViewControllerWithDirection:UISwipeGestureRecognizerDirectionLeft];
}

- (void)goToInfoViewControllerWithDirection:(UISwipeGestureRecognizerDirection)direction {
    
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
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"InfoViewController" bundle:nil];
    InfoViewController *infoVC = (InfoViewController *)[story instantiateViewControllerWithIdentifier:@"InfoViewController"];
    [self presentViewController:infoVC animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showFullScreenAd {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (delegate.interstitial.isReady) {
        [CATransaction setDisableActions:YES];
        self.modalPresentationStyle = UIModalPresentationNone;
        [delegate.interstitial presentFromRootViewController:self];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[self presentedViewController] dismissViewControllerAnimated:NO completion:^{
                
            }];
        });
    }
}


- (void)showAdBanner {
    if (_forbidenAd) {
        return;
    }
    
    
    CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width, 60);
    _requestBanner = [[GADBannerView alloc] initWithAdSize:GADAdSizeFromCGSize(size) origin:CGPointMake(0, [UIScreen mainScreen].bounds.size.height-60)];
    _requestBanner.rootViewController = self;
    _requestBanner.delegate = self;
    _requestBanner.adUnitID = @"ca-app-pub-9435427819697575/4379751147";
    GADRequest *request = [GADRequest request];
    [_requestBanner loadRequest:request];
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    [_banner removeFromSuperview];
    _banner = bannerView;
    [self.view addSubview:_banner];
}

- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView {
    [bannerView removeFromSuperview];
    _forbidenAd = YES;
}

@end
