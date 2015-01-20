//
//  ViewControllerInfo.m
//  LittleKid
//
//  Created by 李允恺 on 12/17/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import "ViewControllerInfo.h"
#import "RuntimeStatus.h"
#import <CommonCrypto/CommonDigest.h>/* fro MD5 */
#import "ViewControllerMsgCheck.h"

@interface ViewControllerInfo ()

@property (weak, nonatomic) IBOutlet UITextField *account;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *passwordCheck;
@property (strong, nonatomic) NSString *checkCode;



@end

@implementation ViewControllerInfo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.checkCode = [[NSString alloc] init];
    //add-7
    self.account.delegate = self;
    self.password.delegate = self;
    self.passwordCheck.delegate = self;
    
    self.password.returnKeyType = UIReturnKeyNext;
    self.passwordCheck.returnKeyType = UIReturnKeyGo;
    
    self.password.secureTextEntry = YES;
    self.passwordCheck.secureTextEntry = YES;
    
    //add
    UITapGestureRecognizer *gestureTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeKeyBoard)];
    gestureTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:gestureTap];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIFI_SIGN_UP object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        //code here to decide if segue to next
        NSLog(@"get notify");
        NSDictionary *signUpRcvdDict = note.userInfo;
        NSLog(@"%@",signUpRcvdDict);
        //检查ack，成功则继续提取短信验证码，失败则提示问题
        if ( YES == [self checkAck:signUpRcvdDict] ) {
            [self performSegueWithIdentifier:@"segueFromInfo" sender:self];
        }
    }];
}
///add
- (void)removeKeyBoard{
    [self.account resignFirstResponder];
    [self.password resignFirstResponder];
    [self.passwordCheck resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
///add
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.password) {
        [self.passwordCheck becomeFirstResponder];
    } else {
        [self onBtnSignUp:nil];
    }
    return YES;
}
///add
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
///


#define RET_CODE    @"retcode"
- (BOOL)checkAck:(NSDictionary *)ackDict{
    NSString *retCode = [ackDict objectForKey:RET_CODE];
    if ( [retCode intValue]<0 ) {
        [[[UIAlertView alloc] initWithTitle:@"手机号已被注册" message:@"请更换手机号码或直接登陆" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] show];
        return NO;
    }
    self.checkCode = retCode;
    return YES;
}

- (IBAction)onBtnSignUp:(id)sender {
    if ([self checkMsg] == NO) {//本地check是否合法
        return;
    }
    [RuntimeStatus instance].signAccountUID = self.account.text;
    [[RuntimeStatus instance].usrSelf addSignUpMsgToUsrselfWithUID:self.account.text pwd:[self md5WithStr:self.password.text]];//pwd加密
    NSDictionary *signUpDict = [[RuntimeStatus instance].usrSelf packetSignUpDict];
    [HTTTClient sendData:signUpDict withProtocol:SIGN_UP];
    [self waitStatus];
}

-(void)waitStatus{
    //wait status view
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

- (BOOL)checkMsg{
    //check telephone,email, etc
    if (self.account.text.length == 0 || self.account.text.length != 11 ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"账号错误" message:@"请输入11位手机号码" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        return NO;    //if fail, return. don't go to next page
    }
    if ( NSOrderedSame != [self.password.text compare:self.passwordCheck.text] ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"密码错误" message:@"两次输入密码不一致" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        return NO;    //if fail, return. don't go to next page
    }
    if ( self.password.text.length < 6 ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"密码不合法" message:@"请输入至少6位密码" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        return NO;    //if fail, return. don't go to next page
    }
    //other msg check
    
    
    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ViewControllerMsgCheck *desVC = segue.destinationViewController;
    desVC.checkCode = self.checkCode;
}

@end
