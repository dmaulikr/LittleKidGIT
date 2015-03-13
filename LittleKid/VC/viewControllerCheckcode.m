//
//  viewControllerCheckcode.m
//  LittleKid
//
//  Created by XC on 15-3-12.
//  Copyright (c) 2015年 李允恺. All rights reserved.
//

#import "viewControllerCheckcode.h"
#include <AVOSCloud/AVOSCloud.h>

@interface  viewControllerCheckcode()
@property (strong, nonatomic) IBOutlet UITextField *updatePsd;
@property (strong, nonatomic) IBOutlet UITextField *confirmPsd;
@property (strong, nonatomic) IBOutlet UIButton *updatePsdBtn;


@end

@implementation viewControllerCheckcode

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self.updatePsdBtn addTarget:self action:@selector(updatePassword) forControlEvents:UIControlEventTouchUpInside];
    
    
    //按下背景退出输入法
    UITapGestureRecognizer *gestureTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeKeyBoard)];
    gestureTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:gestureTap];
}

- (void)removeKeyBoard{
    [self.updatePsd resignFirstResponder];
    [self.confirmPsd resignFirstResponder];
}

-(BOOL)checkNewPsdisSame{
    return [self.updatePsd.text isEqualToString: self.confirmPsd.text];
}




-(void)updatePassword{
    if (![self checkNewPsdisSame]) {
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"两次输入的密码不一致" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
        [alter show];
    } else {
        [AVUser resetPasswordWithSmsCode:self.code newPassword:self.updatePsd.text block:^(BOOL succeeded, NSError *error) {
            NSLog(@"%@;;;;;;;;;;;%@",self.code,self.updatePsd.text);
            if (succeeded) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UITableViewController* nextController = [storyboard instantiateViewControllerWithIdentifier:@"mainTabViewController"];
                [self.navigationController presentViewController:nextController animated:YES completion:^{
                    ;
                }];
                NSLog(@"oppooopopopopopopopopopopop");
            } else {
                
            }
        }];
    }
}

@end
