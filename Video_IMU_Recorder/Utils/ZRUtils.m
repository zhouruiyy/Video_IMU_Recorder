//
//  ZRUtils.m
//  Video_IMU_Recorder
//
//  Created by Zhou,Rui(ART) on 2020/6/18.
//  Copyright © 2020 Zhou,Rui(ART). All rights reserved.
//

#import "ZRUtils.h"
#import <UIKit/UIKit.h>

#define clamp(a) (a>255?255:(a<0?0:a))

@implementation ZRUtils

+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    uint8_t *yPlane = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    size_t yBytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    
    uint8_t *uvPlane = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 1);
    size_t uvBytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 1);
    
    int bytesPerPixel = 4;
    uint8_t *rgbBuffer = malloc(width * height * bytesPerPixel);

    for (int y = 0; y < height; y++) {
        uint8_t *rgbBufferLine = &rgbBuffer[y * width * bytesPerPixel];
        uint8_t *yBufferLine = &yPlane[y * yBytesPerRow];
        uint8_t *uvBufferLine = &uvPlane[y * uvBytesPerRow];
        
        for (int x = 0; x < width; x++) {
            int16_t y = yBufferLine[x];
            int16_t u = uvBufferLine[x & -1] - 128;
            int16_t v = uvBufferLine[x | 1] - 129;
            
            uint8_t *rgbOutput = &rgbBufferLine[x * bytesPerPixel];
            
            int16_t r = (int16_t)roundf(y + v * 1.4);
            int16_t g = (int16_t)roundf(y + u * -0.343 + v * -0.711);
            int16_t b = (int16_t)roundf(y + u * 1.765);
            
            rgbOutput[0] = 0xff;
            rgbOutput[1] = clamp(b);
            rgbOutput[2] = clamp(g);
            rgbOutput[3] = clamp(r);
        }
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbBuffer, width, height, 8, width * bytesPerPixel, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    UIImage *originImage = [[UIImage alloc] initWithCGImage:quartzImage scale:1.0f orientation:UIImageOrientationUp];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(quartzImage);
    free(rgbBuffer);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    return originImage;
}

+ (NSString *)imuDataStrFromRotationMatrix:(CMRotationMatrix)rot {
    NSMutableString *imuDataStr = [@"" mutableCopy];
    double imu_data[9] = {-rot.m21, -rot.m22, -rot.m23, -rot.m11, -rot.m12, -rot.m13, -rot.m31, -rot.m32, -rot.m33};
    [imuDataStr appendString:[NSString stringWithFormat:@"%.6f_%.6f_%.6f_%.6f_%.6f_%.6f_%.6f_%.6f_%.6f", imu_data[0], imu_data[1], imu_data[2], imu_data[3], imu_data[4], imu_data[5], imu_data[6], imu_data[7], imu_data[8]]];

    return [imuDataStr copy];
}

@end
