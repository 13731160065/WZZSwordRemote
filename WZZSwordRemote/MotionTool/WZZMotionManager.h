//
//  WZZSensorManager.h
//  WZZSensorDemo
//
//  Created by 王泽众 on 16/9/7.
//  Copyright © 2016年 wzz. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreMotion;
@class WZZMotionModel;

@interface WZZMotionManager : NSObject

/**
 获取对象
 */
+ (instancetype)sharedWZZMotionManager;

/**
 加速度器
 */
@property (assign, nonatomic) BOOL openA;

/**
 陀螺仪
 */
@property (assign, nonatomic) BOOL openXYZ;

/**
 磁感
 */
@property (assign, nonatomic) BOOL openNS;

/**
 数据模型
 */
@property (strong, nonatomic) WZZMotionModel * dataModel;

/**
 开始更新数据
 */
- (void)startUpdateWithReturnModel:(void(^)(WZZMotionModel * dataModel))updateBlock;

/**
 停止更新数据
 */
- (void)stopUpdate;

@end


@interface WZZMotionModel : NSObject

/**
 加速度
 */
@property (assign, nonatomic) CMAcceleration a;

/**
 陀螺仪
 */
@property (assign, nonatomic) CMRotationRate xyz;

/**
 磁感
 */
@property (assign, nonatomic) CMMagneticField ns;

@end