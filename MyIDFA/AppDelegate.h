//
//  AppDelegate.h
//  MyIDFA
//
//  Created by SuGuocai on 2018/2/7.
//  Copyright © 2018年 魔方. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) GADInterstitial *interstitial;

@end

