//
//  RiskControlSDK.h
//  RiskControlSDK
//
//  Created by 栾美娜 on 2017/2/15.
//  Copyright © 2017年 栾美娜. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RiskControlSDK : NSObject

#pragma mark - 提交信息
/**
 @param token
 @param productType 贷款产品类型
 */
+ (void)presentSDKWithToken:(NSString *)token
                 productType:(NSString *)productType;




#pragma mark - 查看信息
/**
 @param token
 @param productType 贷款产品类型
 */
+ (void)presnetSDKViewInformationWithToken:(NSString *)token
                                productType:(NSString *)productType;



@end
