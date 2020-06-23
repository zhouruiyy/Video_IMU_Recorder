//
//  ZRVideoOutputFrameData.h
//  Video_IMU_Recorder
//
//  Created by Zhou,Rui(ART) on 2020/6/18.
//  Copyright © 2020 Zhou,Rui(ART). All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZRVideoOutputFrameData : NSObject

@property (nonatomic, assign) size_t width;
@property (nonatomic, assign) size_t height;
@property (nonatomic, assign) int bytesPerRow;
@property (nonatomic, assign) size_t size;
@property (nonatomic, strong) NSData *imageData;
@property (nonatomic, assign) unsigned char *bytes;
@property (nonatomic, assign) BOOL bytesNeedRelease;

- (instancetype)initWithVideoOutputFrameData:(size_t)width
                                      height:(size_t)height
                                 bytesPerRow:(int)bytesPerRow
                                       bytes:(unsigned char *)bytes
                            bytesNeedRelease:(BOOL)bytesNeedRelease
                                   imageData:(NSData *)imageData;

@end

NS_ASSUME_NONNULL_END
