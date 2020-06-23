//
//  NSDate+Format.m
//  Video_IMU_Recorder
//
//  Created by Zhou,Rui(ART) on 2020/6/22.
//  Copyright © 2020 Zhou,Rui(ART). All rights reserved.
//

#import "NSDate+Format.h"

@implementation NSDate (Format)

+ (NSString *)dateWithFormatterString:(NSString *)format {
    NSDate *date = [self date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:date];
}

+ (NSString *)dateWithFormatterString:(NSString *)format fromDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:date];
}

+ (NSTimeInterval)timeStampWithDate {
    NSDate *date = [self date];
    return [date timeIntervalSince1970] * 1000;
}

@end
