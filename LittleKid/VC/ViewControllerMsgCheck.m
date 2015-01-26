//
//  ViewControllerMsgCheck.m
//  LittleKid
//
//  Created by 李允恺 on 12/17/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import "ViewControllerMsgCheck.h"
#import "RuntimeStatus.h"
#import "typedef.h"

@interface ViewControllerMsgCheck ()

@property (weak, nonatomic) IBOutlet UIButton *btnRepickCode;
@property(weak, nonatomic) NSTimer *repickBtnFreshTimer;

@property (strong, nonatomic) IBOutlet UITextField *verificationCode;

@end

@implementation ViewControllerMsgCheck

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.verificationCode.delegate = self;
    
    UITapGestureRecognizer *gestureTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeKeyBoard)];
    gestureTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:gestureTap];
    
}

///add

- (void)removeKeyBoard{
    [self.verificationCode resignFirstResponder];
}


#pragma mark --定时器

static int seconds = 60;
//注册成功则停止计时
-(void)releaseTimer{
    if (self.repickBtnFreshTimer) {
        if ([self.repickBtnFreshTimer respondsToSelector:@selector(isValid)]) {
            if ([self.repickBtnFreshTimer isValid]) {
                [self.repickBtnFreshTimer invalidate];
                seconds = 60;
            }
        }
    }
}


-(void)timerFireMethod:(NSTimer *)theTimer {
    if (seconds == 0) {
        [theTimer invalidate];
        seconds = 60;
        [self.btnRepickCode setTitle:@"获取验证码" forState: UIControlStateNormal];
        [self.btnRepickCode setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.btnRepickCode setEnabled:YES];
    }else{
        seconds--;
        NSString *title = [NSString stringWithFormat:@"重新获取验证码 %d",seconds];
        [self.btnRepickCode setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.btnRepickCode setEnabled:NO];
        [self.btnRepickCode setTitle:title forState:UIControlStateNormal];
    }
}

- (IBAction)onRepickCode:(id)sender {

    [AVOSCloud requestSmsCodeWithPhoneNumber:self.kiduser.username appName:@"应用" operation:@"注册验证" timeToLive:10  callback:^(BOOL succeeded, NSError *error) {
        NSLog(@"bool:%c,error:xxxxxx--%@--xxxxxx",succeeded,error);
    }];
    
    self.repickBtnFreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
    
}

#define SEGUE_TO_MAIN @"segueToMain"

- (IBAction)onCheckMsg:(id)sender {


 
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

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //监听键盘高度
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
    
}

- (void)keyboardWasChange:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    self.keyboardHeight = kbSize.height;
    NSLog(@"height--:%f",kbSize.height);
    
}

@end
