//
//  WZZConnectVC.m
//  WZZSwordRemote
//
//  Created by 王泽众 on 2017/6/7.
//  Copyright © 2017年 wzz. All rights reserved.
//

#import "WZZConnectVC.h"
#import "WZZMotionManager.h"
#import "WZZSocketManager.h"

@interface WZZConnectVC ()
{
    WZZSocketClientManager * clientManager;
    WZZMotionManager * motionManager;
}

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITextView *mainTextView;

@end

@implementation WZZConnectVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [_mainTextView.layer setMasksToBounds:YES];
    [_mainTextView.layer setCornerRadius:5];
    [_backButton.layer setMasksToBounds:YES];
    [_backButton.layer setCornerRadius:5];
    [self setup];
    [self logMessage:@"请保持手机与地表呈竖直状态，马上建立连接倒计时5秒"];
    for (int i = 0; i < 5; i++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self logMessage:[NSString stringWithFormat:@"倒计时%d秒", 5-i]];
        });
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self logMessage:@"准备建立连接"];
        [self connect];
    });
    
    //监听系统音量键
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetPR:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

- (void)setup {
    motionManager = [WZZMotionManager sharedWZZMotionManager];
    motionManager.openA = YES;
    motionManager.openXYZ = YES;
    [motionManager resetDataModelPR];
    [motionManager startUpdateWithReturnModel:^(WZZMotionModel *dataModel) {
        float rPix = 0.1;
        //修复自动偏移
        float xFix = 0.005104;
        float yFix = 0.002498;
        float zFix = 0.001521;
        
        CGFloat x = dataModel.rotation.x+dataModel.xyz.x*rPix+xFix;//加速度值为弧度/秒，乘0.1是0.1秒的
        CGFloat y = dataModel.rotation.y+dataModel.xyz.y*rPix+yFix;
        CGFloat z = dataModel.rotation.z+dataModel.xyz.z*rPix+zFix;
        
        float aPix = 0;
        //修复自动偏移
        float xxFix = 0.000044;
        float yyFix = 0.000066;
        float zzFix = -0.003074;
        CGFloat xx = dataModel.position.x+dataModel.a.x*aPix+xxFix;
        CGFloat yy = dataModel.position.y+dataModel.a.y*aPix+yyFix;
        CGFloat zz = dataModel.position.z+dataModel.a.z*aPix+zzFix;
        
        dataModel.rotation = SCNVector3Make(x, y, z);
        dataModel.position = SCNVector3Make(xx, yy, zz);
        
        [self sendStringWithDic:@{
                                  @"a":@{@"x":@(xx), @"y":@(yy), @"z":@(zz)},
                                  @"xyz":@{@"x":@(x), @"y":@(y), @"z":@(z)},
                                  }];
        //            if (testN < 100) {
        //                testX+=xx;
        //                testY+=yy;
        //                testZ+=zz;
        //                if (testN == 99) {
        //                    NSLog(@"%f, %f, %f", testX/100, testY/100, testZ/100);
        //                }
        //                testN++;
        //            }
    }];
    clientManager = [WZZSocketClientManager sharedClientManager];
    [clientManager logMessage:^(NSString *msg) {
        [self logMessage:msg];
    }];
}

- (void)resetPR:(NSNotification *)noti {
    [motionManager resetDataModelPR];
}

- (void)sendStringWithDic:(NSDictionary *)dic {
    NSString * str = [self jsonFromObject:dic];
    if (str) {
        [clientManager sendString:str];
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
- (IBAction)backClick:(id)sender {
    [clientManager disconnectServer];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)connect {
    [clientManager connectServerWithHost:_severIP port:_severPort];
    [motionManager resetDataModelPR];
}

- (void)logMessage:(NSString *)str {
    if (str) {
        str = [@"\n" stringByAppendingString:str];
        _mainTextView.text = [_mainTextView.text stringByAppendingString:str];
        [self tvScrollToEnd];
    }
}

- (void)tvScrollToEnd {
    [_mainTextView scrollRangeToVisible:NSMakeRange(_mainTextView.text.length, 1)];
}

@end
