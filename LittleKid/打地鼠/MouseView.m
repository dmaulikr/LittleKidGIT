//
//  MouseView.m
//  打地鼠
//
//  Created by 元帅 on 14-7-22.
//  Copyright (c) 2014年 唐元帅. All rights reserved.
//

#import "MouseView.h"

@implementation MouseView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _speed = 0;
        _coodY = self.center.y;
        [self uiConfig];
    }
    return self;
}
- (void)uiConfig
{
    self.userInteractionEnabled = YES;
    self.animationImages = @[[UIImage imageNamed:@"Mole01"]
                             ,[UIImage imageNamed:@"Mole02"]
                             ,[UIImage imageNamed:@"Mole03"]
                             ,[UIImage imageNamed:@"Mole02"]];
    self.animationDuration = 0.4;
    [self startAnimating];
}
//老鼠被点击事件
- (void)beAttack{
    //被点击后运动方向变
    _speed = 1;
    [self stopAnimating];//必须把动画停了才能换背景图
        self.image = [UIImage imageNamed:@"Mole04"];
}
- (void)move{
    self.center = CGPointMake(self.center.x, self.center.y+_speed);
    if (_coodY-self.center.y > 60){
        _speed = 1;
    }
    else if (_coodY - self.center.y < 0){
        _speed = 0;
        self.center = CGPointMake(self.center.x, _coodY);
        [self startAnimating];
    }
}
- (BOOL)comeOut{
    if (_speed!=0){
        return NO;
    }
    _speed = -1;
    return YES;
}
@end
