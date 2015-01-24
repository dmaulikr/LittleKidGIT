//
//  UIViewControllerBase.m
//  LittleKid
//
//  Created by XC on 15-1-19.
//  Copyright (c) 2015年 李允恺. All rights reserved.
//

#import "UIViewControllerBase.h"



@implementation UIViewControllerBase



//开始编辑输入框时，软键盘出现，执行此事件
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;
    
    int offset = frame.origin.y + 32 - (self.view.frame.size.height - self.keyboardHeight); //the keyboard's height is 216.0
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    
    if (offset > 0) {
        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
    }
    
    [UIView commitAnimations];
}


//当用户按下return健时，keyboard消失
//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    if (textField.returnKeyType == UIReturnKeyDefault) {
//        [textField resignFirstResponder];
//    }
//    return YES;
//}


//输入框编辑完成以后，将视图恢复到原始状态
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
}


@end