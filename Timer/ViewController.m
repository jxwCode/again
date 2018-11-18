//
//  ViewController.m
//  Timer
//
//  Created by Wicky on 16/9/19.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import "ViewController.h"
#import "RunloopViewController.h"
@interface ViewController ()

@property (nonatomic , assign) NSInteger currentIndex;

@property (nonatomic) CADisplayLink * timerInC;

@property (nonatomic) UIImageView * imgV;

@property (nonatomic) NSTimer * timerInN;

@property (nonatomic) dispatch_source_t timerInG;

@property (nonatomic , assign) BOOL nsTimerResume;

@property (nonatomic , assign) BOOL gcdTimerResume;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor grayColor];
    
    self.imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    self.imgV.contentMode = UIViewContentModeScaleAspectFill;
    self.imgV.center = self.view.center;
    [self.view addSubview:self.imgV];
    
    
    UIButton * button = [UIButton buttonWithType:(UIButtonTypeSystem)];
    [button setFrame:CGRectMake(0, 0, 100, 30)];
    button.center = CGPointMake(self.view.center.x - 110, self.view.center.y + 200);
    [self.view addSubview:button];
    [button setTitle:@"CADisplayLink" forState:(UIControlStateNormal)];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button addTarget:self action:@selector(CADisplayLinkAction) forControlEvents:(UIControlEventTouchUpInside)];
    
    UIButton * button1 = [UIButton buttonWithType:(UIButtonTypeSystem)];
    [button1 setFrame:CGRectMake(0, 0, 100, 30)];
    button1.center = CGPointMake(self.view.center.x, self.view.center.y + 200);
    [self.view addSubview:button1];
    [button1 setTitle:@"NSTimer" forState:(UIControlStateNormal)];
    [button1 setBackgroundColor:[UIColor whiteColor]];
    [button1 addTarget:self action:@selector(NSTimerAction) forControlEvents:(UIControlEventTouchUpInside)];
    
    
    UIButton * button2 = [UIButton buttonWithType:(UIButtonTypeSystem)];
    [button2 setFrame:CGRectMake(0, 0, 100, 30)];
    button2.center = CGPointMake(self.view.center.x + 110, self.view.center.y + 200);
    [self.view addSubview:button2];
    [button2 setTitle:@"GCDTimer" forState:(UIControlStateNormal)];
    [button2 setBackgroundColor:[UIColor whiteColor]];
    [button2 addTarget:self action:@selector(GCDTimerAction) forControlEvents:(UIControlEventTouchUpInside)];
    
    UIButton * button3 = [UIButton buttonWithType:(UIButtonTypeSystem)];
    [button3 setFrame:CGRectMake(0, 0, 100, 30)];
    button3.center = CGPointMake(self.view.center.x, self.view.center.y + 240);
    [self.view addSubview:button3];
    [button3 setTitle:@"看看Runloop" forState:(UIControlStateNormal)];
    [button3 setBackgroundColor:[UIColor whiteColor]];
    [button3 addTarget:self action:@selector(gotoRunloopAction) forControlEvents:(UIControlEventTouchUpInside)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self initTimer];
}

-(void)initTimer
{
    ///target selector 模式初始化一个实例
    self.timerInC = [CADisplayLink displayLinkWithTarget:self selector:@selector(changeImg)];
    ///暂停
    self.timerInC.paused = YES;
    ///selector触发间隔
    self.timerInC.frameInterval = 2;
    ///加入一个runLoop
    [self.timerInC addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.timerInN = [NSTimer timerWithTimeInterval:0.032 target:self selector:@selector(changeImg) userInfo:nil repeats:YES];
    self.timerInN.fireDate = [NSDate distantFuture];
    self.nsTimerResume = YES;
    [[NSRunLoop currentRunLoop] addTimer:self.timerInN forMode:NSDefaultRunLoopMode];
    self.gcdTimerResume = YES;
}

-(void)changeImg
{
    self.currentIndex ++;
    if (self.currentIndex > 75) {
        self.currentIndex = 1;
    }
    self.imgV.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld.jpg",self.currentIndex]];
}

-(void)CADisplayLinkAction
{
    self.nsTimerResume = YES;
    self.timerInN.fireDate = [NSDate distantFuture];
    if (self.timerInG && !self.gcdTimerResume) {
        dispatch_suspend(self.timerInG);
        self.gcdTimerResume = YES;
    }
    self.timerInC.paused = !self.timerInC.paused;
}

-(void)NSTimerAction
{
    self.timerInC.paused = YES;
    
    if (self.timerInG && !self.gcdTimerResume) {
        dispatch_suspend(self.timerInG);
        self.gcdTimerResume = YES;
    }
    self.timerInN.fireDate = self.nsTimerResume?
        [NSDate distantPast]:[NSDate distantFuture];
    self.nsTimerResume = !self.nsTimerResume;
}

-(void)GCDTimerAction
{
    if (self.gcdTimerResume) {
        self.timerInC.paused = YES;
        self.nsTimerResume = YES;
        self.timerInN.fireDate = [NSDate distantFuture];
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            self.timerInG = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
            dispatch_source_set_timer(self.timerInG,  dispatch_walltime(NULL,0 * NSEC_PER_SEC), 0.032 * NSEC_PER_SEC, 0);
            dispatch_source_set_event_handler(self.timerInG, ^{
                [self changeImg];
            });
        });
        dispatch_resume(self.timerInG);
    }
    else
    {
        dispatch_suspend(self.timerInG);
    }
    self.gcdTimerResume = !self.gcdTimerResume;
}

- (void)gotoRunloopAction
{
    [self.timerInC invalidate];
    self.timerInC = nil;
    [self.timerInN invalidate];
    self.timerInN = nil;
    if (self.timerInG) {
        if (self.gcdTimerResume) {
            dispatch_resume(self.timerInG);
        }
        dispatch_source_cancel(self.timerInG);
        self.timerInG = nil;
    }
    RunloopViewController * vc = [[RunloopViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
