//
//  ZRUtils.h
//  Video_IMU_Recorder
//
//  Created by Zhou,Rui(ART) on 2020/6/18.
//  Copyright © 2020 Zhou,Rui(ART). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZRUtils : NSObject

+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;

+ (NSString *)imuDataStrFromRotationMatrix:(CMRotationMatrix)rot;

@end

NS_ASSUME_NONNULL_END
