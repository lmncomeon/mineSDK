//
//  SDKBaseWebViewController.m
//  RiskControlSDK
//
//  Created by 栾美娜 on 2017/3/2.
//  Copyright © 2017年 栾美娜. All rights reserved.
//

#import "SDKBaseWebViewController.h"
#import "SDKcustomHUD.h"


@interface SDKBaseWebViewController () <UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (nonatomic, strong) SDKcustomHUD *blankHUD;

@end

@implementation SDKBaseWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-64)];
    self.webView.scalesPageToFit = YES;
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?access_token=%@", self.loadUrlStr, kgetCommonData(keyName_token)]]]];
 
    self.blankHUD = [SDKcustomHUD new];
    [self.blankHUD showBlankViewInView:self.view];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    // 隐藏导航条
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.getElementsByClassName('mx-title-bar')[0].parentNode.style.display = 'none'"];
    
    // 设置标题
    if (self.titleStr) {
        self.title = self.titleStr;
    } else {
        self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
    
    [self.blankHUD hideBlankView];

//    //禁止用户选择
//    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    
    //禁止长按弹出选择框
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *url = request.URL.absoluteString;
    NSMutableString *newURL = url.mutableCopy;
    NSInteger flag = 0;
    
    while ([newURL rangeOfString:@"http"].location != NSNotFound) {
        [newURL replaceOccurrencesOfString:@"http" withString:@"" options:NSAnchoredSearch range:[newURL rangeOfString:@"http"]];
        flag++;
    }
    
    if (flag == 1 && [newURL containsString:@"SUCCESS"]) {
        [self.navigationController popViewControllerAnimated:true];
        return false;
    }
    

    return true;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    DLog(@"%@ error:\n%@\n", webView, error);
}

@end
