//
//  ZRBaseView.h
//  Video_IMU_Recorder
//
//  Created by Zhou,Rui(ART) on 2020/6/19.
//  Copyright © 2020 Zhou,Rui(ART). All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ZRClickEventType){
    ZRClickEventTypeClose,
    ZRClickEventTypeRecord,
    ZRClickEventTypeStop,
    ZRClickEventTypeRemove,
    ZRClickEventTypeShare,
    ZRClickEventTypeSyncTime,
};

typedef void (^ZRBaseViewClickEventHandler)(ZRClickEventType type, NSDictionary* _Nullable data);

NS_ASSUME_NONNULL_BEGIN

@interface ZRBaseView : UIView

@property (nonatomic, copy) ZRBaseViewClickEventHandler clickEventHandler;

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UITextView *matrixTextView;
@property (nonatomic, strong) UILabel *recordStatusView;
@property (nonatomic, strong) UIButton *syncTimeButton;
@property (nonatomic, strong) UILabel *gpsTimeStampView;
@property (nonatomic, strong) UILabel *gpsUpdateView;
@property (nonatomic, strong) UILabel *gpsTimeStampCallBackView;

@end

NS_ASSUME_NONNULL_END
