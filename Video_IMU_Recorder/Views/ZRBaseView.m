//
//  ZRBaseView.m
//  Video_IMU_Recorder
//
//  Created by Zhou,Rui(ART) on 2020/6/19.
//  Copyright © 2020 Zhou,Rui(ART). All rights reserved.
//

#import "ZRBaseView.h"

@implementation ZRBaseView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    
    CGRect bounds = [UIScreen mainScreen].bounds;
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backButton setTitle:@"返回" forState:UIControlStateNormal];
    self.backButton.backgroundColor = [UIColor lightGrayColor];
    [self.backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.backButton setFrame:CGRectMake(20, 20, 70, 40)];
    [self.backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.backButton];
    
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    self.deleteButton.backgroundColor = [UIColor lightGrayColor];
    [self.deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.deleteButton.frame = CGRectMake(20, bounds.size.height - 50, 70, 40);
    [self.deleteButton addTarget:self action:@selector(remove:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.deleteButton];
    
    self.recordButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.recordButton setTitle:@"录制" forState:UIControlStateNormal];
    self.recordButton.frame = CGRectMake(30, bounds.size.height - 180, bounds.size.width - 60, 40);
    self.recordButton.backgroundColor = [UIColor lightGrayColor];
    [self.recordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.recordButton addTarget:self action:@selector(record:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.recordButton];
    
    self.matrixTextView = [[UITextView alloc] initWithFrame:CGRectMake(100, 50, bounds.size.width - 100, 100)];
    self.matrixTextView.font = [UIFont systemFontOfSize:14];
    self.matrixTextView.backgroundColor = [UIColor clearColor];
    self.matrixTextView.textColor = [UIColor blueColor];
    self.matrixTextView.userInteractionEnabled = NO;
    [self addSubview:self.matrixTextView];
    
    self.stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.stopButton setTitle:@"停止" forState:UIControlStateNormal];
    self.stopButton.frame = CGRectMake(30, bounds.size.height - 120, bounds.size.width - 60, 40);
    self.stopButton.backgroundColor = [UIColor lightGrayColor];
    [self.stopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.stopButton addTarget:self action:@selector(stop:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.stopButton];
    
    self.recordStatusView = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, 100, 40)];
    self.recordStatusView.textColor = [UIColor greenColor];
    self.recordStatusView.font = [UIFont systemFontOfSize:20];
    self.recordStatusView.text = @"未录制";
    self.recordStatusView.userInteractionEnabled = NO;
    [self addSubview:self.recordStatusView];
    
    self.gpsTimeStampView = [[UILabel alloc] initWithFrame:CGRectMake(bounds.size.width - 160, 80, 160, 40)];
    self.gpsTimeStampView.textColor = [UIColor greenColor];
    self.gpsTimeStampView.font = [UIFont systemFontOfSize:15];
    self.gpsTimeStampView.text = @"";
    self.gpsTimeStampView.numberOfLines = 0;
    self.gpsTimeStampView.textAlignment = NSTextAlignmentLeft;
    self.gpsTimeStampView.userInteractionEnabled = NO;
    [self addSubview:self.gpsTimeStampView];
    
    self.syncTimeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.syncTimeButton setTitle:@"时间同步" forState:UIControlStateNormal];
    self.syncTimeButton.backgroundColor = [UIColor lightGrayColor];
    [self.syncTimeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.syncTimeButton setFrame:CGRectMake(bounds.size.width - 90, 20, 70, 40)];
    [self.syncTimeButton addTarget:self action:@selector(syncTime:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.syncTimeButton];
    
    self.shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.shareButton setTitle:@"分享" forState:UIControlStateNormal];
    self.shareButton.backgroundColor = [UIColor lightGrayColor];
    [self.shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.shareButton setFrame:CGRectMake(bounds.size.width - 90, bounds.size.height - 50, 70, 40)];
    [self.shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.shareButton];
    
    self.gpsUpdateView = [[UILabel alloc] initWithFrame:CGRectMake(bounds.size.width - 260, 120, 260, 20)];
    self.gpsUpdateView.textColor = [UIColor greenColor];
    self.gpsUpdateView.font = [UIFont systemFontOfSize:15];
    self.gpsUpdateView.text = @"";
    self.gpsUpdateView.numberOfLines = 0;
    self.gpsUpdateView.textAlignment = NSTextAlignmentLeft;
    self.gpsUpdateView.userInteractionEnabled = NO;
    [self addSubview:self.gpsUpdateView];
    
    self.gpsTimeStampCallBackView = [[UILabel alloc] initWithFrame:CGRectMake(bounds.size.width - 260, 140, 260, 20)];
    self.gpsTimeStampCallBackView.textColor = [UIColor greenColor];
    self.gpsTimeStampCallBackView.font = [UIFont systemFontOfSize:15];
    self.gpsTimeStampCallBackView.text = @"";
    self.gpsTimeStampCallBackView.numberOfLines = 0;
    self.gpsTimeStampCallBackView.textAlignment = NSTextAlignmentLeft;
    self.gpsTimeStampCallBackView.userInteractionEnabled = NO;
    [self addSubview:self.gpsTimeStampCallBackView];
}

- (void)back:(id)sender {
    if (self.clickEventHandler) {
        self.clickEventHandler(ZRClickEventTypeClose, nil);
    }
}

- (void)record:(id)sender {
    if (self.clickEventHandler) {
        self.clickEventHandler(ZRClickEventTypeRecord, nil);
    }
}

- (void)stop:(id)sender {
    if (self.clickEventHandler) {
        self.clickEventHandler(ZRClickEventTypeStop, nil);
    }
}

- (void)remove:(id)sender {
    if (self.clickEventHandler) {
        self.clickEventHandler(ZRClickEventTypeRemove, nil);
    }
}

- (void)syncTime:(id)sender {
    if (self.clickEventHandler) {
        self.clickEventHandler(ZRClickEventTypeSyncTime, nil);
    }
}

- (void)share {
    if (self.clickEventHandler) {
        self.clickEventHandler(ZRClickEventTypeShare, nil);
    }
}

@end
