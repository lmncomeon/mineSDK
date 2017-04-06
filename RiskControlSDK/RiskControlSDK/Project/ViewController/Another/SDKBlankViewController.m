//
//  SDKBlankViewController.m
//  RiskControlSDK
//
//  Created by 栾美娜 on 2017/2/23.
//  Copyright © 2017年 栾美娜. All rights reserved.
//

#import "SDKBlankViewController.h"
#import "SDKPickerModel.h"
#import "SDKCreditMainModel.h"
#import "SDKCheckCrossBorder.h"

// 激活
#import "SDKPhoneAuthenticationViewController.h"
#import "SDKIdentityAuthenticationViewController.h"
#import "SDKBankCardAuthenticationViewController.h"
// 完善资料
#import "SDKCreditNumTwoViewController.h"
// 主动风控
#import "SDKVideoViewController.h"
#import "SDKPhotoViewController.h"
#import "SDKInputTypeViewController.h"
#import "SDKSelectOnePhoneViewController.h"
#import "SDKRecordViewController.h"
// 审核中
#import "SDKCheckResultViewController.h"
// 直接进件
#import "SDKCheckModifyViewController.h"
// 其他入口
#import "SDKCreditMainViewController.h"

@interface SDKBlankViewController ()

@property (nonatomic, strong) UIView *progresslayer;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *areaList;

@end

@implementation SDKBlankViewController

- (UIView *)progresslayer {
    if (!_progresslayer) {
        _progresslayer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 3)];
        _progresslayer.backgroundColor =  UIColorFromRGB(0x42aef7);
        _progresslayer.hidden = false;
        [self.view addSubview:_progresslayer];
    }
    return _progresslayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNavWithTitle:@"XXX"];
    self.navigationItem.leftBarButtonItem = [self createBackButton:@selector(back)];
    [SDKCheckCrossBorder setXcodeSafetyLog:true];
    
    // progress
    [UIView animateWithDuration:0.5f animations:^{
        self.progresslayer.width = kScreenWidth*0.6;
    }];
    
//    // 获取token
//    [SDKNetworkState WithSuccessBlock:^(BOOL status){
//        if (status == true)
//        {
//            [self requestToken];
//        }
//        else
//        {
//            [self errorRemind:nil];
//        }
//    }];
    
    
    if (_index == 0) { // 提交
        [self getUserCurrentStatus];
    } else if (_index == 1) {
        // 查看信息
        [self getMainList];
    }
}


// 获取token
- (void)requestToken {
    [SDKCommonService requestAccesstokenWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        DLog(@"\n\n\ntokeen:%@", [responseObject objectForKey:@"data"]);
        
        if ([responseObject[@"retcode"] integerValue] == 200)
        {
            // save
            [[NSUserDefaults standardUserDefaults] setObject:[responseObject objectForKey:@"data"] forKey:keyName_token];
            
            if (_index == 0) {
                // one->
                [self getUserCurrentStatus];
            } else if (_index == 1) {
                // two->
//                [[NSUserDefaults standardUserDefaults] setObject:@"5591283a28428e060896b2cec6797c90ff2b8885" forKey:kTokenName];
                
                [self getMainList];
            }
            
        }
        else
        {
            showTip(responseObject[@"msg"]);
            [self progressEndWithBlock:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 存储
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:keyName_token];
        [self progressEndWithBlock:nil];
        
        NSString *errorStr = [NSString stringWithFormat:@"error: %ld",[[operation response] statusCode]];
        showTip(errorStr);
    }];
    
}

#pragma mark - one
// 获取当前状态
- (void)getUserCurrentStatus {
    [SDKNetworkState WithSuccessBlock:^(BOOL status) {
        if (status == true) {
            
            [SDKCommonService checkUserStatusSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                if ([responseObject[@"retcode"] integerValue] == 200) {
                    [self progressEndWithBlock:^{
                        
                        NSInteger status = [[[responseObject objectForKey:@"data"] objectForKey:@"step"] integerValue];
                        if (status == 0)
                        { // 未激活
                            NSInteger index = [[[[responseObject objectForKey:@"data"] objectForKey:@"jump"] objectForKey:@"step"] integerValue];

                            if (index == 1) {
                                [self.navigationController pushViewController:[SDKPhoneAuthenticationViewController new] animated:true];
                            } else if (index == 2) {
                                [self.navigationController pushViewController:[SDKIdentityAuthenticationViewController new] animated:true];
                            }  else if (index == 3) {
                                [self.navigationController pushViewController:[SDKBankCardAuthenticationViewController new] animated:true];
                            }
                        }
                        else if (status == 1)
                        { // 1 未提交资料
                            [self getSteps];
                        }
                        else if (status == 2)
                        { // 2 审核中
                            [self.navigationController pushViewController:[SDKCheckResultViewController new] animated:true];
                        }
                        else if (status == 3)
                        { // 3.已修改
                            [self.navigationController pushViewController:[SDKCheckModifyViewController new] animated:true];
                        }

                    }];
                } else {
                    showTip(responseObject[@"msg"]);
                    [self progressEndWithBlock:nil];
                    
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self errorDispose:[[operation response] statusCode] judgeMent:nil];
                [self progressEndWithBlock:nil];
            }];
        } else {
            [self errorRemind:nil];
        }
    }];
}

- (void)getSteps {
    [SDKNetworkState WithSuccessBlock:^(BOOL status) {
        if (status == true)
        {
            [SDKCommonService infomationGetStepsWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                if ([responseObject[@"retcode"] integerValue] == 200) {
                    
                    [self.dataArray removeAllObjects];
                    
                    for (NSDictionary *dic in responseObject[@"data"]) {
                        SDKInfomationModel *model = [SDKInfomationModel yy_modelWithDictionary:dic];
                        [self.dataArray addObject:model];
                    }
                    
                    if (self.dataArray.count > 0) {
                        [self getProvince];
                    }
                    
                }else{
                    showTip(responseObject[@"msg"]);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self errorDispose:[[operation response] statusCode] judgeMent:nil];
            }];
        }
        else
        {
            [self errorRemind:nil];
        }
    }];
}

// 获取省市区
- (void)getProvince {
    [SDKCommonService requestProvinceCityZoneSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
            
            [self.areaList removeAllObjects];
            
        
            for (NSDictionary *dic in responseObject) {
                SDKPickerModel *provinceModel = [SDKPickerModel new];
                provinceModel.text = dic[@"province"];
                
                NSMutableArray *cityArray = [NSMutableArray arrayWithCapacity:5];
                NSArray *tmpCityArr = dic[@"cities"];
                for (NSDictionary *cityDic in tmpCityArr) {
                    SDKPickerModel *cityModel = [SDKPickerModel new];
                    cityModel.text = cityDic[@"city"];
                    
                    NSMutableArray *zoneArray = [NSMutableArray arrayWithCapacity:5];
                    NSArray *tmpZoneArr = cityDic[@"zones"];
                    for (NSString *zone in tmpZoneArr) {
                        SDKPickerModel *zoneModel = [SDKPickerModel new];
                        zoneModel.text = zone;
                        [zoneArray addObject:zoneModel];
                    }
                    
                    cityModel.list = zoneArray;
                    [cityArray addObject:cityModel];
                }
                
                
                provinceModel.list = cityArray;
                [self.areaList addObject:provinceModel];
                
            }
            
            [self canPushVC];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self errorDispose:[[operation response] statusCode] judgeMent:nil];
    }];
}

- (void)canPushVC {
    SDKCreditNumTwoViewController *numVC = [SDKCreditNumTwoViewController new];
    numVC.current = 0;
    numVC.data = self.dataArray;
    numVC.areaList = self.areaList.copy;
    [self.navigationController pushViewController:numVC animated:true];
}





#pragma mark - two
// 获取主页列表
- (void)getMainList {
    [SDKNetworkState WithSuccessBlock:^(BOOL status){
        if (status == true)
        {
            [SDKCommonService requestCreditListSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                if ([responseObject[@"retcode"] integerValue] == 200) {
                    

                    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:5];
                    
                    NSDictionary *dic = responseObject[@"data"];
                    NSArray *keysArr = [dic allKeys];
                    for (NSString *key in keysArr) {
                        SDKCreditMainModel *model = [SDKCreditMainModel new];
                        model.type = key;
                        model.text = dic[key];
                        model.color =  [SDKCreditMainModel getRandomColor];
                        [tmp addObject:model];
                    }
                    
                    if (keysArr.count) {
                        // jump
                        SDKCreditMainViewController *mainVC = [SDKCreditMainViewController new];
                        mainVC.list = tmp.copy;
                        [self.navigationController pushViewController:mainVC animated:true];
                    }
                    
                } else {
                    showTip(responseObject[@"msg"]);
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self errorDispose:[[operation response] statusCode] judgeMent:nil];
                [self progressEndWithBlock:nil];
            }];
        }
        else
        {
            [self errorRemind:nil];
        }
    }];
}


#pragma mark - 进度条结束
- (void)progressEndWithBlock:(void(^)(void))block {
    [UIView animateWithDuration:0.5f animations:^{
        self.progresslayer.width = kScreenWidth;
    } completion:^(BOOL finished) {
        if (finished) {
            self.progresslayer.hidden = true;
            self.progresslayer.width = 0;
            if (block) {
                block();
            }
        }
    }];
}

#pragma mark - lazy load
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


- (NSMutableArray *)areaList {
    if (!_areaList) {
        _areaList = [NSMutableArray array];
    }
    return _areaList;
}

#pragma mark - 返回
- (void)back {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
