//
//  ViewControllerLogin.m
//  LittleKid
//
//  Created by 李允恺 on 12/17/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import "ViewControllerLogin.h"
#import "RuntimeStatus.h"
#import <CommonCrypto/CommonDigest.h>/* fro MD5 */
#include <AVOSCloud/AVOSCloud.h>

@interface ViewControllerLogin ()

@property (strong, nonatomic) IBOutlet UITextField *account;

@property (strong, nonatomic) IBOutlet UITextField *password;

@property (strong, nonatomic) UIViewController *v1;

@end

@implementation ViewControllerLogin


#define SIGN_IN_SEGUE   @"signInSegue"

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.profileImageview.layer.cornerRadius = self.profileImageview.frame.size.width / 2;
    self.profileImageview.clipsToBounds = YES;
    // Do any additional setup after loading the view.
    UIImageView *userImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"denglu_bg_user"]];
    userImage.frame = CGRectMake(10, 0, 40, 40);
    self.account.leftView = userImage;
    self.account.leftViewMode = UITextFieldViewModeAlways;
    
    UIImageView *mimaImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"denglu_bg_mima"]];
    mimaImage.frame = CGRectMake(10, 0, 40, 40);
    self.password.leftView = mimaImage;
    self.password.leftViewMode = UITextFieldViewModeAlways;
    //add-3
    self.account.delegate = self;
    self.password.delegate = self;
    self.password.secureTextEntry = YES;
    //add-2
    self.account.returnKeyType = UIReturnKeyNext;
    self.password.returnKeyType = UIReturnKeyGo;
//    self.account.text = @"13437251599";
//    self.password.text = @"123456";
//    [self onLogin:nil];
    //按下背景退出输入法
    UITapGestureRecognizer *gestureTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeKeyBoard)];
    gestureTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:gestureTap];
    
    [self setupfogPswUI];
    
}


- (void)removeKeyBoard{
    [self.account resignFirstResponder];
    [self.password resignFirstResponder];
}
///add
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.account) {
        [self.password becomeFirstResponder];
    } else {
        [self onLogin:nil];
    }
    return YES;
}


- (IBAction)onLogin:(id)sender {
    if ( [self.account.text length]==0 || [self.password.text length]==0 ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"用户名或密码不能为空" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    
    //登录功能
    [AVUser logInWithUsernameInBackground:self.account.text password:self.password.text block:^(AVUser *user, NSError *error) {
        if (user != nil) {
            [[RuntimeStatus instance] init];
            [[RuntimeStatus instance] initial];
            [self performSegueWithIdentifier:SIGN_IN_SEGUE sender:nil];
            return;
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }];
    
    //设置run的accoutUID
    [RuntimeStatus instance].signAccountUID = self.account.text;
    /* 封装数据并发送 */
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:self.account.text, USR_UID, [self md5WithStr:self.password.text], USR_PWD, nil];
    [HTTTClient sendData:jsonDict withProtocol:SIGN_IN];
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIFI_SIGN_IN object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {//返回消息的回调
        NSLog(@"I get the login reply");
        NSDictionary *signInAckDict = note.userInfo;
        //check if right, then
        if ( YES == [self checkSignInInfo:signInAckDict] ) {
            //get info from local
//            [[RuntimeStatus instance] loadLocalInfo];
//            [[RuntimeStatus instance].usrSelf loadServerSelfInfo:signInAckDict];
            //get info from server//异步的,在全局量里处理就行了
//            [HTTTClient sendData:nil withProtocol:RECENT_MSG_GET];
//            [HTTTClient sendData:nil withProtocol:FRIEND_LIST_GET];
            //切入登陆界面
           [self performSegueWithIdentifier:SIGN_IN_SEGUE sender:nil];
        }
    }];
}

- (BOOL)checkSignInInfo:(NSDictionary *)signInAckDict{
    NSLog(@"%@",signInAckDict);
    NSString *pwdMD5_2FromServer = [signInAckDict objectForKey:USR_PWD];
    NSString *pwdMD5_2 = [self md5WithStr:[self md5WithStr:self.password.text]];//md5二次加密
    if ( NSOrderedSame == [pwdMD5_2 compare:pwdMD5_2FromServer] ) {
        return YES;
    }
    return NO;
}

- (NSString *)md5WithStr:(NSString *)pwd{
    const char *cStr = [pwd UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
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

#pragma mark--实现找回密码页面

-(void)setupfogPswUI{
    
    self.v1 = [[UIViewController alloc] init];
    self.v1.view.backgroundColor = [UIColor lightGrayColor];
    UITextField *userna = [[UITextField alloc] initWithFrame:CGRectMake(0, 90, self.v1.view.frame.size.width, 30)];
    UITextField *userpa = [[UITextField alloc] initWithFrame:CGRectMake(0, userna.frame.origin.y+32, self.v1.view.frame.size.width, 30)];
    userna.backgroundColor = [UIColor whiteColor];
    userpa.backgroundColor = [UIColor whiteColor];
    userna.borderStyle = UITextBorderStyleNone;
    userpa.borderStyle = UITextBorderStyleNone;
    
    userna.keyboardType = UIKeyboardTypePhonePad;
    userna.returnKeyType = UIReturnKeyNext;
    userpa.returnKeyType = UIReturnKeyGo;
    
    UILabel *utips = [[UILabel alloc] initWithFrame:CGRectMake(20, 90, 60, 20)];
    utips.textColor = [UIColor darkTextColor];
    utips.text = @"手机号:";
    userna.leftView = utips;
    userna.leftViewMode = UITextFieldViewModeAlways;
    
    UILabel *ptips = [[UILabel alloc] initWithFrame:CGRectMake(20, 122, 60, 20)];
    ptips.textColor = [UIColor darkTextColor];
    ptips.text = @"验证码:";
    userpa.leftView = ptips;
    userpa.leftViewMode = UITextFieldViewModeAlways;
    
    UIButton *verifyCode =  [UIButton buttonWithType:UIButtonTypeSystem];
    verifyCode.frame = CGRectMake(userna.frame.origin.x + 200, 95, 90, 20);
    verifyCode.backgroundColor = [UIColor blueColor];
    [verifyCode setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [verifyCode setTitle:@"获取验证码" forState:UIControlStateNormal];
    [verifyCode addTarget:self action:@selector(getVerifycode) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *next =  [UIButton buttonWithType:UIButtonTypeSystem];
    next.frame = CGRectMake(20, userpa.frame.origin.y+45, 280, 30);
    next.backgroundColor = [UIColor purpleColor];
    [next.layer setMasksToBounds:YES];
    [next.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
    
    [next setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [next setTitle:@"下一步" forState:UIControlStateNormal];
    [next.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [next addTarget:self action:@selector(verifycodeCheck) forControlEvents:UIControlEventTouchUpInside];
   
    
    [self.v1.view addSubview:userna];
    [self.v1.view addSubview:userpa];
    [self.v1.view addSubview:verifyCode];
    [self.v1.view addSubview:next];
    
}

- (IBAction)forgetPassword {
    [self.navigationController pushViewController:self.v1 animated:YES];
}

-(void)getVerifycode{
//    [];
}

-(void)verifycodeCheck{
    
}

static int seconds = 60;

-(void)timerFireMethod:(NSTimer *)theTimer :(UIButton *)btn{
    if (seconds == 1) {
        [theTimer invalidate];
        seconds = 60;
        [btn setTitle:@"获取验证码" forState: UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setEnabled:YES];
    }else{
        seconds--;
        NSString *title = [NSString stringWithFormat:@"重新获取验证码 %d",seconds];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btn setEnabled:NO];
        [btn setTitle:title forState:UIControlStateNormal];
    }
}

@end
