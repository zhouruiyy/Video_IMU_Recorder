//
//  ZRIMUData.h
//  Video_IMU_Recorder
//
//  Created by Zhou,Rui(ART) on 2020/6/22.
//  Copyright © 2020 Zhou,Rui(ART). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZRIMUData : NSObject

@property (nonatomic, assign) NSTimeInterval timeStamp;
@property (nonatomic, assign) NSTimeInterval absoluteTime;
@property (nonatomic, assign) CMAcceleration accData;
@property (nonatomic, assign) CMRotationRate gyroData;
@property (nonatomic, assign) CMMagneticField magneticData;
@property (nonatomic, assign) CMRotationMatrix rotationMatrix;

@end

NS_ASSUME_NONNULL_END
