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


@end

@implementation ViewControllerMsgCheck

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self testcode];
}

- (void)testcode{
    self.checkCode = @"1";
}

-(void) freshRepickBtn{
    [self performSelector:@selector(changeString) withObject:self afterDelay:0];
    [self.btnRepickCode.titleLabel setText:@"重新获取验证码"];
}

-(void) changeString{
    static int a = 60;
    [self.btnRepickCode.titleLabel setText:[NSString stringWithFormat:@"重新获取验证码，%d",a--]];
    if (a==0) {
        [self.repickBtnFreshTimer invalidate];
        self.btnRepickCode.enabled = YES;
    }
}


- (IBAction)onRepickCode:(id)sender {
    
    ((UIButton *)sender).enabled = false;
    if (self.repickBtnFreshTimer==nil) {
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(freshRepickBtn) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] run];
    }
}

#define SEGUE_TO_MAIN @"segueToMain"

- (IBAction)onCheckMsg:(id)sender {
    if ([self.checkCode compare:@"1"] == NSOrderedSame ) {
        [self performSegueWithIdentifier:SEGUE_TO_MAIN sender:sender];
    }
//    [HTTTClient sendData:nil withProtocol:GET_CHECK_CODE];
//    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIFI_GET_CHECK_CODE object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
//        NSLog(@"do something");
//        [RuntimeStatus instance].signAccountUID = @"example";
//    }];
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
