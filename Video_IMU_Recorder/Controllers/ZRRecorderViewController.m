//
//  ZRRecorderViewController.m
//  Video_IMU_Recorder
//
//  Created by Zhou,Rui(ART) on 2020/6/17.
//  Copyright © 2020 Zhou,Rui(ART). All rights reserved.
//

#import "ZRRecorderViewController.h"
#import "ZRCameraViewController.h"
#import "ZRMovieWriter.h"
#import "ZRLocationManager.h"
#import "ZRDeviceMotionManager.h"
#import "UIView+Toast.h"
#import "ZRBaseView.h"
#import "NSDate+Format.h"
#import "ZRIMUData.h"
#import "ZRGPSData.h"
#import "ZRUtils.h"
#import "ZRMovieWriter.h"

static const NSString *preGPSFileName = @"gps_vs_system_time";
static const NSString *lastGPSFileName = @"last_gps_vs_system_time.txt";

@interface ZRRecorderViewController ()<ZRLocationUpdateDelegate>

@property (nonatomic, strong) ZRCameraViewController *cameraVC;
@property (nonatomic, strong) ZRMovieWriter *movieWriter;
@property (nonatomic, strong) ZRLocationManager *locationManager;

@property (nonatomic, strong) ZRBaseView *baseView;

@property (nonatomic, strong) ZRGPSData *gpsData;
@property (nonatomic, strong) ZRIMUData *imuData;

@property (nonatomic, copy) NSString *gpsTimeStampDataPath;
@property (nonatomic, copy) NSString *matrixDataPath;
@property (nonatomic, copy) NSString *imuDataPath;
@property (nonatomic, copy) NSString *videoPath;

//
@property (nonatomic, assign) BOOL recording;
@property (nonatomic, assign) BOOL snapshotting;
@property (nonatomic, assign) BOOL isInitializedRecorder;

@property (nonatomic, assign) BOOL isClickSyncTimeBtn;
@property (nonatomic, assign) BOOL isFirstGpsUpdate;
@property (nonatomic, assign) long lastGpsTimeStamp;
@property (nonatomic, assign) int frameIndex;

@property (nonatomic, strong) NSMutableString *imuDataStr;
@property (nonatomic, strong) NSMutableString *matrixDataStr;

@end

@implementation ZRRecorderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupBaseView];
    [self setupCameraVC];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // sensor
    [[ZRDeviceMotionManager sharedInstance] startUpdateDeviceMotion];
    // camera
    [self.cameraVC startCapture];
    __weak typeof(self) weakSelf = self;
    [self.cameraVC setCaptureSampleBufferOutputBlock:^(CMSampleBufferRef sampleBuffer, NSString *matrixStr) {
        [weakSelf setBufferFrame:sampleBuffer matrixStr:matrixStr];
    }];
    
    // gps
    [self.locationManager startUpdateLocation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // sensor
    [[ZRDeviceMotionManager sharedInstance] stopUpdateDeviceMotion];
    // camera
    [self.cameraVC stopCapture];
    // gps
    [self.locationManager stopUpdateLocation];
}

#pragma mark - ui & event

- (void)setupBaseView {
    self.baseView = [[ZRBaseView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.baseView];
    
    __weak typeof(self) weakSelf = self;
    self.baseView.clickEventHandler = ^(ZRClickEventType type, NSDictionary * _Nullable data) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        switch (type) {
            case ZRClickEventTypeClose:
                [strongSelf back:nil];
                break;
            case ZRClickEventTypeStop:
                [strongSelf stop:nil];
                break;
            case ZRClickEventTypeRemove:
                [strongSelf remove:nil];
                break;
            case ZRClickEventTypeRecord:
                [strongSelf record:nil];
                break;
            case ZRClickEventTypeShare:
                [strongSelf share];
                break;
            case ZRClickEventTypeSyncTime:
                [strongSelf syncTime:nil];
                break;
            default:
                break;
        }
    };
}

- (void)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)remove:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确定删除吗？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:DocumentsPath];
        for (NSString *fileName in enumerator) {
            [[NSFileManager defaultManager] removeItemAtPath:[DocumentsPath stringByAppendingPathComponent:fileName] error:nil];
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)record:(id)sender {
    if (self.recording) {
        return;
    }
    self.recording = YES;
    self.baseView.recordStatusView.text = @"正在录制";
    [self.view makeToast:@"开始录制" duration:1.0 position:CSToastPositionCenter];
}

- (void)stop:(id)sender {
    if (!self.recording) {
        return;
    }
    self.recording = NO;
    self.baseView.recordStatusView.text = @"未录制";
    [self.view makeToast:@"停止录制" duration:1.0 position:CSToastPositionCenter];
}

- (void)share {
    // 获取当前document目录下文件
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSDictionary *files = [self getTxtAndVideoFilePath:documentsDirectory];
    
    NSString *shareMessage = @"Hey! Here is the interesting videos. #Tag";
    NSMutableArray *shareItems = [NSMutableArray arrayWithObjects:shareMessage, nil];
    
    NSArray *txtArr = [files objectForKey:@"txt"];
    if (txtArr && [txtArr count] > 0) {
        for (NSString *str in txtArr) {
            NSURL *filePath = [NSURL fileURLWithPath:str];
            [shareItems addObject:filePath];
        }
    }
    
    NSArray *mp4Arr = [files objectForKey:@"mp4"];
    if (mp4Arr && [mp4Arr count] > 0) {
        for (NSString *str in mp4Arr) {
            NSURL *filePath = [NSURL fileURLWithPath:str];
            [shareItems addObject:filePath];
        }
    }
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypeMessage, UIActivityTypeCopyToPasteboard];
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (NSDictionary *)getTxtAndVideoFilePath:(NSString *)path {
    NSMutableArray *txtArr = [NSMutableArray array];
    NSMutableArray *mp4Arr = [NSMutableArray array];
    NSMutableDictionary *fileDic = [NSMutableDictionary dictionary];
    
    NSFileManager * fileManger = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
    if (isExist) {
        NSArray * dirArray = [fileManger contentsOfDirectoryAtPath:path error:nil];
        NSString * subPath = nil;
        for (NSString * str in dirArray) {
            subPath = [path stringByAppendingPathComponent:str];
            if ([str hasSuffix:@".txt"]) {
                [txtArr addObject:subPath];
            }
            if ([str hasSuffix:@".mp4"] || [str hasSuffix:@".mov"]) {
                [mp4Arr addObject:subPath];
            }
        }
        [fileDic setObject:txtArr forKey:@"txt"];
        [fileDic setObject:mp4Arr forKey:@"mp4"];
    }else{
        NSLog(@"this path is not exist!");
    }
    
    return [fileDic copy];
}

- (void)syncTime:(id)sender {
    // time
    NSString *dateString = [NSDate dateWithFormatterString:@"yyyy_MM_dd_HH_mm_ss"];
    long timeStamp = [NSDate timeStampWithDate];
    self.gpsData.timeStamp = timeStamp;
    NSString *syncTime = [NSString stringWithFormat:@"%ld", timeStamp];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [syncTime writeToFile:[self lastRecordSystemTimeStampFilePath] atomically:NO encoding:NSUTF8StringEncoding error:nil];
    });
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject];
    NSString *dataPath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.txt", preGPSFileName, dateString]];
    
    self.gpsTimeStampDataPath = [dataPath stringByAppendingPathComponent:@""];
    self.baseView.gpsTimeStampView.text = [NSString stringWithFormat:@"上次同步系统时间:\n%@",dateString];
    self.isClickSyncTimeBtn = YES;
}

#pragma mark - camera

- (void)setupCameraVC {
    ZRCameraManager *cameraManager = [[ZRCameraManager alloc] init];
    self.cameraVC = [[ZRCameraViewController alloc] init];
    [cameraManager setCaptureDelegate:self.cameraVC];
    self.cameraVC.cameraManager = cameraManager;
    [self.view insertSubview:self.cameraVC.view atIndex:0];
}

#pragma mark - data

- (ZRGPSData *)gpsData {
    if (!_gpsData) {
        _gpsData = [[ZRGPSData alloc] init];
    }
    return _gpsData;
}

- (ZRIMUData *)imuData {
    if (!_imuData) {
        _imuData = [[ZRIMUData alloc] init];
    }
    return _imuData;
}

#pragma mark - preread timestamp

- (void)prereadSystemTimeStamp {
    NSString *filePath = [self lastRecordSystemTimeStampFilePath];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if (![fileMgr fileExistsAtPath:filePath]) {
        self.baseView.gpsTimeStampView.text = [NSString stringWithFormat:@"上次同步系统时间:无"];;
        return;
    }

    NSString *data = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSTimeInterval timeStamp = [data doubleValue] / 1000.0;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    NSString *dateString = [NSDate dateWithFormatterString:@"yyyy_MM_dd_HH_mm_ss" fromDate:date];
    self.baseView.gpsTimeStampView.text = [NSString stringWithFormat:@"上次同步系统时间:\n%@",dateString];;
}

- (NSString *)lastRecordSystemTimeStampFilePath {
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject];
    NSString *filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", lastGPSFileName]];
    return filePath;
}

#pragma mark - location protocol

- (void)didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (self.isFirstGpsUpdate) {
        [self syncTime:nil];
    }
    CLLocation * currentLocation = [locations lastObject];

    self.gpsData.latitude = currentLocation.coordinate.latitude;
    self.gpsData.longitude = currentLocation.coordinate.longitude;
    NSDate *timeStamp = currentLocation.timestamp;
    
    NSLog(@"latitude: %f, longitude:%f, timeStamp:%@", self.gpsData.latitude, self.gpsData.longitude, timeStamp);
    
    long gpsTimeStamp = [timeStamp timeIntervalSince1970] * 1000;
    dispatch_async(dispatch_get_main_queue(), ^{
        long data = gpsTimeStamp - self.lastGpsTimeStamp;
        self.baseView.gpsUpdateView.text = [NSString stringWithFormat:@"GPS刷新频率:%ld毫秒", data];
        self.baseView.gpsTimeStampCallBackView.text = [NSString stringWithFormat:@"回调GPS时间戳:%ld", gpsTimeStamp];
        self.lastGpsTimeStamp = gpsTimeStamp;
    });
    
    [self writeTimeStamp:gpsTimeStamp];
    self.isFirstGpsUpdate = NO;
}

- (void)didUpdateFailWithError:(NSError *)error {
    NSLog(@"%@", error);
    if (error.code == kCLErrorDenied) {
        NSLog(@"%@", error);
    }
}

#pragma mark - write to file

- (void)writeGPSTimeStampAndSystemTimeStampToFile:(long)gpsTS systemTS:(long)systemTS {
    NSString *data = [NSString stringWithFormat:@"%ld  %ld", gpsTS, systemTS];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [data writeToFile:self.gpsTimeStampDataPath atomically:NO encoding:NSUTF8StringEncoding error:nil];
    });
}

- (void)writeTimeStamp:(long)gpsTimeStamp {
    if (self.isClickSyncTimeBtn || self.isFirstGpsUpdate) {
        [self writeGPSTimeStampAndSystemTimeStampToFile:gpsTimeStamp systemTS:self.gpsData.timeStamp];
        self.isClickSyncTimeBtn = NO;
    }
}

#pragma mark - handle sampleBuffer imu

- (void)setBufferFrame:(CMSampleBufferRef)sampleBuffer matrixStr:(NSString *)matrixStr {
    
    if (self.snapshotting) {
        CMRotationMatrix rot = [[ZRDeviceMotionManager sharedInstance] rotMatrix];
        NSString *temp = [ZRUtils imuDataStrFromRotationMatrix:rot];
        [self.imuDataStr appendString:temp];
        self.snapshotting = NO;
    }
    
    if (self.recording) {
        @autoreleasepool {
            if (sampleBuffer != nil) {
                NSTimeInterval timeStamp = [NSDate timeStampWithDate];
                
                if (!self.isInitializedRecorder) {
                    [self initData];
                    [self initMovieWriterAndStartRecord:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
                    self.isInitializedRecorder = YES;
                    return;
                }
                
                CMRotationMatrix rot = [[ZRDeviceMotionManager sharedInstance] rotMatrix];
                NSString *temp = [ZRUtils imuDataStrFromRotationMatrix:rot];
                int index = ++_frameIndex;
                [self.imuDataStr appendString:[NSString stringWithFormat:@"%.3f %05d %@\n", timeStamp, index, temp]];
                [self.matrixDataStr appendString:[NSString stringWithFormat:@"%.3f %05d %@\n", timeStamp, index, matrixStr]];
                
                [self.movieWriter encodeFrame:sampleBuffer];
            }
                
        }
    } else {
        if (self.isInitializedRecorder) {
            [ZRDeviceMotionManager sharedInstance].accelerometerHandler = nil;
            [ZRDeviceMotionManager sharedInstance].gyroHandler = nil;
        }
        
        [_imuDataStr writeToFile:_imuDataPath atomically:NO encoding:NSUTF8StringEncoding error:nil];
        [_matrixDataStr writeToFile:_matrixDataPath atomically:NO encoding:NSUTF8StringEncoding error:nil];

        [_movieWriter finishWriting:^{
           
        }];

        [self resetInitialData];
    }
}

#pragma mark - setup init & reset

- (void)initData {
    _frameIndex = 0;
    _imuDataStr = [@"" mutableCopy];
    _matrixDataStr = [@"" mutableCopy];

    NSString *dateString = [NSDate dateWithFormatterString:@"yyyy_MM_dd_HH_mm_ss"];
    _imuDataPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@_imu.txt", dateString]];
    _videoPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@_video.mp4", dateString]];
    _matrixDataPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@_matrix.txt", dateString]];
}

- (void)initMovieWriterAndStartRecord:(CMTime)time {
    _movieWriter = [[ZRMovieWriter alloc] initWithFilePath:_videoPath videoSize:CGSizeMake(720, 1280)];
    [_movieWriter startWriting:time];
}

- (void)resetInitialData {
    _frameIndex = 0;
    _imuDataStr = nil;
    _movieWriter = nil;
    _imuDataPath = nil;
    _isInitializedRecorder = NO;
}

@end
