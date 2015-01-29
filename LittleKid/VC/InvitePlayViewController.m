//
//  InvitePlayViewController.m
//  LittleKid
//
//  Created by XC on 15-1-29.
//  Copyright (c) 2015年 李允恺. All rights reserved.
//

#import "InvitePlayViewController.h"
#import "CDCommonDefine.h"
#import "RootViewController.h"

@interface InvitePlayViewController ()

@end



@implementation InvitePlayViewController

- (instancetype)initWithUser:(NSString *)otherid {
    if ((self = [super init])) {
        self.otherId = otherid;
    }
    return self;
}
- (IBAction)onCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.username.text = self.otherId;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageUpdated:) name:NOTIFICATION_INVITE_PLAY_CHESS_ACK_UPDATED object:nil];
    // Do any additional setup after loading the view.
}

//cmd_dictionary @"cmd_type" @""ack_value"
- (void)messageUpdated:(NSNotification *)notification {
    NSDictionary *dict = notification.userInfo;
    dict = [dict objectForKey:@"cmd"];
    NSString *str = [dict objectForKey:@"cmd_type"];
    if ([str isEqualToString:INVITE_PLAY_CHESS_CMD_ACK] ) {
        str = [dict objectForKey:@"ack_value"];
        if ([str isEqualToString:@"同意"])//可以下象棋
        {
                RootViewController *vc = [[RootViewController alloc] init];
                vc.otherId = self.otherId;
                vc.isblack = FALSE;
                [self presentViewController:vc animated:YES completion:nil];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
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
