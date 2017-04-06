//
//  CommonService.m
//  TestDemo
//
//  Created by 栾美娜 on 2017/4/5.
//  Copyright © 2017年 栾美娜. All rights reserved.
//

#import "CommonService.h"
#import <CommonCrypto/CommonDigest.h>

//屏幕尺寸
#define kScreenFrame    [UIScreen mainScreen].bounds
#define kScreenWidth    [UIScreen mainScreen].bounds.size.width
#define kScreenHeight   [UIScreen mainScreen].bounds.size.height

#define BaseAPPUrl @"https://grccore.songzidai.com/sdk"

@implementation CommonService


+ (AFHTTPRequestOperationManager *)createObject {
    AFHTTPRequestOperationManager * manger = [AFHTTPRequestOperationManager manager];
    AFSecurityPolicy * securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manger.securityPolicy = securityPolicy;
    manger.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/x-javascript",@"application/json",@"text/plain",@"text/html", @"image/jpeg", @"image/jpg", nil];
    return  manger;
}

#pragma mark - 获取 token
/**
 *  获取平台token
 *
 *  @param success access_token
 *  @param failure error/operation
 */
+ (void)requestAccesstokenWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSString * timeStamp = [NSString stringWithFormat:@"%ld",(long)[[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970]];
    NSString * appVersion = [NSString stringWithFormat:@"V%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    
    NSString * system = [NSString stringWithFormat:@"iOS%@",[[UIDevice currentDevice] systemVersion]];
    NSString * width = [NSString stringWithFormat:@"%.f",kScreenWidth];
    NSString * height = [NSString stringWithFormat:@"%.f",kScreenHeight];
    NSString * appkey = @"112233445566";
    NSString * imei    = [[UIDevice currentDevice].identifierForVendor UUIDString];
    NSString * secretKey = @"fc9caf5bae6a13cad474df97531e0772";
    
    NSDictionary * param = @{
                             @"timestamp": timeStamp,
                             @"appkey" : appkey,
//                             @"userid" : userid,
                             @"version": appVersion,
                             @"imei"   : imei,
                             @"system" : system,
                             @"width"  : width,
                             @"height" : height,
                             @"secretKey" : secretKey
                             };
    NSMutableDictionary * paramsDic = [NSMutableDictionary dictionary];
    if (param) {
        [paramsDic setValuesForKeysWithDictionary:param];
    }
    NSMutableString * signatureString = [NSMutableString string];
    NSArray * sortedKeys = [[paramsDic allValues] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString * key in sortedKeys) {
        [signatureString appendFormat:@"%@",key];
    }
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    NSData * stringBytes = [signatureString dataUsingEncoding:NSUTF8StringEncoding];
    NSString * signature = [NSString string];
    if (CC_SHA1([stringBytes bytes], (CC_LONG)[stringBytes length], digest)) {
        /* SHA-1 hash has been calculated and stored in 'digest'. */
        NSMutableString * digestString = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH];
        for (int i = 0; i< CC_SHA1_DIGEST_LENGTH; i++) {
            unsigned char aChar = digest[i];
            [digestString appendFormat:@"%02x",aChar];
        }
        signature = digestString;
    }
    NSDictionary * parameters = @{
                                  @"signature": signature,
                                  @"timestamp": timeStamp,
                                  @"appkey" : appkey,
//                                  @"userid" : userid,
                                  @"version": appVersion,
                                  @"imei"   : imei,
                                  @"system" : system,
                                  @"width"  : width,
                                  @"height" : height,
                                  @"secretKey" : secretKey
                                  };
    AFHTTPRequestOperationManager * manger = [AFHTTPRequestOperationManager manager];
    AFSecurityPolicy * securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manger.securityPolicy = securityPolicy;
    [manger GET:[NSString stringWithFormat:@"%@/m/accesstoken",BaseAPPUrl] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation, error);
        }
    }];
}

@end
