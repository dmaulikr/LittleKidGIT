//
//  ViewControllerLogin.m
//  LittleKid
//
//  Created by 李允恺 on 12/17/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import "ViewControllerLogin.h"
#import "RuntimeStatus.h"

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
}


#define SIGN_IN_SEGUE   @"signInSegue"

- (IBAction)onLogin:(id)sender {
    if ( [self.account.text length]==0 || [self.password.text length]==0 ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"用户名或密码不能为空" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    NSError *err;
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:self.account.text, @"uid", self.password.text, @"pwd", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: dict options:NSJSONWritingPrettyPrinted error:&err];
    if (err) {
        NSLog(@"%@",err);
        return;
    }
    [HTTTClient sendData:jsonData withProtocol:SIGN_IN];
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIFI_SIGN_IN object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSLog(@"I get the login reply");
        //check if right, then
        if ( YES == [self checkSignInInfo:note] ) {
            [RuntimeStatus instance].signAccountUID = self.account.text;
            [self performSegueWithIdentifier:SIGN_IN_SEGUE sender:nil];
        }
    }];
}

- (BOOL)checkSignInInfo:(NSNotification *)note{
    
    
    return YES;
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
