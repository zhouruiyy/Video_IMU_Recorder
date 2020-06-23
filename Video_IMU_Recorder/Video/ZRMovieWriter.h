//
//  ZRMovieWriter.h
//  Video_IMU_Recorder
//
//  Created by Zhou,Rui(ART) on 2020/6/18.
//  Copyright © 2020 Zhou,Rui(ART). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZRMovieWriter : NSObject

- (instancetype)initWithFilePath:(NSString *)path videoSize:(CGSize)videoSize;
- (BOOL)encodeFrame:(CMSampleBufferRef)sampleBuffer;
- (void)startWriting:(CMTime)time;
- (void)finishWriting:(dispatch_block_t)completion;

@end

NS_ASSUME_NONNULL_END
