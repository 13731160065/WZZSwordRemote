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
#import "WZZConnectVC.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
@import SystemConfiguration;

@interface ViewController ()
{
    int testN;
    double testX;
    double testY;
    double testZ;
    double testAX;
    double testAY;
    double testAZ;
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
    [_conButton.layer setCornerRadius:5];
    [_testButton.layer setMasksToBounds:YES];
    [_testButton.layer setCornerRadius:5];
    [_msgTextView.layer setMasksToBounds:YES];
    [_msgTextView.layer setCornerRadius:5];
    
    [self logMessage:[NSString stringWithFormat:@"本机ip:%@", [self getIPAddress]]];
    [self logMessage:@"1.点“连接”前，请保持手机与地表呈竖直状态，点击连接5秒后将进入连接状态!"];
    [self logMessage:@"2.点击“校对陀螺仪”前，请先将手机放置于一个稳定物体表面，不要有任何晃动和位移，否则将导致不可预计的后果!"];
    [self logMessage:@"3.没什么意外的话端口默认38080"];
}

- (void)tvScrollToEnd {
    [_msgTextView scrollRangeToVisible:NSMakeRange(_msgTextView.text.length, 1)];
}

//获取WIFIIP的方法
- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_severIP resignFirstResponder];
    [_severPort resignFirstResponder];
}

- (IBAction)testClick:(id)sender {
    //修复自动偏移
    [self logMessage:@"开始校验，请不要动手机"];
    
    for (int i = 0; i < 5; i++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self logMessage:[NSString stringWithFormat:@"倒计时%d秒", 5-i]];
        });
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [WZZMotionManager sharedWZZMotionManager].openA = NO;
        [WZZMotionManager sharedWZZMotionManager].openXYZ = NO;
        [[WZZMotionManager sharedWZZMotionManager] stopUpdate];
        
        //计算误差
        double fixX = testX/testN;
        double fixY = testY/testN;
        double fixZ = testZ/testN;
        
        double fixAX = testAX/testN;
        double fixAY = testAY/testN;
        double fixAZ = testAZ/testN;
        
        [[NSUserDefaults standardUserDefaults] setObject:@{@"fx":@(fixX), @"fy":@(fixY), @"fz":@(fixZ), @"fax":@(fixAX), @"fay":@(fixAY), @"faz":@(fixAZ)} forKey:@"fixvalue"];
        
        [self logMessage:[NSString stringWithFormat:@"校验完毕，校验时间5秒，校验次数%d次", testN]];
        [self logMessage:@"修复值为:"];
        [self logMessage:@"--加速度--"];
        [self logMessage:[NSString stringWithFormat:@"x:%lf", fixX]];
        [self logMessage:[NSString stringWithFormat:@"y:%lf", fixY]];
        [self logMessage:[NSString stringWithFormat:@"z:%lf", fixZ]];
        [self logMessage:@"--角速度--"];
        [self logMessage:[NSString stringWithFormat:@"x:%lf", fixAX]];
        [self logMessage:[NSString stringWithFormat:@"y:%lf", fixAY]];
        [self logMessage:[NSString stringWithFormat:@"z:%lf", fixAZ]];
        
        testX = 0;
        testY = 0;
        testZ = 0;
        testAX = 0;
        testAY = 0;
        testAZ = 0;
        testN = 0;
    });
    
    [WZZMotionManager sharedWZZMotionManager].openA = YES;
    [WZZMotionManager sharedWZZMotionManager].openXYZ = YES;
    [[WZZMotionManager sharedWZZMotionManager] startUpdateWithReturnModel:^(WZZMotionModel *dataModel) {
        double xx = dataModel.a.x;
        double yy = dataModel.a.y;
        double zz = dataModel.a.z;
        testAX+=xx;
        testAY+=yy;
        testAZ+=zz;
        
        double ax = dataModel.xyz.x;
        double ay = dataModel.xyz.y;
        double az = dataModel.xyz.z;
        testX+=ax;
        testY+=ay;
        testZ+=az;
        
        testN++;
    }];
}

- (IBAction)conClick:(id)sender {
    if ([_severIP.text isEqualToString:@""] || [_severPort.text isEqualToString:@""]) {
        [self logMessage:@"把ip和端口填写完整"];
        return;
    }
    WZZConnectVC * vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"WZZConnectVC"];
    vc.severIP = _severIP.text;
    vc.severPort = _severPort.text;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)logMessage:(NSString *)str {
    if (str) {
        str = [@"\n" stringByAppendingString:str];
        _msgTextView.text = [_msgTextView.text stringByAppendingString:str];
        [self tvScrollToEnd];
    }
}

@end
