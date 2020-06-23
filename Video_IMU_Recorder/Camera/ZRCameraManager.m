//
//  ZRCameraManager.m
//  Video_IMU_Recorder
//
//  Created by Zhou,Rui(ART) on 2020/6/18.
//  Copyright © 2020 Zhou,Rui(ART). All rights reserved.
//

#import "ZRCameraManager.h"
#import <AVFoundation/AVFoundation.h>

@interface ZRCameraManager ()

@property (nonatomic, strong) AVCaptureSession *avCaptureSession;
@property (nonatomic, strong) AVCaptureDevice *avCaptureDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *avCaptureDeviceInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *avCaptureVideoDataOutput;
@property (nonatomic, weak) id<AVCaptureVideoDataOutputSampleBufferDelegate> delegate;
@property (nonatomic, strong) AVCaptureConnection *videoConnection;
@property (nonatomic, strong) dispatch_queue_t videoQueue;

@end

@implementation ZRCameraManager

- (instancetype)init {
    if (self = [super init]) {
        _avCaptureDevice = [[self class] getBackCamera];
    }
    
    return self;
}

+ (BOOL)cameraAuthorized {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    return authStatus == AVAuthorizationStatusAuthorized;
}

- (void)setCaptureDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)delegate {
    self.delegate = delegate;
    
    [self setupSession];
}

#pragma mark - setup session

- (void)setupSession {
    NSError *error = nil;
    
    AVCaptureDeviceInput *deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.avCaptureDevice error:&error];
    self.avCaptureDeviceInput = deviceInput;
    
    if (!self.avCaptureDeviceInput) {
        self.avCaptureDevice = nil;
        return;
    }
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    self.avCaptureSession = session;
    
    [self.avCaptureSession beginConfiguration];
    
    if ([self.avCaptureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        self.avCaptureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    } else {
        return;
    }
    
    if ([self.avCaptureSession canAddInput:self.avCaptureDeviceInput]) {
        [self.avCaptureSession addInput:self.avCaptureDeviceInput];
    } else {
        self.avCaptureSession = nil;
        self.avCaptureDevice = nil;
        self.avCaptureDeviceInput = nil;
        return;
    }
    
    AVCaptureVideoDataOutput *avCaptureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    NSDictionary *settings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    avCaptureVideoDataOutput.videoSettings = settings;
    avCaptureVideoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    self.avCaptureVideoDataOutput = avCaptureVideoDataOutput;
    
    self.videoQueue = dispatch_queue_create("com.video.queue", DISPATCH_QUEUE_SERIAL);
    [self.avCaptureVideoDataOutput setSampleBufferDelegate:self.delegate queue:self.videoQueue];
    
    if ([self.avCaptureSession canAddOutput:self.avCaptureVideoDataOutput])
    {
        [self.avCaptureSession addOutput:self.avCaptureVideoDataOutput];
    }
    else
    {
        [self.avCaptureSession removeInput:self.avCaptureDeviceInput];
        self.avCaptureDeviceInput = nil;
        self.avCaptureVideoDataOutput = nil;
        self.avCaptureSession = nil;
        self.avCaptureDevice = nil;
        return;
    }
    
    [self.avCaptureSession commitConfiguration];
    
    self.videoConnection = [self.avCaptureVideoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    self.videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    if (@available(iOS 11.0, *)) {
        if (self.videoConnection.isCameraIntrinsicMatrixDeliverySupported) {
            self.videoConnection.cameraIntrinsicMatrixDeliveryEnabled = YES;
        }
    }
}

+ (AVCaptureDevice *)getBackCamera
{
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in cameras)
    {
        if (device.position == AVCaptureDevicePositionBack)
        {
            return device;
        }
    }
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

+ (AVCaptureDevice *)getFrontCamera
{
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in cameras)
    {
        if (device.position == AVCaptureDevicePositionFront)
            return device;
    }
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

- (void)startCapture {
    if (self.avCaptureSession) {
        if (self.avCaptureSession.running == NO) {
            [self.avCaptureSession startRunning];
        }
    }
}

- (void)stopCapture {
    if (self.avCaptureSession) {
        [self.avCaptureSession stopRunning];
    }
}

- (AVCaptureSession *)getCaptureSession {
    return self.avCaptureSession;
}

@end
