//
//  ZRMovieWriter.m
//  Video_IMU_Recorder
//
//  Created by Zhou,Rui(ART) on 2020/6/18.
//  Copyright © 2020 Zhou,Rui(ART). All rights reserved.
//

#import "ZRMovieWriter.h"

@implementation ZRMovieWriter {
    AVAssetWriter *_writer;
    AVAssetWriterInput *_videoInput;
    
    NSString *_filePath;
    CGSize _videoSize;
}

- (instancetype)initWithFilePath:(NSString *)path videoSize:(CGSize)videoSize {
    if (self = [super init]) {
        _filePath = path;
        _videoSize = videoSize;
        [self setupWriter];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"ZRMovieWriter dealloc");
}

- (void)setupWriter {
    [[NSFileManager defaultManager] removeItemAtPath:_filePath error:nil];
    NSURL* url = [NSURL fileURLWithPath:_filePath];
    _writer = [AVAssetWriter assetWriterWithURL:url fileType:AVFileTypeMPEG4 error:nil];
    _writer.shouldOptimizeForNetworkUse = YES;
    
    //录制视频的一些配置，分辨率，编码方式等等
    NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
                             AVVideoCodecH264, AVVideoCodecKey,
                             [NSNumber numberWithInteger:_videoSize.width], AVVideoWidthKey,
                             [NSNumber numberWithInteger:_videoSize.height], AVVideoHeightKey,
                             nil];
    //初始化视频写入类
    _videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:settings];
    //表明输入是否应该调整其处理为实时数据源的数据
    _videoInput.expectsMediaDataInRealTime = YES;
    //将视频输入源加入
    [_writer addInput:_videoInput];
}

- (void)startWriting:(CMTime)time {
    //写入状态为未知,保证视频先写入
    if (_writer.status == AVAssetWriterStatusUnknown) {
        //开始写入
        [_writer startWriting];
        [_writer startSessionAtSourceTime:time];
    }
}

- (void)finishWriting:(dispatch_block_t)completion {
    [_writer finishWritingWithCompletionHandler:completion];
}

//通过这个方法写入数据
- (BOOL)encodeFrame:(CMSampleBufferRef)sampleBuffer {
    //数据是否准备写入
    if (CMSampleBufferDataIsReady(sampleBuffer)) {
        //写入失败
        if (_writer.status == AVAssetWriterStatusFailed) {
            NSLog(@"writer error %@", _writer.error.localizedDescription);
            return NO;
        }
        //视频输入是否准备接受更多的媒体数据
        if (_videoInput.readyForMoreMediaData == YES) {
            //拼接数据
            [_videoInput appendSampleBuffer:sampleBuffer];
            return YES;
        }
    }
    return NO;
}

@end
