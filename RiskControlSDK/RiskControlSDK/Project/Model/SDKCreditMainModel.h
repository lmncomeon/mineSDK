//
//  SDKCreditMainModel.h
//  RiskControlSDK
//
//  Created by 栾美娜 on 2017/2/22.
//  Copyright © 2017年 栾美娜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SDKCreditMainModel : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong) UIColor *color;

+ (NSArray *)getList;

+ (UIColor *)getRandomColor;

@end
