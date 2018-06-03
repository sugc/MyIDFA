//
//  InfoViewController.m
//  MyIDFA
//
//  Created by SuGuocai on 2018/4/22.
//  Copyright © 2018年 魔方. All rights reserved.
//

#import "InfoViewController.h"
#import "InfoTableViewCell.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#include <net/if.h>
#import "MacAddressManager.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
//#define IOS_VPN       @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

@interface InfoViewController()<
    UITableViewDelegate,
    UITableViewDataSource,
    GADBannerViewDelegate
>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, copy) NSString *deviceIpv4;

@property (nonatomic, copy) NSString *deviceIpv6;

@property (nonatomic, copy) NSString *celluarIpv4;

@property (nonatomic, copy) NSString *macAddr;

@property (nonatomic, strong) GADBannerView *banner;

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    [self addGesture];
    [self getAllInfo];
    [self addBanner];
}

- (void)configUI {
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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
    InfoTableViewCell *cell = (InfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"InfoTableViewCell"];
    
    NSString *title = @"";
    NSString *subTitle = @"";
    
    switch (indexPath.row) {
        case 0:
            title = @"Device IP";
            if (_deviceIpv4) {
                subTitle = _deviceIpv4;
            }else {
                subTitle = @"NO IP";
            }
            break;
        case 1:
            title = @"Device IP(V6)";
            if (_deviceIpv6) {
                subTitle = _deviceIpv6;
            }else {
                subTitle = @"NO IP";
            }
            break;
        case 2:
            title = @"Celluar IP";
            if (_celluarIpv4) {
                subTitle = _celluarIpv4;
            }else {
                subTitle = @"NO IP";
            }
            break;
        case 3:
            
            title = @"Mac addreess";
            if (_macAddr) {
                subTitle = _macAddr;
            }else {
                subTitle = @"please enable your wifi to get mac address";
            }
            break;
        default:
            break;
    }
    
    cell.titleLabel.text = title;
    cell.subTitleLabel.text = subTitle;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //请求获取更加详细的ip信息
    if (indexPath.row == 0) {
    
    }else if (indexPath.row == 1) {
        
    }
}

- (IBAction)actionBack:(id)sender {
    [self backWithDreiction:UISwipeGestureRecognizerDirectionRight];
}

- (IBAction)actionRefresh:(id)sender {
    [self getAllInfo];
    [self.tableView reloadData];
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

//获取所有信息
- (void)getAllInfo {
    [self getIPAddress:YES];
    
    _macAddr = [MacAddressManager getMacAddressFromMDNS];
}

- (void)getIPAddress:(BOOL)preferIPv4 {
    
    NSArray *searchArray = preferIPv4 ?
  @[ IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6] :
    @[ /*IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4,*/ IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {

         NSString *ip = addresses[key];
         if ([key hasSuffix:IP_ADDR_IPv4]) {
             if (ip) {
                 _deviceIpv4 = ip;
             }
         }else if ([key hasSuffix:IP_ADDR_IPv6]) {
             if (ip) {
                 _deviceIpv6 = ip;
             }
         }
         
         if ([key hasPrefix:IOS_CELLULAR]) {
             if (ip) {
                 _celluarIpv4 = ip;
             }
         }
     }];
}

- (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
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


- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView {
    [bannerView removeFromSuperview];
    NSDate *date = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:@"last_banner_click_time"];
}

@end
