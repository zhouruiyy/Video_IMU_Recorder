//
//  ZRDeviceMotionManager.m
//  Video_IMU_Recorder
//
//  Created by Zhou,Rui(ART) on 2020/6/19.
//  Copyright © 2020 Zhou,Rui(ART). All rights reserved.
//

#import "ZRDeviceMotionManager.h"

#define TRIGGER_THREADHOLD (GLKMathDegreesToRadians(15))
#define kZRDerviceDirectionMonitorRatioFourDirection 0.88
#define kZRDerviceDirectionMonitorRatioFaceUpOrDown 0.5

@interface ZRDeviceMotionManager()

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) NSMutableArray *updateObservers;
@property (nonatomic, strong) NSOperationQueue *updateQueue;
@property (nonatomic, assign) BOOL isWorking;

@end

@implementation ZRDeviceMotionManager

+ (ZRDeviceMotionManager *)sharedInstance {
    static ZRDeviceMotionManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZRDeviceMotionManager alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _updateObservers = [@[] mutableCopy];
        _internal = 1.0 / 100;
        _referenceFrame = CMAttitudeReferenceFrameXArbitraryZVertical;
    }
    
    return self;
}

- (BOOL)isWorking {
    return _isWorking;
}

- (CMMotionManager *)motionManager {
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    return _motionManager;
}

- (void)addObserver:(id<ZRDeviceMotionManagerDelegate>)observer {
    [self.updateObservers addObject:observer];
}

- (void)removeObserver:(id<ZRDeviceMotionManagerDelegate>)observer {
    if ([self.updateObservers containsObject:observer]) {
        [self.updateObservers removeObject:observer];
    }
}

- (void)removeObservers {
    [self.updateObservers removeAllObjects];
}

- (BOOL)startUpdateDeviceMotion {
    if (self.isWorking) {
        [self stopUpdateDeviceMotion];
    }
    if (![self.motionManager isDeviceMotionAvailable]) {
        return NO;
    }
    if ([self.motionManager isDeviceMotionActive]) {
        return NO;
    }
    
    self.motionManager.gyroUpdateInterval = self.internal;
    self.motionManager.accelerometerUpdateInterval = self.internal;
    self.motionManager.deviceMotionUpdateInterval = self.internal;
    self.motionManager.magnetometerUpdateInterval = self.internal;
    
    [self.motionManager startMagnetometerUpdates];
    
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
         if (self.accelerometerHandler) {
             self.accelerometerHandler(accelerometerData, error);
         }
     }];
    
    [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
        if (self.gyroHandler) {
            self.gyroHandler(gyroData, error);
        }
    }];
    
    __weak typeof(self) weakSelf = self;
    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:self.referenceFrame
                                                            toQueue:self.updateQueue
                                                        withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        for (id observe in weakSelf.updateObservers) {
            id<ZRDeviceMotionManagerDelegate> item = (id<ZRDeviceMotionManagerDelegate>)observe;
            if ([item respondsToSelector:@selector(updateDeviceMotion:)]) {
                [item updateDeviceMotion:motion];
            }
        }
        
        [weakSelf gravityUpdated:motion.gravity];
    }];
    
    self.isWorking = YES;
    return YES;
}

- (void)stopUpdateDeviceMotion {
    if (!self.isWorking) {
        return;
    }
    [self.motionManager stopDeviceMotionUpdates];
    [self.motionManager stopGyroUpdates];
    [self.motionManager stopMagnetometerUpdates];
    [self.motionManager stopAccelerometerUpdates];
    self.isWorking = NO;
}

- (void)gravityUpdated:(CMAcceleration)gravity {
    double x = gravity.x;
    double y = gravity.y;
    double z = gravity.z;
    
    UIDeviceOrientation orientation = UIDeviceOrientationUnknown;
    double ratio = MAXFLOAT;
    if (z > kZRDerviceDirectionMonitorRatioFaceUpOrDown || z <  - kZRDerviceDirectionMonitorRatioFaceUpOrDown || UIDeviceOrientationFaceUp == _orientation || UIDeviceOrientationFaceDown == _orientation ) {
        ratio = kZRDerviceDirectionMonitorRatioFaceUpOrDown;
    } else {
        ratio = kZRDerviceDirectionMonitorRatioFourDirection;
    }
    if ( x > ratio ) {
        orientation = UIDeviceOrientationLandscapeRight;
    }
    else if ( x < - ratio ) {
        orientation = UIDeviceOrientationLandscapeLeft;
    }
    else if (y < - ratio) {
        orientation = UIDeviceOrientationPortrait;
    }
    else if (y > ratio) {
        orientation = UIDeviceOrientationPortraitUpsideDown;
    }
    else if (z < - ratio) {
        orientation = UIDeviceOrientationFaceUp;
    }
    else if (z > ratio) {
        orientation = UIDeviceOrientationFaceDown;
    }
    else {
        
    }
    
    if (_orientation != orientation && UIDeviceOrientationUnknown != orientation && orientation != UIDeviceOrientationFaceUp && orientation != UIDeviceOrientationFaceDown && orientation != UIDeviceOrientationPortraitUpsideDown) {
        _orientation = orientation;
        [[NSNotificationCenter defaultCenter] postNotificationName:ZRDerviceDirectionChangedNotification object:[NSNumber numberWithInteger:orientation]];
    }
    
    UIDeviceOrientation actuallyOrientation = UIDeviceOrientationUnknown;
    if (fabs(y) >= fabs(x)){
        if (y >= 0){
            actuallyOrientation =  UIDeviceOrientationPortraitUpsideDown;
        }
        else{
            actuallyOrientation = UIDeviceOrientationPortrait;
        }
    }
    else{
        if (x >= 0){
            actuallyOrientation =  UIDeviceOrientationLandscapeRight;
        }
        else{
            actuallyOrientation = UIDeviceOrientationLandscapeLeft;
        }
    }
    if(_actuallyOrientation != actuallyOrientation){
        _actuallyOrientation = actuallyOrientation;
        [[NSNotificationCenter defaultCenter] postNotificationName:ZRActuallyOrientationChangedNotification object:[NSNumber numberWithInteger:actuallyOrientation]];
    }
}


- (CMRotationRate)getGyro {
    return self.motionManager.gyroData.rotationRate;
}

- (CMAcceleration)getAcceleration {
    return self.motionManager.accelerometerData.acceleration;
}

- (CMMagneticField)getMagnetic {
    return self.motionManager.magnetometerData.magneticField;
}

- (CMRotationRate)getRotationRate {
    return self.motionManager.deviceMotion.rotationRate;
}

- (CMRotationMatrix)rotMatrix {
    return self.motionManager.deviceMotion.attitude.rotationMatrix;
}

@end
