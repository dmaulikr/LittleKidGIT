//
//  RootViewController.m
//  象棋Demo
//
//  Created by QzydeMac on 14/11/30.
//  Copyright (c) 2014年 Qzy. All rights reserved.
//

#import "RootViewController.h"
#import "CheseInterface.h"
#import "CheseTools.h"
#import <AVOSCloud/AVOSCloud.h>
#import "RuntimeStatus.h"
#import "CDSessionManager.h"


#define MAINSCREEN_WIDTH     ([[UIScreen mainScreen]bounds].size.width)
#define MAINSCREEN_HEIGHT      ([[UIScreen mainScreen]bounds].size.height)
//extern int ischessReverse;
@interface RootViewController ()
@property (weak, nonatomic) IBOutlet UIView *moreView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) NSArray *messages;
@property (nonatomic) BOOL isnoMusic;
@property(weak, nonatomic) NSTimer *repickBtnFreshTimer;
@property(nonatomic) NSDictionary *senddict;
@property(nonatomic)int ratio;
@end
static  BOOL isShouldChessPlayer = YES;
@implementation RootViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isnoMusic = self.cheseInterface.isnoMusic = FALSE;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(procCmd:) name:NOTIFICATION_PLAY_CHESS_UPDATED object:nil];    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatesendfailed:) name:NOTIFICATION_PLAY_CHESS_SEND_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatesendfinish:) name:NOTIFICATION_PLAY_CHESS_SEND_FINISH object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSessionPaused:) name:NOTIFICATION_SESSION_PAUSED object:nil];
    UIImageView *bacakGroundImage = [[UIImageView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    NSString *path = [[NSBundle mainBundle]pathForResource:@"music" ofType:@"mp3"];
    NSURL *url = [[NSURL alloc]initFileURLWithPath:path];
    self.play = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
    self.play.numberOfLoops = -1;
    [self.play prepareToPlay];
    [self.play play];
//    [self.play stop];
    bacakGroundImage.image = [UIImage imageNamed:@"象棋主界面.png"];
    bacakGroundImage.userInteractionEnabled = YES;
    [self.view addSubview:bacakGroundImage];
    lenthOfUnitWidth =  (int)(MAINSCREEN_WIDTH/9.14);
    lenthOfUnitHight = (MAINSCREEN_HEIGHT/14.4);
    lenthChesePieces = lenthOfUnitHight;
    widthChesePieces = lenthOfUnitWidth;
    chessboardStartPointy =  (int)(MAINSCREEN_HEIGHT/19.2);
    chessStartPointY = (int)chessboardStartPointy*3;
    chessStartPointX = 0;
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(procCmd:) name:NOTIFI_CHESS_MOVE object:nil];
    self.view.backgroundColor = [UIColor blackColor];
    _cheseInterface = [[CheseInterface alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    _cheseInterface.ischessReverse = self.isblack;
    isShouldChessPlayer = !self.isblack;
    self.mytime = [UILabel alloc];
    self.opponenttime = [UILabel alloc];
    
    [_cheseInterface loadCheseInterface];
    _cheseInterface.center = CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0);
    _cheseInterface.delegate = self;
    _cheseInterface.otherId = self.otherId;
    [self.view addSubview:_cheseInterface];

    
    self.repickBtnFreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
    
    self.sendCmd = 0;
    seconds = 180;
    CGRect mainrect = [[UIScreen mainScreen]bounds];//获取主屏
    
    UIButton * moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect rect = CGRectMake(0, mainrect.size.height*9/10, mainrect.size.height/10, mainrect.size.height/10);
    moreButton.frame = rect;
    UIImage * tmpimage = [UIImage imageNamed:@"菜单.png"];
    [moreButton setBackgroundImage:tmpimage forState:UIControlStateNormal];
    
    [moreButton addTarget:self action:@selector(more) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:moreButton];
    
    UIImageView *myphoto = [[UIImageView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    myphoto.image = [[RuntimeStatus instance] circleImage:[RuntimeStatus instance].userInfo.headImage withParam:0];
    CGFloat photowidth = mainrect.size.width/4.6;
    rect = CGRectMake(mainrect.size.width/2-photowidth/2, mainrect.size.height-photowidth, photowidth, photowidth);
    [myphoto setFrame:rect];
    
    [bacakGroundImage addSubview:myphoto];
    UIImageView *opponentphoto = [[UIImageView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    opponentphoto.image = [[RuntimeStatus instance] circleImage:[[RuntimeStatus instance] getFriendUserInfo:self.otherId].headImage withParam:0];
    [opponentphoto setFrame:CGRectMake(mainrect.size.width/2-photowidth/2, mainrect.size.height/30, photowidth, photowidth)];
    [bacakGroundImage addSubview:opponentphoto];
    UILabel *myname = [[UILabel alloc]initWithFrame:CGRectMake(mainrect.size.width/2+photowidth/2+mainrect.size.height/30, mainrect.size.height*0.9, mainrect.size.width/4, mainrect.size.width/16)];
    UILabel *mygrade = [[UILabel alloc]initWithFrame:CGRectMake(mainrect.size.width/2+photowidth/2+mainrect.size.height/30, mainrect.size.height*0.9+mainrect.size.width/16, mainrect.size.width/4, mainrect.size.width/16)];
    
    UILabel *opponentname = [[UILabel alloc]initWithFrame:CGRectMake(mainrect.size.width/2+photowidth/2+mainrect.size.height/30, mainrect.size.height*0.05, mainrect.size.width/4, mainrect.size.width/16)];
    
    UILabel *opponentgrade = [[UILabel alloc]initWithFrame:CGRectMake(mainrect.size.width/2+photowidth/2+mainrect.size.height/30, mainrect.size.height*0.05+mainrect.size.width/16, mainrect.size.width/4, mainrect.size.width/16)];
    myname.text = [RuntimeStatus instance].userInfo.nickname;
    NSNumber *levernumber = [RuntimeStatus instance].userInfo.score;
    mygrade.text = [self getGradeForNumber:levernumber];
    opponentname.text = [[RuntimeStatus instance] getFriendUserInfo:self.otherId].nickname;
    levernumber = [[RuntimeStatus instance] getFriendUserInfo:self.otherId].score;
    opponentgrade.text = [self getGradeForNumber:levernumber];
    self.mytime = [[UILabel alloc]initWithFrame:CGRectMake(mainrect.size.width/2-photowidth/2-mainrect.size.height/15, mainrect.size.height*0.9+mainrect.size.width/16, mainrect.size.width/4, mainrect.size.width/16)];
    self.opponenttime = [[UILabel alloc]initWithFrame:CGRectMake(mainrect.size.width/2-photowidth/2-mainrect.size.height/15, mainrect.size.height*0.05+mainrect.size.width/16, mainrect.size.width/4, mainrect.size.width/16)];
    self.mytime.font = self.opponenttime.font =[UIFont boldSystemFontOfSize:mainrect.size.width/32];
    self.mytime.textColor = self.opponenttime.textColor =[UIColor whiteColor];
    
    
    myname.font = [UIFont boldSystemFontOfSize:mainrect.size.width/32];
    opponentname.font =[UIFont boldSystemFontOfSize:mainrect.size.width/32];
    opponentname.textColor = myname.textColor = [UIColor whiteColor];
    opponentgrade.backgroundColor = opponentname.backgroundColor = mygrade.backgroundColor = myname.backgroundColor = [UIColor clearColor];
    mygrade.font = opponentgrade.font =[UIFont boldSystemFontOfSize:mainrect.size.width/32];
    mygrade.textColor = opponentgrade.textColor =[UIColor whiteColor];
    self.mytime.hidden = self.isblack;
    self.opponenttime.hidden = !self.isblack;
    [bacakGroundImage addSubview:self.mytime];
    [bacakGroundImage addSubview:self.opponenttime];
    [bacakGroundImage addSubview:myname];
    [bacakGroundImage addSubview:mygrade];
    [bacakGroundImage addSubview:opponentgrade];
    [bacakGroundImage addSubview:opponentname];
    [bacakGroundImage addSubview:myphoto];
 //   RNLongPressGestureRecognizer *longPress = [[RNLongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
//    [self.view addGestureRecognizer:longPress];
    [self showWhoShouldPlayChese:0];
}
-(void) shouldPlayChange
{
    isShouldChessPlayer = !isShouldChessPlayer;
    if (isShouldChessPlayer) {
        self.mytime.hidden = NO;
        self.opponenttime.hidden = YES;
    }
    else
    {
        self.mytime.hidden = YES;
        self.opponenttime.hidden = NO;
    }
}

-(NSString *)getGradeForNumber:(NSNumber *)number//0-12
{
    NSInteger i = number.integerValue;
    i = i/10000;
    switch (i) {
        case 0:
            return @"九级棋士";
        case 1:
            return @"八级棋士";
        case 2:
            return @"七级棋士";
        case 3:
            return @"六级棋士";
        case 4:
            return @"五级棋士";
        case 5:
            return @"四级棋士";
        case 6:
            return @"三级棋士";
        case 7:
            return @"二级棋士";
        case 8:
            return @"一级棋士";
        case 9:
            return @"三级大师";
        case 10:
            return @"二级大师";
        case 11:
            return @"一级大师";
        case 12:
            return @"特级大师";
        default:
            return nil;
    }
}

- (void)procCmd:(NSNotification *)notify
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *dict = notify.userInfo;
        NSString *fromID = [dict objectForKey:@"fromid"];
        dict = [dict objectForKey:@"cmd"];
        if (![fromID isEqualToString:self.otherId])
        {
            return;
        }
        NSString *cmd = [dict objectForKey:@"CHESS_CMD"];
        NSInteger cmdindex = [cmd integerValue];
        NSString *chess_x = [dict objectForKey:@"CHESS_X"];
        NSString *chess_tag = [dict objectForKey:@"CHESS_TAG"];
        NSInteger tag = [chess_tag integerValue];
        _cheseInterface.optionButton = (UIButton *)[self.cheseInterface viewWithTag:tag];
        //        NSLog(@"receve a data:%@",err);
        switch (cmdindex)
        {
            case CHESS_CMD_MOVE://MOVE
            {
                NSString *chess_y = [dict objectForKey:@"CHESS_Y"];
                NSInteger x = [chess_x integerValue];
                NSInteger y = [chess_y integerValue];
                x = 8 - x;
                y = 9 - y;
                CGPoint point;
                point.x =  chessStartPointX + (lenthOfUnitWidth*x);
                point.y = chessStartPointY + (lenthOfUnitHight*y);
                self.cheseInterface.pointLocation = point;
                seconds = 180;
                [self shouldPlayChange];
                [self.cheseInterface opponentmovechess];
            }
                break;
            case CHESS_CMD_REMOVE://REMOVE
            {
                NSString *chess_newtag = [dict objectForKey:@"NEW_CHESS_TAG"];
                NSInteger newtag = [chess_newtag integerValue];
                UIButton *newbutton =(UIButton *) [self.cheseInterface viewWithTag:newtag];
                [self.cheseInterface opponentremoveChesePiecesAnimation:newbutton];
                seconds = 180;
                [self shouldPlayChange];
            }
                break;
            case CHESS_CMD_DRAWOFFER:
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"对方请求和局" message:nil delegate:self cancelButtonTitle:@"可以"  otherButtonTitles:@"不可以", nil];
                [alert setTag:23];
                [alert show];
                break;
            }
            case CHESS_CMD_DEFEAL:
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"对方认输" message:nil delegate:self cancelButtonTitle:@"可以"  otherButtonTitles:nil, nil];
                [alert setTag:24];
                [alert show];
                break;
            }
            case CHESS_CMD_ACK:
            {
                NSString *chessack = [dict objectForKey:@"CHESS_CHOOSE"];
                [self.alertwait dismissWithClickedButtonIndex:0 animated:YES];
                self.alertwait = nil;
                switch (self.sendCmd)
                {
                    case CHESS_CMD_DRAWOFFER:
                    {
                        if ([chessack  isEqual: @"可以"])
                        {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"对方同意和局" message:nil delegate:self cancelButtonTitle:@"确定"  otherButtonTitles:nil, nil];
                            [alert setTag:27];
                            [alert show];
                        }
                        else
                        {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"对方不同意和局" message:nil delegate:self cancelButtonTitle:@"确定"  otherButtonTitles:nil, nil];
                            [alert setTag:28];
                            [alert show];
                        }
                    }
                        break;
                    default:
                        break;
                }
                break;
            }
            default:
                break;
        }
        
    });
    
}
- (void) updateSessionPaused:(NSNotification *)notify
{
    AVSession *session = notify.object;
    if (session.peerId == [RuntimeStatus instance].currentUser.username) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络不正常" message:nil delegate:self cancelButtonTitle:@"确定"  otherButtonTitles:nil, nil];
        [alert show];
    }
  
}
- (void)updatesendfailed:(NSNotification *)notify
{
        
        [[CDSessionManager sharedInstance] sendPlayChess:self.senddict toPeerId:self.otherId];
   
}
-(void)updatesendfinish:(NSNotification *)notify
{
    if (self.sendCmd == CHESS_CMD_MOVE) {
        seconds = 180;
        [self shouldPlayChange];
        [self.cheseInterface moveComplete];
        
    }
}
#pragma mark --定时器

static int seconds = 180;
-(void)timerFireMethod:(NSTimer *)theTimer {
    if (seconds == 0) {
        if (isShouldChessPlayer) {
            [self sendchessRequest:CHESS_CMD_DEFEAL];
            rezult = 0;
            [self Restart];
        }
        else
        {
            if ([[CDSessionManager sharedInstance] isOpen]) {
                rezult = 2;
                [self Restart];
            }
            else
            {
                rezult = 0;
                [self Restart];
            }
            
        }
    }else{
        seconds--;
        self.mytime.text = self.opponenttime.text = [NSString stringWithFormat:@"%d:%02d",seconds/60,seconds%60];
    }
}
- (void)sendack:(NSString *) string
{
    NSString *str_cmd = [[NSString alloc]initWithFormat:@"%d",CHESS_CMD_ACK];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:str_cmd,@"CHESS_CMD",string,@"CHESS_CHOOSE", nil];
    self.senddict = dict;
    self.sendCmd = CHESS_CMD_ACK;
    [[CDSessionManager sharedInstance] sendPlayChess:self.senddict toPeerId:self.otherId];
//    [[RuntimeStatus instance].udpP2P sendDict:dict toUser:self.cheseInterface.userother withProtocol:CHESS];
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{

    if ([alertView tag] ==23)
    {
        if (buttonIndex == 0)
        {
            [self sendack:@"可以"];
            rezult = 1;
            [self Restart];
        }
        else
        {
            [self sendack:@"不可以"];
            
        }
    }
    if ([alertView tag] ==24)
    {
        rezult =2;
        [self Restart];
    }
    if ([alertView tag] ==27)//和局
    {
        if (buttonIndex == 0)
        {
            rezult = 1;
            [self Restart];
        }
       
    }
    if ([alertView tag] == 56) {
       [self showchoujiangrezult];
    }
    
}

- (void)sendchessRequest :(NSInteger)index
{
    NSString *chesscmdtype = [[NSString alloc]initWithFormat:@"%d", (int)index];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:chesscmdtype,@"CHESS_CMD", nil];
    self.senddict = dict;
    self.sendCmd = CHESS_CMD_DRAWOFFER;
    [[CDSessionManager sharedInstance] sendPlayChess:self.senddict toPeerId:self.otherId];
}

-(void) off
{
    [self.delegate rootViewControllerCancel:self];
}

- (void)Restart
{

//    [_cheseInterface removenotifition];
    self.play =nil;
    [self.repickBtnFreshTimer invalidate];
    [_cheseInterface removeFromSuperview];
    [self addrezultView];
    
//    [_cheseInterface loadCheseInterface];
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    
//    UITableViewController* nextController = [storyboard instantiateViewControllerWithIdentifier:@"mainTabViewController"];
//    [self presentViewController:nextController animated:YES completion:nil];
//    [self dismissViewControllerAnimated:YES completion:nil];
    
//    ViewController *controller = [[ViewController alloc]init];
//    controller.delegate = self;
//    [self presentViewController:controller animated:YES completion:nil];
//    [self.navigationController pushViewController:controller animated:YES];

//    [self.delegate rootViewControllerCancel:self];
   
}
-(void) addrezultView
{
    
    //添加背景
    UIImageView *image_backgroup = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rezultBackgroup"]];
    image_backgroup.frame = [[UIScreen mainScreen]bounds];
    image2 = image_backgroup;
    [self.view addSubview:image2];
    //添加转盘
    CGFloat x = image_backgroup.frame.size.width;
    CGFloat disk_width = x*5/7;
    CGFloat disk_starty = 175;
    
    UIImageView *image_disk = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"抽奖盘"]];
    image_disk.frame = CGRectMake(x/7, disk_starty, disk_width , disk_width);
    image1 = image_disk;
    [self.view addSubview:image1];
    
    //添加转针
    CGFloat start_width = 120;
    UIImageView *image_start = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"start.png"]];
    image_start.frame = CGRectMake((x - start_width/2)/2, disk_starty + disk_width/2 - start_width /2, start_width/2, start_width);
    image2 = image_start;
    [self.view addSubview:image2];
    
    //添加按钮
    self.btn_start = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.btn_start.frame = CGRectMake(x/2 - 75, disk_starty + disk_width +60, 150.0, 40.0);
    [self.btn_start setBackgroundImage:[UIImage imageNamed:@"抽奖按键"] forState:UIControlStateNormal];
//    [self.btn_start setTitle:@"抽奖" ];
    [self.btn_start addTarget:self action:@selector(choujiang) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btn_start];
    
    CGFloat rezultwidty = 100;
    UIImageView *rezultimage = [[UIImageView alloc]initWithFrame:CGRectMake((x - rezultwidty)/2, disk_starty - 60, rezultwidty, 40)];
    
    if (rezult==0) {
        rezultimage.image = [UIImage imageNamed:@"战败"];
        increaseScore = 30;
        
    }
    else if(rezult == 1)
    {
        rezultimage.image = [UIImage imageNamed:@"和棋"];
        increaseScore = 100;
    }
    else if (rezult ==2)
    {
        rezultimage.image = [UIImage imageNamed:@"胜利"];
        increaseScore = 300;
    }
    [self.view addSubview:rezultimage];
    
}

- (void)choujiang
{
    //******************旋转动画******************
    //产生随机角度
    self.btn_start.enabled = FALSE;
    srand((unsigned)time(0));  //不加这句每次产生的随机数不变
    random = (rand() % 20) / 10.0;
    //设置动画
    CABasicAnimation *spin = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [spin setFromValue:[NSNumber numberWithFloat:M_PI * (0.0+orign)]];
    [spin setToValue:[NSNumber numberWithFloat:M_PI * (10.0+random+orign)]];
    [spin setDuration:2.5];
    [spin setDelegate:self];//设置代理，可以相应animationDidStop:finished:函数，用以弹出提醒框
    //速度控制器
    [spin setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    //添加动画
    [[image2 layer] addAnimation:spin forKey:nil];
    //锁定结束位置
    image2.transform = CGAffineTransformMakeRotation(M_PI * (10.0+random+orign));
    //锁定fromValue的位置
    orign = 10.0+random+orign;
    orign = fmodf(orign, 2.0);
    
}
-(void) showchoujiangrezult
{
    UIImageView *bacakGroundImage = [[UIImageView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    bacakGroundImage.image = [UIImage imageNamed:@"象棋主界面.png"];
    bacakGroundImage.userInteractionEnabled = YES;
    [self.view addSubview:bacakGroundImage];
    UIImageView *imageview = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"抽奖结果背景"]];
    CGFloat mainwidh = MAINSCREEN_WIDTH;
    CGFloat image_width = mainwidh *5/7;
    [imageview setFrame:CGRectMake(mainwidh/2 - image_width /2, 100, image_width, image_width*2 )];
    [self.view addSubview:imageview];
    
    UILabel *ratiolabel = [[UILabel alloc]initWithFrame:CGRectMake(imageview.frame.origin.x + image_width/2 - 50, imageview.frame.origin.y +150, 100, 20)];
    ratiolabel.text = [NSString stringWithFormat:@"%d * %d倍",(int)increaseScore,self.ratio];
    ratiolabel.textColor = [UIColor greenColor];
    ratiolabel.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:ratiolabel];
    
    UILabel *nowscorelabel = [[UILabel alloc]initWithFrame:CGRectMake(imageview.frame.origin.x + image_width/2 , imageview.frame.origin.y +190, 100, 30)];
    int nowscore = [[RuntimeStatus instance].userInfo.score intValue] + (int)increaseScore *self.ratio;
    [RuntimeStatus instance].userInfo.score  = [NSNumber numberWithInt:nowscore];
    [[RuntimeStatus instance] saveUserInfo];
    nowscorelabel.text = [NSString stringWithFormat:@"%d",nowscore];
    nowscorelabel.textColor = [UIColor whiteColor];
    nowscorelabel.textAlignment = UITextAlignmentLeft;
    [self.view addSubview:nowscorelabel];
    
    UILabel *needscorelabel = [[UILabel alloc]initWithFrame:CGRectMake(imageview.frame.origin.x + image_width/2, imageview.frame.origin.y +220, 100, 30)];
    int needscore = 10000- nowscore%10000;
    needscorelabel.text = [NSString stringWithFormat:@"%d",needscore];
    needscorelabel.textColor = [UIColor whiteColor];
    needscorelabel.textAlignment = UITextAlignmentLeft;
    [self.view addSubview:needscorelabel];
    
    UIButton *offbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    offbutton.frame = CGRectMake(imageview.frame.origin.x + image_width/2 -50, imageview.frame.origin.y +260, 100, 40);
    [offbutton setBackgroundImage:[UIImage imageNamed:@"离开按键"] forState:UIControlStateNormal];
    //    [self.btn_start setTitle:@"抽奖" ];
    [offbutton addTarget:self action:@selector(off) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:offbutton];

}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    self.ratio = 1;
    orign = orign - 0.1;
    if ((orign >= 0.0 && orign < (0.5/3.0)*2.0)||(orign >= 0.5 && orign < (0.5/3.0)*7.0)||(orign >= (0.5/3.0)*8.0 && orign < (0.5/3.0)*9.0)||(orign >= (0.5/3.0)*10.0 && orign < (0.5/3.0)*12.0))
    {
        self.ratio = 1;
    }
    else if((orign >= (0.5/3.0)*2.0 && orign < (0.5/3.0)*3.0)||(orign >= (0.5/3.0)*7.0 && orign < (0.5/3.0)*8.0))
    {
        self.ratio = 2;
    }
    else
    {
        self.ratio = 3;
    }
    UIAlertView *result = [[UIAlertView alloc] initWithTitle:@"恭喜中奖！" message:[[NSString alloc]initWithFormat:@"您获得了%d倍积分",self.ratio] delegate:self cancelButtonTitle:@"领奖去！" otherButtonTitles: nil];
    [result setTag:56];
    [result show];


}
//{
//    //判断抽奖结果
//    float ratio;
//    if (orign >= 0.0 && orign < (0.5/3.0)) {
//        ratio = 3;
//        UIAlertView *result = [[UIAlertView alloc] initWithTitle:@"恭喜中奖！" message:[[NSString alloc]initWithFormat:@"您中了 一等奖，获得了3倍积分，共%d积分",3*increaseScore] delegate:self cancelButtonTitle:@"领奖去！" otherButtonTitles: nil];
//        [result setTag:56];
//        [result show];
//    }
//    else if (orign >= (0.5/3.0) && orign < ((0.5/3.0)*2))
//    {
//        ratio = 1;
//        UIAlertView *result = [[UIAlertView alloc] initWithTitle:@"恭喜中奖！" message:[[NSString alloc]initWithFormat:@"您中了 七等奖，获得了1倍积分，共%d积分",increaseScore] delegate:self cancelButtonTitle:@"领奖去！" otherButtonTitles: nil];
//        [result setTag:56];
//        [result show];
//    }else if (orign >= ((0.5/3.0)*2) && orign < ((0.5/3.0)*3))
//    {
//        ratio = 1.2;
//        UIAlertView *result = [[UIAlertView alloc] initWithTitle:@"恭喜中奖！" message:[[NSString alloc]initWithFormat:@"您中了 六等奖，获得了1.2倍积分，共%d积分",(int)(increaseScore*1.2)] delegate:self cancelButtonTitle:@"领奖去！" otherButtonTitles: nil];
//        [result setTag:56];
//        [result show];
//    }else if (orign >= (0.0+0.5) && orign < ((0.5/3.0)+0.5))
//    {
//        ratio = 1;
//        UIAlertView *result = [[UIAlertView alloc] initWithTitle:@"恭喜中奖！" message:[[NSString alloc]initWithFormat:@"您中了 七等奖，获得了1倍积分，共%d积分",increaseScore] delegate:self cancelButtonTitle:@"领奖去！" otherButtonTitles: nil];
//        [result setTag:56];
//        [result show];
//    }else if (orign >= ((0.5/3.0)+0.5) && orign < (((0.5/3.0)*2)+0.5))
//    {
//        ratio = 1.5;
//        UIAlertView *result = [[UIAlertView alloc] initWithTitle:@"恭喜中奖！" message:[[NSString alloc]initWithFormat:@"您中了 五等奖，获得了1.5倍积分，共%d积分",(int)(increaseScore*1.5)] delegate:self cancelButtonTitle:@"领奖去！" otherButtonTitles: nil];
//        [result setTag:56];
//        [result show];
//    }else if (orign >= (((0.5/3.0)*2)+0.5) && orign < (((0.5/3.0)*3)+0.5))
//    {
//        ratio = 1;
//        UIAlertView *result = [[UIAlertView alloc] initWithTitle:@"恭喜中奖！" message:[[NSString alloc]initWithFormat:@"您中了 七等奖，获得了1倍积分，共%d积分",(int)(increaseScore*1)] delegate:self cancelButtonTitle:@"领奖去！" otherButtonTitles: nil];
//        [result setTag:56];
//        [result show];
//    }else if (orign >= (0.0+1.0) && orign < ((0.5/3.0)+1.0))
//    {
//        ratio = 1.8;
//        UIAlertView *result = [[UIAlertView alloc] initWithTitle:@"恭喜中奖！" message:[[NSString alloc]initWithFormat:@"您中了 四等奖，获得了1.8倍积分，共%d积分",(int)(increaseScore*1.8)] delegate:self cancelButtonTitle:@"领奖去！" otherButtonTitles: nil];
//        [result setTag:56];
//        [result show];
//    }else if (orign >= ((0.5/3.0)+1.0) && orign < (((0.5/3.0)*2)+1.0))
//    {
//        ratio = 1;
//        UIAlertView *result = [[UIAlertView alloc] initWithTitle:@"恭喜中奖！" message:[[NSString alloc]initWithFormat:@"您中了 七等奖，获得了1倍积分，共%d积分",(int)(increaseScore*1)] delegate:self cancelButtonTitle:@"领奖去！" otherButtonTitles: nil];
//        [result setTag:56];
//        [result show];
//    }else if (orign >= (((0.5/3.0)*2)+1.0) && orign < (((0.5/3.0)*3)+1.0))
//    {
//        ratio = 2;
//        UIAlertView *result = [[UIAlertView alloc] initWithTitle:@"恭喜中奖！" message:[[NSString alloc]initWithFormat:@"您中了 三等奖，获得了2倍积分，共%d积分",(int)(increaseScore*2)] delegate:self cancelButtonTitle:@"领奖去！" otherButtonTitles: nil];
//        [result setTag:56];
//        [result show];
//    }else if (orign >= (0.0+1.5) && orign < ((0.5/3.0)+1.5))
//    {
//        ratio = 1;
//        UIAlertView *result = [[UIAlertView alloc] initWithTitle:@"恭喜中奖！" message:[[NSString alloc]initWithFormat:@"您中了 七等奖，获得了1倍积分，共%d积分",(int)(increaseScore*1)] delegate:self cancelButtonTitle:@"领奖去！" otherButtonTitles: nil];
//        [result setTag:56];
//        [result show];
//    }else if (orign >= ((0.5/3.0)+1.5) && orign < (((0.5/3.0)*2)+1.5))
//    {
//        ratio = 2.5;
//        UIAlertView *result = [[UIAlertView alloc] initWithTitle:@"恭喜中奖！" message:[[NSString alloc]initWithFormat:@"您中了 二等奖，获得了2.5倍积分，共%d积分",(int)(increaseScore*2.5)] delegate:self cancelButtonTitle:@"领奖去！" otherButtonTitles: nil];
//        [result setTag:56];
//        [result show];
//    }else if (orign >= (((0.5/3.0)*2)+1.5) && orign < (((0.5/3.0)*3)+1.5))
//    {
//        ratio = 1;
//        UIAlertView *result = [[UIAlertView alloc] initWithTitle:@"恭喜中奖！" message:[[NSString alloc]initWithFormat:@"您中了 七等奖，获得了1倍积分，共%d积分",(int)(increaseScore*1)] delegate:self cancelButtonTitle:@"领奖去！" otherButtonTitles: nil];
//        [result setTag:56];
//        [result show];
//    }
//    increaseScore = increaseScore *ratio;
//    [RuntimeStatus instance].userInfo.score = [NSNumber numberWithInt:increaseScore];
//    [[RuntimeStatus instance] saveUserInfo];
//}
//
//#pragma mark -ViewControllerDelegate
//
//- (void)ViewControllerCancel:(ViewController *)Controller
//{
//    [self dismissViewControllerAnimated:YES completion:NULL];
//    [self.delegate rootViewControllerCancel:self];
//}

#pragma mark - RNGridMenuDelegate
- (void)turnoffMusic
{
    [self.play stop];
}
- (void)turnonMusic
{
    [self.play play];
}
- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex {
    NSLog(@"Dismissed with item %d: %@", itemIndex, item.title);
    
    switch (itemIndex) {
        case 0://关闭声音
            //self.sendCmd = CHESS_CMD_BACKMOVE;
            self.isnoMusic = ~self.isnoMusic;
            self.cheseInterface.isnoMusic = self.isnoMusic;
            if (self.isnoMusic) {
                [self turnoffMusic];
                
            }
            else
            {
                [self turnonMusic];
            }
            return;
        case 1:
            [self sendchessRequest:CHESS_CMD_DRAWOFFER];
            break;
        case 2:
            [self sendchessRequest:CHESS_CMD_DEFEAL];
            rezult = 0;
            [self Restart];
            return;
            
        default:
            break;
    }
     self.alertwait = [[UIAlertView alloc] initWithTitle:@"对待对方答复" message:nil delegate:self cancelButtonTitle:nil  otherButtonTitles:nil, nil];
    [self.alertwait setTag:30];
    [self.alertwait show];
    
}
-(void)cheseInterSendcmd:(NSDictionary *)dict
{
    self.senddict = dict;
    self.sendCmd = CHESS_CMD_MOVE;
    [[CDSessionManager sharedInstance] sendPlayChess:self.senddict toPeerId:self.otherId];
}

-(void) cheseInterRezult
{
    if (_cheseInterface.rezult) {
        rezult = 2;
    }
    else
    {
        rezult = 0;
    }
    [self Restart];
}

#pragma mark - Private

- (void)showImagesOnly {
    NSInteger numberOfOptions = 1;
    NSArray *images = @[
                        [UIImage imageNamed:@"抽奖结果背景"],
//                        [UIImage imageNamed:@"attachment"],
//                        [UIImage imageNamed:@"block"],
//                        [UIImage imageNamed:@"bluetooth"],
//                        [UIImage imageNamed:@"cube"],
//                        [UIImage imageNamed:@"download"],
//                        [UIImage imageNamed:@"enter"],
//                        [UIImage imageNamed:@"file"],
//                        [UIImage imageNamed:@"github"]
                        ];
    RNGridMenu *av = [[RNGridMenu alloc] initWithImages:[images subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    av.delegate = self;
    [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
}

- (void)showList {
    NSInteger numberOfOptions = 5;
    NSArray *options = @[
                         @"Next",
                         @"Attach",
                         @"Cancel",
                         @"Bluetooth",
                         @"Deliver",
                         @"Download",
                         @"Enter",
                         @"Source Code",
                         @"Github"
                         ];
    RNGridMenu *av = [[RNGridMenu alloc] initWithTitles:[options subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    av.delegate = self;
    //    av.itemTextAlignment = NSTextAlignmentLeft;
    av.itemFont = [UIFont boldSystemFontOfSize:18];
    av.itemSize = CGSizeMake(150, 55);
    [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
}

- (void)showGrid {
    NSInteger numberOfOptions = 3;
    if (self.isnoMusic) {
        NSArray *items = @[
                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"音乐"] title:@"音效"],
                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"菜单二级（求和）"] title:@"求和"],
                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"菜单二级（认输）"] title:@"认输"],
                           //  [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"bluetooth"] title:@"聊天"],
                           //  [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"cube"] title:@"设置"],
                           //  [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"download"] title:@"视频"],
                           //   [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"enter"] title:@"Enter"],
                           //   [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"file"] title:@"Source Code"],
                           //    [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"github"] title:@"Github"]
                           ];
        RNGridMenu *av = [[RNGridMenu alloc] initWithItems:[items subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
        av.delegate = self;
        //    av.bounces = NO;
        [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, 2*self.view.bounds.size.height/3.f)];
    }
    else
    {
        NSArray *items = @[
                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"音乐不删除"] title:@"音效"],
                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"菜单二级（求和）"] title:@"求和"],
                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"菜单二级（认输）"] title:@"认输"],
                           //  [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"bluetooth"] title:@"聊天"],
                           //  [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"cube"] title:@"设置"],
                           //  [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"download"] title:@"视频"],
                           //   [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"enter"] title:@"Enter"],
                           //   [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"file"] title:@"Source Code"],
                           //    [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"github"] title:@"Github"]
                           ];
        RNGridMenu *av = [[RNGridMenu alloc] initWithItems:[items subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
        av.delegate = self;
        //    av.bounces = NO;
        [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, 2*self.view.bounds.size.height/3.f)];
    }
    
    
    
    
   
}

- (void)showGridWithHeaderFromPoint:(CGPoint)point {
    NSInteger numberOfOptions = 4;
    NSArray *items = @[
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"attachment"] title:@"Attach"],
                       
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"bluetooth"] title:@"Bluetooth"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"cube"] title:@"Deliver"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"download"] title:@"Download"],
                      
                       ];
    
    RNGridMenu *av = [[RNGridMenu alloc] initWithItems:[items subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    av.delegate = self;
    av.bounces = NO;
    av.animationDuration = 0.2;
    av.blurExclusionPath = [UIBezierPath bezierPathWithOvalInRect:self.imageView.frame];
    av.backgroundPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0.f, 0.f, av.itemSize.width*3, av.itemSize.height*3)];
    
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
    header.text = @"Example Header";
    header.font = [UIFont boldSystemFontOfSize:18];
    header.backgroundColor = [UIColor clearColor];
    header.textColor = [UIColor whiteColor];
    header.textAlignment = NSTextAlignmentCenter;
    // av.headerView = header;
    
    [av showInViewController:self center:point];
}

- (void)showGridWithPath {
    NSInteger numberOfOptions = 9;
    NSArray *items = @[
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"arrow"] title:@"Next"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"attachment"] title:@"Attach"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"block"] title:@"Cancel"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"bluetooth"] title:@"Bluetooth"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"cube"] title:@"Deliver"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"download"] title:@"Download"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"enter"] title:@"Enter"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"file"] title:@"Source Code"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"github"] title:@"Github"]
                       ];
    
    RNGridMenu *av = [[RNGridMenu alloc] initWithItems:[items subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    av.delegate = self;
    //    av.bounces = NO;
    [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
}
-(void)more
{
  //  UIView *moreView = [UIView init]
    [self showGrid];
    // [self showGridWithHeaderFromPoint:CGPointMake(40, 400)];
}
- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [self showGridWithHeaderFromPoint:[longPress locationInView:self.view]];
    }
}
- (void)showWhoShouldPlayChese:(NSInteger)num
{
 /*   if (num==0)
    {
        _label.text = @"准备";
    }
    else if (num==1)//黑色
    {
        _label.text = @"黑色";
    }
    else
    {
        _label.text = @"红色";
    }
  */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
