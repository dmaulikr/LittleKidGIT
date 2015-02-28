//
//  invatedPlayViewController.m
//  LittleKid
//
//  Created by XC on 15-1-29.
//  Copyright (c) 2015年 李允恺. All rights reserved.
//

#import "invatedPlayViewController.h"
#import "CDSessionManager.h"
#import "RootViewController.h"
#import "RuntimeStatus.h"

@interface invatedPlayViewController ()

@property (strong,nonatomic) AVAudioPlayer *play;
@end

@implementation invatedPlayViewController
- (IBAction)accept {
    [self stopInvateMusic];
    [[CDSessionManager sharedInstance] invitePlayChessAck:@"同意" toPeerId:self.toid];
    RootViewController *vc = [[RootViewController alloc] init];
    vc.otherId = self.otherid.text;
    vc.isblack = TRUE;
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}
- (IBAction)reject{
    [self stopInvateMusic];
    [[CDSessionManager sharedInstance] invitePlayChessAck:@"不同意" toPeerId:self.toid];
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self playInvateMusic];
    self.otherid.text = self.toid;
    UIImageView *image_backgroup = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"invatedbackview"]];
    image_backgroup.frame = [[UIScreen mainScreen]bounds];
    [self.view addSubview:image_backgroup];
    UIImageView *headimageview = [[UIImageView alloc]initWithFrame:CGRectMake((image_backgroup.frame.size.width - 100)/2, 150, 100, 100)];
    headimageview.image = [[RuntimeStatus instance]circleImage:[[RuntimeStatus instance] getFriendUserInfo:self.toid].headImage withParam:0];
    [self.view addSubview:headimageview];
    UILabel * nicknamelabel = [[UILabel alloc]initWithFrame:CGRectMake((image_backgroup.frame.size.width - 100)/2, 270, 100, 20)];
    nicknamelabel.text = [[RuntimeStatus instance] getFriendUserInfo:self.toid].nickname;
    nicknamelabel.textColor = [UIColor whiteColor];
    nicknamelabel.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:nicknamelabel];
    UILabel * gradelabel = [[UILabel alloc]initWithFrame:CGRectMake((image_backgroup.frame.size.width - 100)/2, 300, 100, 20)];
    gradelabel.text = [[RuntimeStatus instance]getLevelString:[[RuntimeStatus instance] getFriendUserInfo:self.toid].score];
    gradelabel.textColor = [UIColor whiteColor];
    gradelabel.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:gradelabel];
    
    UIButton *btn_start = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn_start.frame = CGRectMake((image_backgroup.frame.size.width/2 - 100)/2, 430, 100, 40.0);
    [btn_start setBackgroundImage:[UIImage imageNamed:@"invatedaccept"] forState:UIControlStateNormal];
    //    [self.btn_start setTitle:@"抽奖" ];
    [btn_start addTarget:self action:@selector(accept) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn_start];
    
    UIButton *btn_reject = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn_reject.frame = CGRectMake((image_backgroup.frame.size.width* 3/2 - 150)/2, 430, 100, 40.0);
    [btn_reject setBackgroundImage:[UIImage imageNamed:@"invatedreject"] forState:UIControlStateNormal];
    //    [self.btn_start setTitle:@"抽奖" ];
    [btn_reject addTarget:self action:@selector(reject) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cancelInvate:) name:NOTIFICATION_CANCEL_INVATE object:nil];
    [self.view addSubview:btn_reject];
    
    // Do any additional setup after loading the view.
}
- (void) cancelInvate:(NSNotification *) notify
{
    [self stopInvateMusic];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rootViewControllerCancel:(RootViewController *)Controller
{
    NSLog(@"*** qb_imagePickerControllerDidCancel:");
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.navigationController popViewControllerAnimated:NO];
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
