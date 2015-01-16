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

@interface ViewControllerLogin ()

@property (weak, nonatomic) IBOutlet UITextField *account;

@property (weak, nonatomic) IBOutlet UITextField *password;

@end

@implementation ViewControllerLogin

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.profileImageview.layer.cornerRadius = self.profileImageview.frame.size.width / 2;
    self.profileImageview.clipsToBounds = YES;
    // Do any additional setup after loading the view.
    self.account.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wo_button_hand"]];
    self.account.leftViewMode = UITextFieldViewModeAlways;
    
    UITapGestureRecognizer *gestureTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeKeyBoard)];
    gestureTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:gestureTap];
}

- (void)removeKeyBoard{
    [self.account resignFirstResponder];
    [self.password resignFirstResponder];
}

#define SIGN_IN_SEGUE   @"signInSegue"

- (IBAction)onLogin:(id)sender {
    if ( [self.account.text length]==0 || [self.password.text length]==0 ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"用户名或密码不能为空" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
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
            [[RuntimeStatus instance] loadLocalInfo];
            [[RuntimeStatus instance].usrSelf loadServerSelfInfo:signInAckDict];
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

@end
