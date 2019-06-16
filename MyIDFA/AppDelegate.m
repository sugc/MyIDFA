//
//  AppDelegate.m
//  MyIDFA
//
//  Created by SuGuocai on 2018/2/7.
//  Copyright © 2018年 魔方. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "RecordingViewController.h"

#define IS_IPHONE_5_8 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )812 ) < DBL_EPSILON )

#define iPhoneXSafeDistanceTop ((IS_IPHONE_5_8)?44:0)
#define iPhoneXSafeDistanceBottom ((IS_IPHONE_5_8)?34:0)
#define iPhoneXSafeDistance ((IS_IPHONE_5_8)?78:0)

static NSInteger count = 2;

@interface AppDelegate ()<GADInterstitialDelegate>

@property (nonatomic, strong) UILabel *countDownLabel;

@property (nonatomic, strong) GADInterstitial *interstitial;

@property (nonatomic, strong) UIViewController *topVC;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self.window makeKeyAndVisible];
    
    UINavigationController *nav = [[UINavigationController alloc] init];
    self.window.rootViewController = nav;
    nav.navigationBar.hidden = YES;
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *VC = [story instantiateViewControllerWithIdentifier:@"ViewController"];
    

    [nav pushViewController:VC animated:NO];
    nav.interactivePopGestureRecognizer.enabled = NO;
    
    [Fabric with:@[[Crashlytics class]]];
    [GADMobileAds configureWithApplicationID:@"ca-app-pub-9435427819697575~1781631674"];
    [self resetAd];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [self enterForeGround];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)enterForeGround {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [self showFullScreenAd];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self resetAd];
    });
}


- (void)resetAd {
//    self.interstitial = nil;
//    self.interstitial = [[GADInterstitial alloc]
//                         initWithAdUnitID:@"ca-app-pub-9435427819697575/1413614365"];
//    self.interstitial.delegate = self;
//    GADRequest *request = [GADRequest request];
//    request.testDevices = @[@"E8CE0248-1963-4FF5-BC94-CDD0E9CA5040"];
//    [self.interstitial loadRequest:request];
}

- (void)showFullScreenAd {
//    if (self.interstitial.isReady) {
//        [CATransaction setDisableActions:YES];
//        self.topVC.modalPresentationStyle = UIModalPresentationNone;
//        [self.interstitial presentFromRootViewController:self.topVC];
//
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            _countDownLabel = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen  mainScreen].bounds.size.width - 70,
//                                                                        iPhoneXSafeDistanceTop + 10,
//                                                                        50,
//                                                                        20)];
//            _countDownLabel.layer.cornerRadius = 10;
//            _countDownLabel.layer.masksToBounds = YES;
//            _countDownLabel.textColor = [UIColor whiteColor];
//
//            _countDownLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
//            _countDownLabel.text = @"3";
//            _countDownLabel.textAlignment = NSTextAlignmentCenter;
//            [self.window addSubview:_countDownLabel];
//            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(repeat:) userInfo:nil repeats:YES];
//        });
//    }
}

- (void)repeat:(NSTimer *)timer {
    
    if (count == 0) {
        [timer invalidate];
        [_countDownLabel removeFromSuperview];
        [[self.topVC presentedViewController] dismissViewControllerAnimated:NO completion:^{
            count = 2;
        }];
    }else {
        NSString *text = [NSString stringWithFormat:@"%ld",count];
        _countDownLabel.text = text;
    }
    count --;
}


-(UIViewController *)topVC {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UINavigationController *nav = (UINavigationController *)delegate.window.rootViewController;
    _topVC = [nav topViewController];
    return _topVC;
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
//    [_countDownLabel removeFromSuperview];
//    count = 2;
//    [self resetAd];
}

@end
