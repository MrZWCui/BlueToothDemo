//
//  ZWBlueToothViewController.m
//  ZWBlueTooth
//
//  Created by 崔先生的MacBook Pro on 2022/9/6.
//

#import "ZWBlueToothViewController.h"
#import "ZWBlueToothView.h"

@interface ZWBlueToothViewController ()

@property (nonatomic, strong) ZWBlueToothView *blueToothView;

@end

@implementation ZWBlueToothViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    _blueToothView = [[ZWBlueToothView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_blueToothView];
    [_blueToothView addTarget:self action:@selector(hideListView) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)hideListView {
    [_blueToothView hideListView];
    NSLog(@"你点击了我");
}

@end
