//
//  ZRVideoOutputFrameData.m
//  Video_IMU_Recorder
//
//  Created by Zhou,Rui(ART) on 2020/6/18.
//  Copyright © 2020 Zhou,Rui(ART). All rights reserved.
//

#import "ZRVideoOutputFrameData.h"

@implementation ZRVideoOutputFrameData

- (instancetype)initWithVideoOutputFrameData:(size_t)width
                                      height:(size_t)height
                                 bytesPerRow:(int)bytesPerRow
                                       bytes:(unsigned char *)bytes
                            bytesNeedRelease:(BOOL)bytesNeedRelease
                                   imageData:(NSData *)imageData {
    if (self = [super init]) {
        _width = width;
        _height = height;
        _bytesPerRow = bytesPerRow;
        size_t length = width * height;
        unsigned char *temp = (unsigned char *)malloc(length);
        memcpy(temp, bytes, length);
        _bytes = temp;
        _bytesNeedRelease = bytesNeedRelease;
        _imageData = [[NSData alloc] initWithData:imageData];
    }
    
    return self;
}

- (void)dealloc {
    if (self.bytesNeedRelease) {
        free(self.bytes);
    }
}

@end
