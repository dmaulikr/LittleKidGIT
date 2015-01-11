//
//  GameControl.m
//  打地鼠
//
//  Created by 元帅 on 14-7-22.
//  Copyright (c) 2014年 唐元帅. All rights reserved.
//

#import "GameControl.h"
#import "MouseView.h"
#import "RootViewController.h"
//@synthesize delegate;
@implementation GameControl
{
    NSTimer *_timer;//计时器
    NSMutableArray *mouseArr;
    UIView *_timeBar;//时间轴
}
//@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self uiConfig];
    }
    self.score = 0;
    return self;
}
- (void)uiConfig{
    int heights[4] = {227,124,123,116};
    int coodY[4] = {0,190,276,364};
    NSMutableArray *backgroundArr = [[NSMutableArray alloc] init];
    mouseArr = [[NSMutableArray alloc] init];
    for (int i=0;i<4;i++)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, coodY[i], 320, heights[i])];
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"GameBG0%d",i+1]];
        [self addSubview:imageView];
        [backgroundArr addObject:imageView];
    }
    for (int i=0;i<9;i++){
        MouseView *mouse = [[MouseView alloc] initWithFrame:CGRectMake(30+102*(i%3), 200+87*(i/3), 56, 79)];
        [mouseArr addObject:mouse];
        [self insertSubview:mouse aboveSubview:backgroundArr[i/3]];
        //给每只老鼠添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickMouse:)];
        [mouse addGestureRecognizer:tap];
    }
    //给时间进度条添加背景
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(90, 420, 203, 22)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [self insertSubview:whiteView belowSubview:backgroundArr[3]];
    //时间进度条
    _timeBar = [[UIView alloc] initWithFrame:CGRectMake(95, 421, 200, 20)];
    _timeBar.backgroundColor = [UIColor blueColor];
    [self insertSubview:_timeBar aboveSubview:whiteView];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(refreshView) userInfo:nil repeats:YES];
}
//实现手势
- (void)clickMouse:(UITapGestureRecognizer *)tap
{
    //面向对象
    MouseView *mouse = (MouseView*)tap.view;
    if (mouse.speed == -1||mouse.speed==1)
    {
        self.score++;
        [mouse beAttack];
    }
    
    
}
static int count = 0;
- (void)refreshView
{
    count++;
    _timeBar.frame = CGRectMake(_timeBar.frame.origin.x, _timeBar.frame.origin.y,_timeBar.frame.size.width - 200.0/200.0, _timeBar.frame.size.height);
    if (_timeBar.frame.size.width<1) {
        [_timer invalidate];
        _timer = nil;
        
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"时间到" message:[NSString stringWithFormat:@"你的得分：%d",self.score] delegate:nil cancelButtonTitle:@"开始下棋" otherButtonTitles:nil];
        alter.delegate = self;
        
        [alter show];
//        [alter release];
    }
    
    //老鼠运动
    for (MouseView *mouse in mouseArr){
        [mouse move];
    }
    if (count%15 == 0){
        [self mouseComeOut];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
 //   id<GameControlDelegate> delegate = self.delegate;
    [self removeFromSuperview];
    [self.delegate alterWillDismiss:self.score];
    
}
//设置随机数,让老鼠无规律出现
- (void)mouseComeOut{
    int index = arc4random()%9;
    MouseView *mouse =mouseArr[index];
    //如果没有出现,则出现
    if (![mouse comeOut]){
        [self mouseComeOut];
    }
}

@end
