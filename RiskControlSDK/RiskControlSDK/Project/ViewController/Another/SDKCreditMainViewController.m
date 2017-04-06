//
//  SDKCreditMainViewController.m
//  RiskControlSDK
//
//  Created by 栾美娜 on 2017/2/22.
//  Copyright © 2017年 栾美娜. All rights reserved.
//

#import "SDKCreditMainViewController.h"
#import "SDKCreditMainModel.h"
#import "SDKCreditInfoViewController.h"
#import "SDKEditCreditInfoViewController.h"

@interface SDKCreditMainViewController ()

@property (nonatomic, strong) UIScrollView *mainScrollview;

@end

@implementation SDKCreditMainViewController

- (UIScrollView *)mainScrollview {
    if (!_mainScrollview) {
        _mainScrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-64)];
        _mainScrollview.alwaysBounceVertical=true;
        _mainScrollview.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.view addSubview:_mainScrollview];
    }
    return _mainScrollview;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavWithTitle:@"信用资料"];
    self.navigationItem.leftBarButtonItem = [self createBackButton:@selector(back)];
    
    // banner
    UIImageView *banner = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, adaptY(119))];
    banner.image = [UIImage imageNamed:kImageBundle @"iOS-banner"];
    [self.mainScrollview addSubview:banner];
    
    // 主页
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(banner.frame)+adaptY(8.5), kScreenWidth, 0)];
    [self.mainScrollview addSubview:container];
    
    CGFloat itemW = (kScreenWidth-0.5f)*0.5;
    CGFloat itemH = adaptY(79);
    
    NSInteger count = _list.count;
    if (_list.count % 2 != 0) { // 奇数
        count++;
    }
    
    for (int i = 0; i < count; i++) {
        NSInteger row = i / 2;
        NSInteger col = i % 2;
       
        if (_list.count % 2 != 0)
        { // 奇数
            if (i == count-1) { // add another
                UIView *another = [self createPlaceholderWithFrame:CGRectMake(col*(itemW+0.5f), row*(itemH+0.5f), itemW, itemH)];
                [container addSubview:another];
            } else {
                UIButton *item = [self createItemWithFrame:CGRectMake(col*(itemW+0.5f), row*(itemH+0.5f), itemW, itemH) model:_list[i]];
                item.tag = 1000 + i; // tag
                [container addSubview:item];
            }
        }
        else
        {
            UIButton *item = [self createItemWithFrame:CGRectMake(col*(itemW+0.5f), row*(itemH+0.5f), itemW, itemH) model:_list[i]];
            item.tag = 1000 + i; // tag
            [container addSubview:item];
        }
    }
    
    container.height = CGRectGetMaxY(container.subviews.lastObject.frame);
    
    
    
    self.mainScrollview.contentSize = CGSizeMake(0, CGRectGetMaxY(self.mainScrollview.subviews.lastObject.frame));
}

- (void)btnAction:(UIButton *)sender {
    DLog(@"%ld", sender.tag-1000);
    
    SDKCreditMainModel *model = self.list[sender.tag-1000];
    
    [SDKNetworkState WithSuccessBlock:^(BOOL status) {
        if (status == true)
        {
            self.hud = [SDKcustomHUD new];
            [self.hud showCustomHUDWithView:self.view];
            
            [SDKCommonService requestCreditInfoWithType:model.type success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if ([responseObject[@"retcode"] integerValue] == 200) {
                    [self.hud hideCustomHUD];
                    
                    NSArray *items = [responseObject[@"data"] objectForKey:@"items"];
                    NSDictionary *valuesDic = [responseObject[@"data"] objectForKey:@"values"];
                    NSString *name = [responseObject[@"data"] objectForKey:@"name"];
                    
                    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:5];
                    for (NSDictionary *dic in items) {
                        SDKCommonModel *model = [SDKCommonModel yy_modelWithDictionary:dic];
                        
                        if ([model.type isEqualToString:@"area"]) {
                            model.value1 = ![valuesDic[model.name] isEqual:[NSNull null]] ?valuesDic[model.name] : @"";
                            model.value2 = ![valuesDic[model.name2] isEqual:[NSNull null]] ?valuesDic[model.name2] : @"";
                            model.value3 = ![valuesDic[model.name3] isEqual:[NSNull null]] ?valuesDic[model.name3] : @"";
                        }
                        else if ([model.type isEqualToString:@"readtext"]) {
                            model.value1 = ![valuesDic[model.name] isEqual:[NSNull null]] ?valuesDic[model.name] : @"";
                            model.value2 = ![valuesDic[model.name2] isEqual:[NSNull null]] ?valuesDic[model.name2] : @"";
                        }
                        else if ([model.type isEqualToString:@"radio"] ||
                                 [model.type isEqualToString:@"checkbox"] ||
                                 [model.type isEqualToString:@"list"]) {
                            NSString *index = ![valuesDic[model.name] isEqual:[NSNull null]] ?valuesDic[model.name] : @"";
                            model.value1 = index;
                        }
                        else if ([model.type isEqualToString:@"image"]) {
                            model.value1 = ![valuesDic[model.name] isEqual:[NSNull null]] ?valuesDic[model.name] : @"";
                            model.value2 = ![valuesDic[model.name2] isEqual:[NSNull null]] ?valuesDic[model.name2] : @"";
                            model.value3 = ![valuesDic[model.name3] isEqual:[NSNull null]] ?valuesDic[model.name3] : @"";
                        }
                        else if ([model.type isEqualToString:@"text"] || [model.type isEqualToString:@"phone"] || [model.type isEqualToString:@"mailbox"])
                            
                        {
                            model.value1 = ![valuesDic[model.name] isEqual:[NSNull null]] ?valuesDic[model.name] : @"";
                        }
                        
                        [tmp addObject:model];
                    }
                    
                    if (tmp.count) {
                        SDKCreditInfoViewController *infoVC = [SDKCreditInfoViewController new];
                        infoVC.dataArray = tmp.copy;
                        infoVC.titleStr = model.text;
                        infoVC.name = name;
                        infoVC.edit = ![responseObject[@"data"][@"readonly"] boolValue];
                        [self.navigationController pushViewController:infoVC animated:true];
                        
//                        if ([[responseObject[@"data"] objectForKey:@"status"] boolValue])
//                        { // 可以修改
//                            [self getProvince:tmp.copy title:model.text name:name];
//                        }
//                        else
//                        {
//                            SDKCreditInfoViewController *infoVC = [SDKCreditInfoViewController new];
//                            infoVC.dataArray = tmp.copy;
//                            infoVC.titleStr = model.text;
//                            [self.navigationController pushViewController:infoVC animated:true];
//                        }
                        
                    } else {
                        showTip(@"无数据");
                    }
                    
                }else{
                    [self.hud hideCustomHUD];
                    showTip(responseObject[@"msg"]);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self.hud hideCustomHUD];
                [self errorDispose:[[operation response] statusCode] judgeMent:nil];
            }];
           
        }
        else
        {
            [self errorRemind:nil];
        }
    }];
    
    
}

// 返回item
- (UIButton *)createItemWithFrame:(CGRect)frame model:(SDKCreditMainModel *)model {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:[UIImage imageWithColor:commonWhiteColor] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageWithColor:cuttingLineColor] forState:UIControlStateHighlighted];
    btn.frame = frame;
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIView *item = [[UIView alloc] initWithFrame:btn.bounds];
    item.userInteractionEnabled = false;
    [btn addSubview:item];
    
    
    CGFloat colorWH = adaptX(8);
    UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(adaptX(40), (frame.size.height-colorWH)*0.5, colorWH, colorWH)];
    colorView.backgroundColor = model.color;
    colorView.layer.masksToBounds = true;
    colorView.layer.cornerRadius = colorWH*0.5;
    [item addSubview:colorView];
    
    SDKCustomLabel *lab = [SDKCustomLabel setLabelTitle:model.text setLabelFrame:CGRectMake(CGRectGetMaxX(colorView.frame) +adaptX(5), (frame.size.height-adaptY(20))*0.5, adaptX(100), adaptY(20)) setLabelColor:commonBlackColor setLabelFont:kFont(14)];
    [item addSubview:lab];
    
    return btn;
}

- (UIView *)createPlaceholderWithFrame:(CGRect)frame {
    UIView *item = [[UIView alloc] initWithFrame:frame];
    item.backgroundColor = commonWhiteColor;
    
    CGFloat colorWH = adaptX(8);
    CGFloat padding = adaptX(10);
    CGFloat startX  = (frame.size.width - 3*colorWH - 2*padding)*0.5;
    for (int i = 0; i < 3; i++) {
        
        UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(startX + i*(colorWH+padding), (frame.size.height-colorWH)*0.5, colorWH, colorWH)];
        colorView.backgroundColor = commonGrayColor;
        colorView.layer.masksToBounds = true;
        colorView.layer.cornerRadius = colorWH*0.5;
        [item addSubview:colorView];
    }
    
    return item;
}

#pragma mark - 返回
- (void)back {
    [self dismissViewControllerAnimated:true completion:nil];
}


@end
