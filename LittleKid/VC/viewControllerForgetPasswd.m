//
//  viewControllerForgetPasswd.m
//  LittleKid
//
//  Created by XC on 15-3-10.
//  Copyright (c) 2015年 李允恺. All rights reserved.
//

#import "viewControllerForgetPasswd.h"
#import "viewControllerCheckcode.h"

@interface viewControllerForgetPasswd()

@property (strong, nonatomic) IBOutlet UITextField *userna;
@property (strong, nonatomic) IBOutlet UITextField *userpa;
@property (strong, nonatomic) IBOutlet UIButton *verifyCodeBtn;
@property (strong, nonatomic) IBOutlet UIButton *nextBtn;


@end

@implementation viewControllerForgetPasswd

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.verifyCodeBtn addTarget:self action:@selector(getVerifycode1) forControlEvents:UIControlEventTouchUpInside];
    [self.nextBtn addTarget:self action:@selector(verifycodeCheck) forControlEvents:UIControlEventTouchUpInside];
    
    //按下背景退出输入法
    UITapGestureRecognizer *gestureTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeKeyBoard)];
    gestureTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:gestureTap];
}

- (void)removeKeyBoard{
    [self.userna resignFirstResponder];
    [self.userpa resignFirstResponder];
}


-(void)getVerifycode1{
    
    if (self.userna.text.length != 11) {
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"无效的电话号码" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
        [alter show];
    }
    else
    {
//        [AVOSCloud requestSmsCodeWithPhoneNumber:self.userna.text appName:@"一起兴趣班" operation:@"找回密码服务" timeToLive:10  callback:^(BOOL succeeded, NSError *error) {
//            NSLog(@"bool:%c,error:xxxxxx--%@--xxxxxx",succeeded,error);
//            //TODO:当error不为空时（比如联网故障），没有反应，应进行处理。
//        }];
        //需要验证手机号-----在leancloud的应用设置页面讲
        
        [AVUser requestPasswordResetWithPhoneNumber:self.userna.text block:^(BOOL succeeded, NSError *error) {
            //<#code#>
            NSLog(@"%@",self.userna.text);
            NSLog(@"%@",error);
            //TODO:当error不为空时（比如联网故障），没有反应，应进行处理。
        }];
        
        ///秒数连续-2，因为timer尚未取消。
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
    }
    
}



-(void)verifycodeCheck{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* nextController = [storyboard instantiateViewControllerWithIdentifier:@"viewControllerCheckcode"];
    
    [self.navigationController pushViewController:nextController animated:YES];
    
//    [AVOSCloud verifySmsCode:self.userpa.text mobilePhoneNumber:self.userna.text callback:^(BOOL succeeded, NSError *error) {
//        if (succeeded) {
//            //TODO:跳转下一页
//           
//        } else {
//            ;
//        }
//    }];
}




static int seconds = 120;

-(void)timerFireMethod:(NSTimer *)theTimer{
    if (seconds == 1) {
        [theTimer invalidate];
        seconds = 60;
        [self.verifyCodeBtn setTitle:@"获取验证码" forState: UIControlStateNormal];
        [self.verifyCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.verifyCodeBtn setEnabled:YES];
    }else{
        seconds--;
        NSString *title = [NSString stringWithFormat:@"重新获取%d",seconds];
        [self.verifyCodeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.verifyCodeBtn setEnabled:NO];
        [self.verifyCodeBtn setTitle:title forState:UIControlStateNormal];
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    viewControllerCheckcode *desVC = segue.destinationViewController;
    desVC.code = self.userpa.text;
}

@end
