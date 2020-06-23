//
//  ZRCameraView.h
//  Video_IMU_Recorder
//
//  Created by Zhou,Rui(ART) on 2020/6/19.
//  Copyright © 2020 Zhou,Rui(ART). All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZRCameraView : UIView

- (instancetype)initWithFrame:(CGRect)frame captureSession:(AVCaptureSession *)session;

@end

NS_ASSUME_NONNULL_END
