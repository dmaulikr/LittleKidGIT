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
#import "RuntimeStatus.h"
#import "CDSessionManager.h"

@interface InvitePlayViewController ()
@property (strong,nonatomic) AVAudioPlayer *play;
@end



@implementation InvitePlayViewController

- (instancetype)initWithUser:(NSString *)otherid {
    if ((self = [super init])) {
        self.otherId = otherid;
    }
    return self;
}
- (IBAction)onCancel{
    [self stopInvateMusic];
    [[CDSessionManager sharedInstance]cancelInvite:self.otherId];
     [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)rootViewControllerCancel:(UIViewController *)Controller
{
    NSLog(@"*** qb_imagePickerControllerDidCancel:");
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.navigationController popViewControllerAnimated:NO];
//    [Controller dealloc ];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.username.text = self.otherId;
    [self playInvateMusic];
    UIImageView *image_backgroup = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"背景"]];
    image_backgroup.frame = [[UIScreen mainScreen]bounds];
    [self.view addSubview:image_backgroup];
    UIImageView *headimageview = [[UIImageView alloc]initWithFrame:CGRectMake((image_backgroup.frame.size.width - 100)/2, 150, 100, 100)];
    headimageview.image = [[RuntimeStatus instance]circleImage:[[RuntimeStatus instance] getFriendUserInfo:self.otherId].headImage withParam:0];
    [self.view addSubview:headimageview];
    UILabel * nicknamelabel = [[UILabel alloc]initWithFrame:CGRectMake((image_backgroup.frame.size.width - 100)/2, 270, 100, 20)];
    nicknamelabel.text = [[RuntimeStatus instance] getFriendUserInfo:self.otherId].nickname;
    nicknamelabel.textColor = [UIColor whiteColor];
    nicknamelabel.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:nicknamelabel];
    UILabel * gradelabel = [[UILabel alloc]initWithFrame:CGRectMake((image_backgroup.frame.size.width - 100)/2, 300, 100, 20)];
    gradelabel.text = [[RuntimeStatus instance]getLevelString:[[RuntimeStatus instance] getFriendUserInfo:self.otherId].score];
    gradelabel.textColor = [UIColor whiteColor];
    gradelabel.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:gradelabel];
    
    UIButton *btn_start = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn_start.frame = CGRectMake((image_backgroup.frame.size.width - 150)/2, 430, 150.0, 40.0);
    [btn_start setBackgroundImage:[UIImage imageNamed:@"取消挑战按键"] forState:UIControlStateNormal];
    //    [self.btn_start setTitle:@"抽奖" ];
    [btn_start addTarget:self action:@selector(onCancel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn_start];
    
    if ([[CDSessionManager sharedInstance]peerIdIsOnline:self.otherId] == NO) {
        UILabel *offlineLabel = [[UILabel alloc]initWithFrame:CGRectMake((image_backgroup.frame.size.width - 150)/2, 320.0, 150.0, 40.0)];
        offlineLabel.text = @"对方可能不在线";
        offlineLabel.textColor = [UIColor redColor];
        offlineLabel.textAlignment = UITextAlignmentCenter;
        [self.view addSubview:offlineLabel];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageUpdated:) name:NOTIFICATION_INVITE_PLAY_CHESS_ACK_UPDATED object:nil];
    // Do any additional setup after loading the view.
}
-(void) playInvateMusic
{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"invate" ofType:@"mp3"];
    NSURL *url = [[NSURL alloc]initFileURLWithPath:path];
    self.play = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
    self.play.numberOfLoops = -1;
    [self.play prepareToPlay];
    [self.play play];
}
-(void) stopInvateMusic
{
    self.play = nil;
}
//cmd_dictionary @"cmd_type" @""ack_value"
- (void)messageUpdated:(NSNotification *)notification {
    [self stopInvateMusic];
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
            vc.delegate = self;
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
