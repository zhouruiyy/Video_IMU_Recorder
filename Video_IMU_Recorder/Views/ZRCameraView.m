//
//  ZRCameraView.m
//  Video_IMU_Recorder
//
//  Created by Zhou,Rui(ART) on 2020/6/19.
//  Copyright © 2020 Zhou,Rui(ART). All rights reserved.
//

#import "ZRCameraView.h"

@interface ZRCameraView()

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureSession *avCaptureSession;

@end

@implementation ZRCameraView

- (instancetype)initWithFrame:(CGRect)frame captureSession:(AVCaptureSession *)session {
    if (self = [super initWithFrame:frame]) {
        _avCaptureSession = session;
        [self setupViews];
    }
    
    return self;
}

- (void)layoutSubviews {
    _previewLayer.frame = self.frame;
}

- (void)setupViews {
    if (!_previewLayer) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_avCaptureSession];
    }
    
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    [self.layer addSublayer:_previewLayer];
}



@end
