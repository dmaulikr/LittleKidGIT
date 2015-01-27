//
//  UIViewControllerBase.h
//  LittleKid
//
//  Created by XC on 15-1-19.
//  Copyright (c) 2015年 李允恺. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVOSCloud/AVOSCloud.h>

@interface UIViewControllerBase : UIViewController <UITextFieldDelegate>

@property (assign) CGFloat keyboardHeight;
@property (strong, nonatomic)  AVUser *kiduser;

@end
