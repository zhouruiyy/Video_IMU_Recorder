//
//  ZRLocationManager.h
//  Video_IMU_Recorder
//
//  Created by Zhou,Rui(ART) on 2020/6/18.
//  Copyright © 2020 Zhou,Rui(ART). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol ZRLocationUpdateDelegate <NSObject>

- (void)didUpdateLocations:(NSArray<CLLocation *> *_Nullable)locations;
- (void)didUpdateFailWithError:(NSError *_Nullable)error;

@end

NS_ASSUME_NONNULL_BEGIN

@interface ZRLocationManager : NSObject

@property (nonatomic, weak) id<ZRLocationUpdateDelegate> delegate;

- (void)startUpdateLocation;
- (void)stopUpdateLocation;

@end

NS_ASSUME_NONNULL_END
