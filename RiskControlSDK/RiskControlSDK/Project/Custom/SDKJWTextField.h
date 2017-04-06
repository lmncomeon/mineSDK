//
//  SDKJWTextField.h
//  SDKJWTextField
//
//  Created by 梁家文 on 16/6/11.
//  Copyright © 2016年 梁家文. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TextFieldImportStyle) {
    TextFieldImportStyleNormal = 0,     //无限制
    TextFieldImportStyleNumber = 1,     //限制数字输入格式 (首位不可以为0)
    TextFieldImportStylePassword = 2,   //限制密码输入格式 (暂时没有限制)
    TextFieldImportStyleMoney = 3,       //限制金钱输入格式  (输入格式：最低输入1.00)
    TextFieldImportStyleMinMoney = 4,       //限制金钱输入格式 (输入格式：最低输入0.01)
    TextFieldImportStyleRightfulMoney = 5,       //限制合法的小数金额限制 (合法的小数输入规则)
    TextFieldImportStyleNumberTwo = 6,     //限制数字输入格式 (首位可以为0)
    TextFieldImportStyleNumberandLetter = 7  //限制只能输入数字和字母
};


@interface SDKJWTextField : UITextField

@property (nonatomic,assign)BOOL isDian;//是否有小数点

@property (nonatomic,assign)TextFieldImportStyle importStyle;

@property (nonatomic,assign)NSInteger maxLength; /**< 最大限制默认为7位 */

@property (nonatomic, strong) NSString *max; // 默认99999999.99

@property (nonatomic,copy) void(^importBackString)(NSString * backStr);

@end







// ======================================================================
@interface SDKMNChineseField : UITextField

- (instancetype)initWithFrame:(CGRect)frame placeHolder:(NSString *)placeHolder font:(UIFont *)font align:(NSTextAlignment)align;

@property (nonatomic, copy) void (^sendValueBlock)(NSString *backStr);

@end







