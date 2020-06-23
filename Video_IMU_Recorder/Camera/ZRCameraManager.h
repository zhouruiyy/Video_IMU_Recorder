//
//  ZRCameraManager.h
//  Video_IMU_Recorder
//
//  Created by Zhou,Rui(ART) on 2020/6/18.
//  Copyright © 2020 Zhou,Rui(ART). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZRCameraManager : NSObject

+ (BOOL)cameraAuthorized;

- (void)setCaptureDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)delegate;

- (void)startCapture;

- (void)stopCapture;

- (AVCaptureSession *)getCaptureSession;

@end

NS_ASSUME_NONNULL_END
