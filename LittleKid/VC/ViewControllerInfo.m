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
#import "CDCommon.h"

@interface ViewControllerInfo ()

@property (strong, nonatomic) IBOutlet UITextField *nickname;
@property (strong, nonatomic) IBOutlet UITextField *account;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) NSString *nick;
@property (strong, nonatomic) AVUser *user;
@property (strong, nonatomic) AVQuery * query;



@end

@implementation ViewControllerInfo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //add-7
    self.account.delegate = self;
    self.password.delegate = self;
    self.nickname.delegate = self;
    
    //add
    UITapGestureRecognizer *gestureTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeKeyBoard)];
    gestureTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:gestureTap];
    
    //初始化本地用户
     self.user = [AVUser user];
    //初始化查询
     self.query = [AVUser query];
    
    ///add--监听电话号码长度
    [self.account addTarget:self
                       action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
    
}
///add
- (void)removeKeyBoard{
    [self.account resignFirstResponder];
    [self.password resignFirstResponder];
    [self.nickname resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
///add
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.password) {
//        [self.passwordCheck becomeFirstResponder];
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



#pragma mark --动态监听输入长度


-(IBAction)textFieldDidChange:(UITextField *)sender
{
    bool isChinese;//判断当前输入法是否是中文
    if ([[[UITextInputMode currentInputMode] primaryLanguage] isEqualToString: @"en-US"]) {
        isChinese = false;
    }
    else
    {
        isChinese = true;
    }
    
    // 11位
    NSString *str = [[sender text] stringByReplacingOccurrencesOfString:@"?" withString:@""];
   
    if (isChinese) { //中文输入法下
        UITextRange *selectedRange = [sender markedTextRange];
        //获取高亮部分
        UITextPosition *position = [sender positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            NSLog(@"汉字");
            if ( str.length == 11) {
                NSLog(@"%@",@"#######################################0");
                
               
                [self.query whereKey:@"username" equalTo:self.account.text];
                [self.query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    NSLog(@"objects:%@",objects);
                    if (error == nil) {
                        
                        if ( [objects  count] == 0 ) {
                             NSLog(@"mnmnmnmnmnmnmnmnmnmnmnmnnmnmnmnmnmn00");
                        }
                        else {
                            
                             [[[UIAlertView alloc] initWithTitle:@"手机号已被注册" message:@"请更换手机号码或直接登陆" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] show];
                        }
                        
                    } else {
                        
                    }
                }];
                
            }
        }
        else
        {
            NSLog(@"输入的英文还没有转化为汉字的状态");
            
        }
    }else{
        if ([str length] == 11) {
             NSLog(@"%@",@"#######################################1");
            

            [self.query whereKey:@"username" equalTo:self.account.text];
            [self.query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                NSLog(@"objects:%@",objects);
                if (error == nil) {
                    if ( [objects  count] == 0 ) {
                        NSLog(@"mnmnmnmnmnmnmnmnmnmnmnmnnmnmnmnmnmn00");
                    }
                    else {
                        [[[UIAlertView alloc] initWithTitle:@"手机号已被注册" message:@"请更换手机号码或直接登陆" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] show];
                    }

 
                } else {
                   
                }
            }];

        }
    }

}


#define SIGN_UP_SEGUE   @"segueFromInfo"

- (IBAction)onBtnSignUp:(id)sender {
    if ([self checkMsg] == NO) {//本地check是否合法
        return;
    }

    self.nick = self.nickname.text;
    self.user.username = self.account.text;
    self.user.password =  self.password.text;
 
    
//    NSDictionary *signUpDict = [[RuntimeStatus instance].usrSelf packetSignUpDict];
//    [HTTTClient sendData:signUpDict withProtocol:SIGN_UP];
    [self performSegueWithIdentifier:SIGN_UP_SEGUE sender:nil];
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

    
    if ( self.password.text.length < 6 ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"密码不合法" message:@"请输入至少6位密码" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        return NO;    //if fail, return. don't go to next page
    }
    //other msg check
    
    
    return YES;
}

#pragma mark - Navigation--通过次在两个controller中传递数据

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ViewControllerMsgCheck *desVC = segue.destinationViewController;
    desVC.nickname = self.nick;
    desVC.kiduser = self.user;
}

@end
