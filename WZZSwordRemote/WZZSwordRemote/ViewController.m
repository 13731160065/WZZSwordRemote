//
//  ViewController.m
//  WZZSwordRemote
//
//  Created by 王泽众 on 2017/6/3.
//  Copyright © 2017年 wzz. All rights reserved.
//

#import "ViewController.h"
#import "WZZSocketManager.h"
#import "WZZMotionManager.h"
@import CoreMotion;

@interface ViewController ()
{
    WZZSocketClientManager * clientManager;
    WZZMotionManager * motionManager;
}
@property (weak, nonatomic) IBOutlet UIButton *conButton;
@property (weak, nonatomic) IBOutlet UIButton *testButton;
@property (weak, nonatomic) IBOutlet UITextField *severIP;
@property (weak, nonatomic) IBOutlet UITextField *severPort;
@property (weak, nonatomic) IBOutlet UITextView *msgTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_conButton.layer setMasksToBounds:YES];
    [_conButton.layer setCornerRadius:10];
    [_testButton.layer setMasksToBounds:YES];
    [_testButton.layer setCornerRadius:10];
    motionManager = [WZZMotionManager sharedWZZMotionManager];
    motionManager.openA = YES;
    motionManager.openXYZ = YES;
    [motionManager startUpdateWithReturnModel:^(WZZMotionModel *dataModel) {
        [self sendStringWithDic:@{
                                  @"a":@{@"x":@(dataModel.a.x), @"y":@(dataModel.a.y), @"z":@(dataModel.a.z)},
                                  @"xyz":@{@"x":@(dataModel.xyz.x), @"y":@(dataModel.xyz.y), @"z":@(dataModel.xyz.z)},
                                  }];
    }];
    clientManager = [WZZSocketClientManager sharedClientManager];
    [clientManager logMessage:^(NSString *msg) {
        [self logMessage:msg];
    }];
}

- (IBAction)testClick:(id)sender {
    [self sendStringWithDic:@{@"msg":@"hello world"}];
}

- (IBAction)conClick:(id)sender {
    if ([_severIP.text isEqualToString:@""] || [_severPort.text isEqualToString:@""]) {
        return;
    }
    [clientManager connectServerWithHost:_severIP.text port:_severPort.text];
}

- (void)sendStringWithDic:(NSDictionary *)dic {
    NSString * str = [self jsonFromObject:dic];
    if (str) {
        [clientManager sendString:str];
    }
}

- (void)logMessage:(NSString *)str {
    if (str) {
        str = [@"\n" stringByAppendingString:str];
        _msgTextView.text = [_msgTextView.text stringByAppendingString:str];
    }
}

//对象转json
- (NSString *)jsonFromObject:(id)obj {
    if (obj == nil) {
        return nil;
    }
    NSError * err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:0 error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
