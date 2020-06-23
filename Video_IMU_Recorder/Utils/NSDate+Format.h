//
//  NSDate+Format.h
//  Video_IMU_Recorder
//
//  Created by Zhou,Rui(ART) on 2020/6/22.
//  Copyright © 2020 Zhou,Rui(ART). All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Format)

+ (NSString *)dateWithFormatterString:(NSString *)format;

+ (NSString *)dateWithFormatterString:(NSString *)format fromDate:(NSDate *)date;

+ (NSTimeInterval)timeStampWithDate;

@end

NS_ASSUME_NONNULL_END
