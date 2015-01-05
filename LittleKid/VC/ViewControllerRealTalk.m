//
//  ViewControllerRealTalk.m
//  LittleKid
//
//  Created by 李允恺 on 12/19/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import "ViewControllerRealTalk.h"

@interface ViewControllerRealTalk ()

@property (strong, nonatomic) AnyChatPlatform   *anyChat;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer    *localVideoSurface;
@property (strong, nonatomic) IBOutlet UIImageView          *remoteVideoSurface;
@property (strong, nonatomic) IBOutlet UIView               *theLocalView;
@property (weak, nonatomic) IBOutlet UIButton               *switchCameraBtn;
@property (weak, nonatomic) IBOutlet UIButton               *endCallBtn;
@property (weak, nonatomic) IBOutlet UIButton               *voiceBtn;
@property (weak, nonatomic) IBOutlet UIButton               *cameraBtn;

- (IBAction) FinishVideoChatBtnClicked:(id)sender;

- (IBAction) OnSwitchCameraBtnClicked:(id)sender;

- (IBAction) OnCloseVoiceBtnClicked:(id)sender;

- (IBAction) OnCloseCameraBtnClicked:(id)sender;

- (void) FinishVideoChat;

- (void) StartVideoChat:(int) userid;

- (void) btnSelectedOnClicked:(UIButton*)button;


@end

@implementation ViewControllerRealTalk

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AnyChatNotifyHandler:) name:@"ANYCHATNOTIFY" object:nil];
    [AnyChatPlatform InitSDK:0];
    self.anyChat = [[AnyChatPlatform alloc] init];
    self.anyChat.notifyMsgDelegate = self;
    [AnyChatPlatform Connect:[RuntimeStatus instance].realTalkServerIP : [[RuntimeStatus instance].realTalkServerPort intValue]];
    [AnyChatPlatform Login:[RuntimeStatus instance].realTalkUsrName : [RuntimeStatus instance].realTalkUsrPwd];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    [RuntimeStatus instance].realTalkRemoteUsrID = textField.text;
    [self StartVideoChat:[[RuntimeStatus instance].realTalkRemoteUsrID intValue]];
    return  YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AnyChatNotifyMessageDelegate

// 连接服务器消息
- (void) OnAnyChatConnect:(BOOL) bSuccess
{
    if (bSuccess)
    {
        NSLog(@"Connect success");
    }
    else{
        NSLog(@"Connect error");
    }
}

// 用户登陆消息
- (void) OnAnyChatLogin:(int) dwUserId : (int) dwErrorCode
{
    //    onlineUserMArray = [NSMutableArray arrayWithCapacity:5];
    
    if(dwErrorCode == GV_ERR_SUCCESS)
    {
        NSLog(@"login success");
        [RuntimeStatus instance].realTalkUsrID = [NSString stringWithFormat:@"%d",dwUserId];
        NSLog(@"self usrID is %@",[RuntimeStatus instance].realTalkUsrID);
        //[self saveSettings];  //save correct configuration
        [AnyChatPlatform EnterRoom:[[RuntimeStatus instance].realTalkRoomNumber intValue] : [RuntimeStatus instance].realTalkRoomPwd];
    }
    else
    {
        NSLog(@"enter room error");
    }
    
}

// 自己进入房间状态及ID
- (void) OnAnyChatEnterRoom:(int) dwRoomId : (int) dwErrorCode
{
    if (dwErrorCode != 0)
    {
        NSLog(@"get online user array: %@",[self getOnlineUserArray]);
    }
    else
    {
        NSLog(@"enter room error, err code: %d",dwErrorCode);
    }
}

// 房间在线用户消息
- (void) OnAnyChatOnlineUser:(int) dwUserNum : (int) dwRoomId
{
    [RuntimeStatus instance].realTalkOnlineUsrList = [self getOnlineUserArray];
    NSLog(@"have got the user number, %d",dwUserNum);
    
}

// 用户进入房间消息
- (void) OnAnyChatUserEnterRoom:(int) dwUserId
{
    [RuntimeStatus instance].realTalkOnlineUsrList = [self getOnlineUserArray];
    NSLog(@"someone got in");
}

// 用户退出房间消息
- (void) OnAnyChatUserLeaveRoom:(int) dwUserId
{
    if ([[RuntimeStatus instance].realTalkRemoteUsrID intValue] == dwUserId ) {
        [self FinishVideoChat];
        [RuntimeStatus instance].realTalkRemoteUsrID = @"-1";
    }
    NSLog(@"someone got out");
    [RuntimeStatus instance].realTalkOnlineUsrList = [self getOnlineUserArray];
}

// 网络断开消息
- (void) OnAnyChatLinkClose:(int) dwErrorCode
{
    [self FinishVideoChat];
    [AnyChatPlatform LeaveRoom:-1];
    [AnyChatPlatform Logout];
    NSLog(@"disconnect to anychat server");
}

#pragma mark - Get & Save Settings Method

- (id) GetServerIP
{
    NSString* serverIP;
    return serverIP;
}

- (id) GetServerPort
{
    NSString* serverPort;
    return serverPort;
}

- (id) GetUserName
{
    NSString* userName;
    return userName;
}

- (id) GetRoomNO
{
    NSString* roomNO;
    return roomNO;
}

- (void)saveSettings
{   // save settings to file
}


#pragma mark - Connect Instance Method

- (void)AnyChatNotifyHandler:(NSNotification*)notify
{
    NSDictionary* dict = notify.userInfo;
    [self.anyChat OnRecvAnyChatNotify:dict];
}

- (NSMutableArray *) getOnlineUserArray
{
    NSMutableArray *onlineUserList = [[NSMutableArray alloc] initWithArray:[AnyChatPlatform GetOnlineUser]];
    [onlineUserList insertObject:[RuntimeStatus instance].realTalkUsrID atIndex:0];
    return onlineUserList;
}


- (void) onLogout
{
    [AnyChatPlatform LeaveRoom:-1];
    [AnyChatPlatform Logout];
}

- (int)getRandomNumber:(int)from to:(int)to
{
    //  +1,result is [from to]; else is [from, to)!!!!!!!
    return (int)(from + (arc4random() % (to - from + 1)));
}




#pragma mark - Video Instance Method


- (void) StartVideoChat:(int) userid
{
    //Get a camera, Must be in the real machine.
    NSMutableArray* cameraDeviceArray = [AnyChatPlatform EnumVideoCapture];
    if (cameraDeviceArray.count > 0)
    {
        [AnyChatPlatform SelectVideoCapture:[cameraDeviceArray objectAtIndex:1]];
    }
    
    // open local video
    [AnyChatPlatform SetSDKOptionInt:BRAC_SO_LOCALVIDEO_OVERLAY :1];
    [AnyChatPlatform UserSpeakControl: -1:YES];
    [AnyChatPlatform SetVideoPos:-1 :self :0 :0 :0 :0];
    [AnyChatPlatform UserCameraControl:-1 : YES];
    // request other user video
    [AnyChatPlatform UserSpeakControl: userid:YES];
    [AnyChatPlatform SetVideoPos:userid: self.remoteVideoSurface:0:0:0:0];
    [AnyChatPlatform UserCameraControl:userid : YES];
    
    [RuntimeStatus instance].realTalkRemoteUsrID = [NSString stringWithFormat:@"%d",userid];
    
    //[AnyChatPlatform SetSDKOptionInt:BRAC_SO_LOCALVIDEO_ORIENTATION : self.interfaceOrientation];
}


- (void) FinishVideoChat
{
    // 关闭摄像头
    [AnyChatPlatform UserSpeakControl: -1 : NO];
    [AnyChatPlatform UserCameraControl: -1 : NO];
    
    [AnyChatPlatform UserSpeakControl:  [[RuntimeStatus instance].realTalkRemoteUsrID intValue] : NO];
    [AnyChatPlatform UserCameraControl: [[RuntimeStatus instance].realTalkRemoteUsrID intValue] : NO];
    
    [RuntimeStatus instance].realTalkRemoteUsrID = [NSString stringWithFormat:@"%d",-1];
}

- (IBAction)OnCloseVoiceBtnClicked:(id)sender
{
    if (((UIButton *)sender).selected == NO)
    {
        [AnyChatPlatform UserSpeakControl:-1 :NO];
        ((UIButton *)sender).selected = YES;
    }
    else
    {
        [AnyChatPlatform UserSpeakControl: -1:YES];
        ((UIButton *)(sender)).selected = NO;
    }
}

- (IBAction)OnCloseCameraBtnClicked:(id)sender
{
    if ([AnyChatPlatform GetCameraState:-1] == 1)
    {   //open local Camera
        [AnyChatPlatform SetVideoPos:-1 :self :0 :0 :0 :0];
        [AnyChatPlatform UserCameraControl:-1 : YES];
        self.theLocalView.hidden = NO;
        ((UIButton *)(sender)).selected = NO;
    }
    
    if ([AnyChatPlatform GetCameraState:-1] == 2)
    {   //close local Camera
        [AnyChatPlatform UserCameraControl:-1 :NO];
        self.theLocalView.hidden = YES;
        ((UIButton *)(sender)).selected = YES;
    }
}

- (IBAction)FinishVideoChatBtnClicked:(id)sender
{
    [self FinishVideoChat];
    [self onLogout];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) OnSwitchCameraBtnClicked:(id)sender
{
    static int CurrentCameraDevice = 1;
    NSMutableArray* cameraDeviceArray = [AnyChatPlatform EnumVideoCapture];
    if(cameraDeviceArray.count == 2)
    {
        CurrentCameraDevice = (++CurrentCameraDevice) % 2;
        [AnyChatPlatform SelectVideoCapture:[cameraDeviceArray objectAtIndex:CurrentCameraDevice]];
    }
    
    [self btnSelectedOnClicked:(UIButton *)sender];
}

- (void) OnLocalVideoRelease:(id)sender
{
    if(self.localVideoSurface) {
        self.localVideoSurface = nil;
    }
}

- (void) OnLocalVideoInit:(id)session
{
    self.localVideoSurface = [AVCaptureVideoPreviewLayer layerWithSession: (AVCaptureSession*)session];
    //self.localVideoSurface.frame = CGRectMake(0, 0, kLocalVideo_Width, kLocalVideo_Height);
    self.localVideoSurface.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.theLocalView.layer addSublayer:self.localVideoSurface];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)setUIControls
{
    //Local View line
    self.theLocalView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.theLocalView.layer.borderWidth = 1.0f;
    //Rounded corners
    self.theLocalView.layer.cornerRadius = 4;
    self.theLocalView.layer.masksToBounds = YES;
}

- (void) btnSelectedOnClicked:(UIButton*)button
{
    if (button.selected)
    {
        button.selected = NO;
    }
    else
    {
        button.selected = YES;
    }
}

//iRemote user video loading status
-(BOOL)remoteVideoDidLoadStatus
{
    BOOL isDidLoad;
    int videoHeight = 0;
    int theTimes = 0;
    
    while (isDidLoad == NO && theTimes < 5000)
    {
        videoHeight = [AnyChatPlatform GetUserVideoHeight:[[RuntimeStatus instance].realTalkRemoteUsrID intValue]];
        
        if (videoHeight > 0) {
            isDidLoad = YES;
        }
        else
        {
            isDidLoad = NO;
            theTimes++;
        }
    }
    
    return isDidLoad;
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
