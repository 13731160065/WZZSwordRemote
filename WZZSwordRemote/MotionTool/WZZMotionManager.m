//
//  WZZSensorManager.m
//  WZZSensorDemo
//
//  Created by 王泽众 on 16/9/7.
//  Copyright © 2016年 wzz. All rights reserved.
//

#import "WZZMotionManager.h"

static WZZMotionManager *_instance;

@interface WZZMotionManager ()
{
    CMMotionManager * manager;
    NSTimer * timer;
    void(^_updateBlock)(WZZMotionModel *);
}

@end

@implementation WZZMotionManager

#pragma mark - 单例

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    
    return _instance;
}

+ (instancetype)sharedWZZMotionManager
{
    if (_instance == nil) {
        _instance = [[WZZMotionManager alloc] init];
        _instance->manager = [[CMMotionManager alloc] init];
        _instance->_dataModel = [[WZZMotionModel alloc] init];
    }
    
    return _instance;
}

#pragma mark - 属性
- (void)setOpenA:(BOOL)openA {
    if (_openA != openA) {
        _openA = openA;
    }
    if (_openA) {
        //开启加速度更新
        [manager startAccelerometerUpdates];
    } else {
        //关闭加速度更新
        [manager stopAccelerometerUpdates];
    }
}

- (void)setOpenXYZ:(BOOL)openXYZ {
    if (_openXYZ != openXYZ) {
        _openXYZ = openXYZ;
    }
    if (_openXYZ) {
        //开启陀螺仪更新
        [manager startGyroUpdates];
    } else {
        //关闭陀螺仪更新
        [manager stopGyroUpdates];
    }
}

- (void)setOpenNS:(BOOL)openNS {
    if (_openNS != openNS) {
        _openNS = openNS;
    }
    if (_openNS) {
        //开启磁感应更新
        [manager startMagnetometerUpdates];
    } else {
        //关闭磁感应更新
        [manager stopMagnetometerUpdates];
    }
}

#pragma mark - 方法
//开始更新数据
- (void)startUpdateWithReturnModel:(void(^)(WZZMotionModel *))updateBlock {
    //开启计时器
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateData) userInfo:nil repeats:YES];
    //计时器加入循环
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    if (_updateBlock != updateBlock) {
        _updateBlock = updateBlock;
    }
}

//停止更新数据
- (void)stopUpdate {
    [timer invalidate];
    timer = nil;
}

//刷新数据
- (void)updateData {
    if (_openA) {
        _dataModel.a = manager.accelerometerData.acceleration;
    } else {
        CMAcceleration b;
        b.x = 0;
        b.y = 0;
        b.z = 0;
        _dataModel.a = b;
    }
    if (_openXYZ) {
        _dataModel.xyz = manager.gyroData.rotationRate;
    } else {
        CMRotationRate b;
        b.x = 0;
        b.y = 0;
        b.z = 0;
        _dataModel.xyz = b;
    }
    if (_openNS) {
        _dataModel.ns = manager.magnetometerData.magneticField;
    } else {
        CMMagneticField b;
        b.x = 0;
        b.y = 0;
        b.z = 0;
        _dataModel.ns = b;
    }
    if (_updateBlock) {
        _updateBlock(_dataModel);
    }
}


@end


@implementation WZZMotionModel

@end