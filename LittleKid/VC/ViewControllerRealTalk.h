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

@end
