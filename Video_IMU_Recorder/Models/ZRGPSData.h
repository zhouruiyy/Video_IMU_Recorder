//
//  ZRGPSData.h
//  Video_IMU_Recorder
//
//  Created by Zhou,Rui(ART) on 2020/6/22.
//  Copyright © 2020 Zhou,Rui(ART). All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZRGPSData : NSObject

@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) long timeStamp;
@property (nonatomic, copy) NSString *gpsTimeStampDataPath;

@end

NS_ASSUME_NONNULL_END
