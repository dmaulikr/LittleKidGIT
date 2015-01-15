//
//  RootViewController.h
//  象棋Demo
//
//  Created by QzydeMac on 14/11/30.
//  Copyright (c) 2014年 Qzy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RNGridMenu.h"
#import "GameControl.h"
#import "RuntimeStatus.h"
#import <AVFoundation/AVFoundation.h>

@class CheseInterface;
@interface RootViewController : UIViewController<GameControlDelegate,RNGridMenuDelegate>

//@property(nonatomic) int blackOrRed;
@property (retain,readwrite,nonatomic)CheseInterface * cheseInterface;
@property (retain,nonatomic,readwrite) UILabel * label;
@property  bool blackOrRed;//0 red 1 black
@property (strong,nonatomic) AVAudioPlayer *play;
@property int sendCmd;
- (void)showWhoShouldPlayChese:(NSInteger)num;
@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
