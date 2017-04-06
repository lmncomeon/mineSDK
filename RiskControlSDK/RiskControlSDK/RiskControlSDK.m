//
//  RiskControlSDK.m
//  RiskControlSDK
//
//  Created by 栾美娜 on 2017/2/15.
//  Copyright © 2017年 栾美娜. All rights reserved.
//

#import "RiskControlSDK.h"
#import "SDKCommonService.h"
#import "SDKDefaultSetting.h"
#import "SDKProjectHeader.h"
#import "SDKNavigationController.h"
#import "SDKcustomHUD.h"
// 空白页面
#import "SDKBlankViewController.h"

#import "SDKRecordViewController.h"
#import "SDKVideoViewController.h"
#import "SDKRecordViewController.h"

@interface RiskControlSDK () 

@property (nonatomic, strong) UIViewController *fromVC;

@end

@implementation RiskControlSDK

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.fromVC = [self currentViewController];
    }
    return self;
}

- (instancetype)initWithToken:(NSString *)token
                   productType:(NSString *)productType {
    self = [super init];
    if (self) {
        self.fromVC = [self currentViewController];
        
        [[NSUserDefaults standardUserDefaults] setObject:token forKey:keyName_token];
        [[NSUserDefaults standardUserDefaults] setObject:productType forKey:keyName_product];

    }
    return self;
}

// one-> 提交信息
+ (void)presentSDKWithToken:(NSString *)token
                productType:(NSString *)productType {
    RiskControlSDK *sdk = [[RiskControlSDK alloc] initWithToken:token productType:productType];
    [sdk presentSDKWithIndex:0];
}

// two-> 查看信息
+ (void)presnetSDKViewInformationWithToken:(NSString *)token
                               productType:(NSString *)productType {
    RiskControlSDK *sdk = [[RiskControlSDK alloc] initWithToken:token productType:productType];
    [sdk presentSDKWithIndex:1];
}


// 进入SDK
- (void)presentSDKWithIndex:(NSInteger)index {
    
    SDKBlankViewController *blankVC = [SDKBlankViewController new];
    blankVC.index = index;
    
    [self.fromVC presentViewController:[[SDKNavigationController alloc] initWithRootViewController:blankVC] animated:true completion:nil];
}


#pragma mark - 获取当前控制器
- (UIViewController *)currentViewController
{
    
    UIViewController * currVC = nil;
    UIViewController * Rootvc = [UIApplication sharedApplication].keyWindow.rootViewController;
    do {
        if ([Rootvc isKindOfClass:[UINavigationController class]]) {
            UINavigationController * nav = (UINavigationController *)Rootvc;
            UIViewController * v = [nav.viewControllers lastObject];
            currVC = v;
            Rootvc = v.presentedViewController;
            continue;
        }
        else if([Rootvc isKindOfClass:[UITabBarController class]]) {
            UITabBarController * tabVC = (UITabBarController *)Rootvc;
            currVC = tabVC;
            Rootvc = [tabVC.viewControllers objectAtIndex:tabVC.selectedIndex];
            continue;
        }
        else if ([Rootvc isKindOfClass:[UIViewController class]]) {
            UIViewController * aVC = (UIViewController *)Rootvc;
            currVC = aVC;
            Rootvc = aVC.presentedViewController;
            continue;
        }
    } while (Rootvc!=nil);
    
    
    return currVC;
}

@end
