//
//  ViewControllerRealTalk.h
//  LittleKid
//
//  Created by 李允恺 on 12/19/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

#import "RuntimeStatus.h"

#import "AnyChatDefine.h"
#import "AnyChatErrorCode.h"
#import "AnyChatPlatform.h"

@interface ViewControllerRealTalk : UIViewController <AnyChatNotifyMessageDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSString *realTalkServerIP;
@property (strong, nonatomic) NSString *realTalkServerPort;
@property (strong, nonatomic) NSString *realTalkUsrName;
@property (strong, nonatomic) NSString *realTalkUsrPwd;
@property (strong, nonatomic) NSString *realTalkUsrID;
@property (strong, nonatomic) NSString *realTalkRemoteUsrID;
@property (strong, nonatomic) NSString *realTalkRoomNumber;
@property (strong, nonatomic) NSString *realTalkRoomPwd;
@property (strong, nonatomic) NSMutableArray *realTalkOnlineUsrList;

@end
