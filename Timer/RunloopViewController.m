//
//  RunloopViewController.m
//  Timer
//
//  Created by Wicky on 16/9/20.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import "RunloopViewController.h"

@interface RunloopViewController ()<UIScrollViewDelegate>

@property (nonatomic ,assign) NSInteger indexA;

@property (nonatomic ,assign) NSInteger indexB;

@property (nonatomic) UILabel * labelA;

@property (nonatomic) UILabel * labelB;

@property (nonatomic) NSTimer * timerA;

@property (nonatomic) NSTimer * timerB;

@property (nonatomic) dispatch_queue_t queue;

@end

@implementation RunloopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.indexA = 100;
    self.indexB = 100;
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height * 2);
    scrollView.backgroundColor = [UIColor lightGrayColor];
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    self.labelA = label;
    label.text = [NSString stringWithFormat:@"%ld",self.indexA];
    label.textAlignment = NSTextAlignmentCenter;
    label.center = CGPointMake(self.view.center.x - 60, self.view.center.y);
    [scrollView addSubview:label];
    
    NSTimer * timerA = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    self.queue = dispatch_get_global_queue(0, 0);
    dispatch_async(self.queue, ^{
        NSRunLoop * runloop = [NSRunLoop currentRunLoop];
        [runloop addTimer:timerA forMode:NSRunLoopCommonModes];
        self.timerA = timerA;
        //timerA不会执行，因为runloop为非激活状态
        //打开注释即可触发TimerA
//        [runloop run];
    });
    
    UILabel * label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    self.labelB = label2;
    label2.text = [NSString stringWithFormat:@"%ld",self.indexB];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.center = CGPointMake(self.view.center.x + 60, self.view.center.y);
    [scrollView addSubview:label2];
    
    NSTimer * timerB = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(timerBction) userInfo:nil repeats:YES];
    self.timerB = timerB;
    //将timerB加入到UITrackingRunLoopMode模式下，当ScrollView不滚动时，当前runloop处于NSDefaultRunLoopMode模式，timerB也不会触发，滚动起scrollView则触发timerB。
    [[NSRunLoop currentRunLoop] addTimer:timerB forMode:UITrackingRunLoopMode];
    
    UIButton * buttonB = [UIButton buttonWithType:(UIButtonTypeSystem)];
    [buttonB setFrame:CGRectMake(0, 0, 200, 30)];
    buttonB.center = CGPointMake(self.view.center.x, self.view.center.y + 200);
    [scrollView addSubview:buttonB];
    [buttonB setTitle:@"timerB fire" forState:(UIControlStateNormal)];
    [buttonB setBackgroundColor:[UIColor whiteColor]];
    [buttonB addTarget:self action:@selector(fireAction) forControlEvents:(UIControlEventTouchUpInside)];
}

-(void)timerAction
{
    self.indexA --;
    self.labelA.text = [NSString stringWithFormat:@"%ld",self.indexA];
}

-(void)timerBction
{
    self.indexB --;
    self.labelB.text = [NSString stringWithFormat:@"%ld",self.indexB];
}

-(void)fireAction
{
    //手动调用TimerB的触发事件，无视runloopMode
    [self.timerB fire];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    NSLog(@"将要开始滚动，将要离开%@模式",[[NSRunLoop currentRunLoop] currentMode]);
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"正在滚动，切换为%@模式",[[NSRunLoop currentRunLoop] currentMode]);
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"滚动将要结束，切换为离开%@模式",[[NSRunLoop currentRunLoop] currentMode]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
