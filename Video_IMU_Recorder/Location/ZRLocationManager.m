//
//  ZRLocationManager.m
//  Video_IMU_Recorder
//
//  Created by Zhou,Rui(ART) on 2020/6/18.
//  Copyright © 2020 Zhou,Rui(ART). All rights reserved.
//

#import "ZRLocationManager.h"

@interface ZRLocationManager()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation ZRLocationManager

- (instancetype)init {
    if (self = [super init]) {
        [self initLocationManager];
    }
    
    return self;
}

- (void)initLocationManager {
    if ([CLLocationManager locationServicesEnabled]) {
        if (!_locationManager) {
            _locationManager = [[CLLocationManager alloc] init];
        }
        
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        
        if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [_locationManager requestAlwaysAuthorization];
            [_locationManager requestWhenInUseAuthorization];
        }
    }
}

- (void)startUpdateLocation {
    [self.locationManager startUpdatingLocation];
}

- (void)stopUpdateLocation {
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateLocations:)]) {
        [self.delegate didUpdateLocations:locations];
    }
}
 
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateFailWithError:)]) {
        [self.delegate didUpdateFailWithError:error];
    }
}

@end
