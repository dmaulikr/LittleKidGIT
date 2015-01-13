//
//  ViewControllerInfo.m
//  LittleKid
//
//  Created by 李允恺 on 12/17/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import "ViewControllerInfo.h"
#import "RuntimeStatus.h"

@interface ViewControllerInfo ()

@property (weak, nonatomic) IBOutlet UITextField *account;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *email;



@end

@implementation ViewControllerInfo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIFI_SIGN_UP object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        //code here to decide if segue to next
        if (note) {
            NSLog(@"get notify");
        }
        //判断是否重账号，获取短信验证码
        [self performSegueWithIdentifier:@"segueFromInfo" sender:self];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBtnSignUp:(id)sender {
    if ([self checkMsg] == NO) {//本地check是否合法
        return;
    }
    [self addMsgToUsrself];
    NSData *signUpJsondata = [[RuntimeStatus instance].usrSelf packetSignUpJsonData];
    [HTTTClient sendData:signUpJsondata withProtocol:SIGN_UP];
    [self waitStatus];
}

-(void)waitStatus{
    //wait status view
}


- (BOOL)checkMsg{
    //check telephone,email, etc
    NSLog(@"%@",self.account.text);
    if (self.account.text.length == 0 || self.account.text.length != 11 ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"账号错误" message:@"请输入11位手机号码" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        return NO;    //if fail, return. don't go to next page
    }
    //other msg check

    
    
    return YES;
}

-(void)addMsgToUsrself{
    [RuntimeStatus instance].usrSelf.UID = self.account.text;
    //add other msgs to usrSelf

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
