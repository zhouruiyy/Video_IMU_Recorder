//
//  ZRCameraViewController.h
//  Video_IMU_Recorder
//
//  Created by Zhou,Rui(ART) on 2020/6/19.
//  Copyright © 2020 Zhou,Rui(ART). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZRCameraManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^CaptureSampleBufferOutputBlock)(CMSampleBufferRef sampleBuffer, NSString *matrixStr);

//相机识图控制器
@interface ZRCameraViewController : UIViewController

@property (nonatomic, strong) ZRCameraManager *cameraManager;
@property (nonatomic, copy) CaptureSampleBufferOutputBlock captureSampleBufferOutputBlock;

- (void)startCapture;
- (void)stopCapture;

@end

NS_ASSUME_NONNULL_END
