//
//  ViewController.m
//  Video_IMU_Recorder
//
//  Created by Zhou,Rui(ART) on 2020/6/17.
//  Copyright © 2020 Zhou,Rui(ART). All rights reserved.
//

#import "ViewController.h"
#import "ZRRecorderViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *recordBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.recordBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.recordBtn setTitle:@"开始采集" forState:UIControlStateNormal];
    self.recordBtn.backgroundColor = [UIColor systemPinkColor];
    [self.recordBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.recordBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 100, ([UIScreen mainScreen].bounds.size.height - 50.0) / 2.0, 200, 50);
    [self.recordBtn addTarget:self action:@selector(record:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.recordBtn];
}

- (void)record:(id)sender {
    ZRRecorderViewController *recorderVC = [[ZRRecorderViewController alloc] init];
    recorderVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:recorderVC animated:YES completion:nil];
}


@end
