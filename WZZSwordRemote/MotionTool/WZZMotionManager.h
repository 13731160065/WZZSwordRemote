//
//  WZZSensorManager.h
//  WZZSensorDemo
//
//  Created by 王泽众 on 16/9/7.
//  Copyright © 2016年 wzz. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreMotion;
@import SceneKit;
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
 手机方向
 */
@property (nonatomic, assign) BOOL openAcc;

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

/**
 重置方位和旋转
 */
- (void)resetDataModelPR;

@end


@interface WZZMotionModel : NSObject

/**
 旋转
 */
@property (nonatomic, assign) SCNVector3 rotation;

/**
 空间位置
 */
@property (nonatomic, assign) SCNVector3 position;

/**
 手机方向
 */
@property (assign, nonatomic) CMAcceleration acc;

/**
 空间加速度
 */
@property (nonatomic, assign) CMAcceleration a;

/**
 角速度
 */
@property (assign, nonatomic) CMRotationRate xyz;

/**
 磁感
 */
@property (assign, nonatomic) CMMagneticField ns;

@end
