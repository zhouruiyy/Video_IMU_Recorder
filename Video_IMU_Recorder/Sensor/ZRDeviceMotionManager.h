//
//  ZRDeviceMotionManager.h
//  Video_IMU_Recorder
//
//  Created by Zhou,Rui(ART) on 2020/6/19.
//  Copyright © 2020 Zhou,Rui(ART). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define ZRDerviceDirectionChangedNotification @"ZRDerviceDirectionChangedNotification"
#define ZRActuallyOrientationChangedNotification @"ZRActuallyOrientationChangedNotification"

@protocol ZRDeviceMotionManagerDelegate <NSObject>

- (void)updateDeviceMotion:(CMDeviceMotion *)motion;

@end

@interface ZRDeviceMotionManager : NSObject
// 磁力计、加速度计回调
@property (nonatomic, copy) CMGyroHandler gyroHandler;
@property (nonatomic, copy) CMAccelerometerHandler accelerometerHandler;

// 传感器相关配置信息
@property (nonatomic, assign) float internal;
@property (nonatomic, assign) CMAttitudeReferenceFrame referenceFrame;

// 姿态旋转矩阵
@property (nonatomic, assign) CMRotationMatrix rotMatrix;

@property (assign, nonatomic) UIDeviceOrientation orientation;
@property (assign, nonatomic) UIDeviceOrientation actuallyOrientation; //实际朝向 目前只包括上下左右

+ (ZRDeviceMotionManager *)sharedInstance;

- (void)addObserver:(id<ZRDeviceMotionManagerDelegate>)observer;

- (void)removeObserver:(id<ZRDeviceMotionManagerDelegate>)observer;
- (void)removeObservers;

// 查询是否在运行
- (BOOL)isWorking;

// 开启姿态数据更新
- (BOOL)startUpdateDeviceMotion;
// 关闭姿态数据更新
- (void)stopUpdateDeviceMotion;

// 获取原始陀螺仪
- (CMRotationRate)getGyro;
// 获取原始加速度
- (CMAcceleration)getAcceleration;
// 获取磁力计
- (CMMagneticField)getMagnetic;
// 旋转角速度
- (CMRotationRate)getRotationRate;

@end

NS_ASSUME_NONNULL_END
