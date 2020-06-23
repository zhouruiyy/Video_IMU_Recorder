//
//  ZRCameraViewController.m
//  Video_IMU_Recorder
//
//  Created by Zhou,Rui(ART) on 2020/6/19.
//  Copyright © 2020 Zhou,Rui(ART). All rights reserved.
//

#import "ZRCameraViewController.h"
#import "ZRCameraView.h"
#import "Video_IMU_Recorder-Swift.h"

@interface ZRCameraViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) ZRCameraView *cameraView;

@end

@implementation ZRCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupCameraView];
}

- (void)setupCameraView {
    _cameraView = [[ZRCameraView alloc] initWithFrame:self.view.frame captureSession:[self.cameraManager getCaptureSession]];
    [self.view addSubview:_cameraView];
}

#pragma mark - action

- (void)startCapture {
    [self.cameraManager startCapture];
}

- (void)stopCapture {
    [self.cameraManager stopCapture];
}

#pragma mark - delegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    NSString *matrixStr = [[ZRCamerIntrinsicMatrix getCameraIntrinsicMatrixFromSampleBufferWithSampleBuffer:sampleBuffer] copy];
    
    if (self.captureSampleBufferOutputBlock) {
        self.captureSampleBufferOutputBlock(sampleBuffer, matrixStr);
    }
}

@end
