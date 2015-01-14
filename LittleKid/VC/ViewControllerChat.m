//
//  ViewControllerChat.m
//  LittleKid
//
//  Created by 李允恺 on 12/18/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import "ViewControllerChat.h"
#import <AVFoundation/AVFoundation.h>
#import "SelfMsgTableViewCell.h"
#import "OtherMsgTableViewCell.h"
#import "RuntimeStatus.h"

@interface ViewControllerChat ()

@property (weak, nonatomic) IBOutlet UITableView *msgTableView;
@property(strong, atomic) AVAudioRecorder *recorder;
@property(strong, atomic) AVAudioPlayer *player;
@property(strong, atomic) NSDictionary *recorderSettingsDict;
@property (strong, nonatomic) NSString *dateToRecordStr;
@property(strong, nonatomic) UserOther *toChatUsr;/* @property设置 */
@property (weak, nonatomic) IBOutlet UIView *viewPanel;



@end

@implementation ViewControllerChat

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUI];
    self.toChatUsr = [[RuntimeStatus instance].recentUsrList objectAtIndex:self.toChatUsrIndex];
    [self testCode];
    [self prepareRecord];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(freshChat:) name:NOTIFI_GET_RECENT_MSG object:nil];
}

- (void)testCode{
    self.toChatUsr.usrIP = @"127.0.0.1";
    self.toChatUsr.usrPort = @"20107";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUI{
    self.msgTableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"liaotian_background.png"]];
    self.viewPanel.layer.cornerRadius = 20.f;
}

- (void)freshChat:(NSNotification *)notification{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.msgTableView reloadData];
    });
}

- (IBAction)touchDownRecord:(id)sender {
    NSError *error = nil;
    self.recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:[self msgDataSavePath]] settings:self.recorderSettingsDict error:&error];
    if (error) {
        NSLog(@"recorder error: %@",error);
    }
    if (self.recorder) {
        self.recorder.meteringEnabled = YES;
        [self.recorder prepareToRecord];
        [self.recorder record];
        //启动定时器
//        timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(levelTimer:) userInfo:nil repeats:YES];
    } else{
        NSLog(@"%@", error);
    }
}

- (IBAction)touchUpInsideSend:(id)sender {
    [self.recorder stop];
    //send the record
    [self updateMsg];
    [self sendMsg];
    self.recorder = nil;
    //结束定时器
    //[timer invalidate];
    //timer = nil;
}

-(BOOL)sendMsg{
    //if p2p is OK, go to p2p, else go to http
    
    //p2p
    [[RuntimeStatus instance].udpP2P sendDict:[self.toChatUsr packetLastChatMsg] toUser:self.toChatUsr withProtocol:RECENT_MSG_POST];
    return YES;
}

-(BOOL)updateMsg{
    ChatMessage *newMsg = [[ChatMessage alloc] init];
    newMsg.owner = MSG_OWNER_SELF;
    newMsg.type = MSG_TYPE_SOUND;
    newMsg.timeStamp = self.dateToRecordStr;
    newMsg.msg = [NSString stringWithFormat:@"%@%@.aac", self.toChatUsr.UID, newMsg.timeStamp];
    [self.toChatUsr.msgs addObject:newMsg];
    return YES;
}

- (IBAction)touchUpOutsideCancel:(id)sender {
    [self.recorder stop];
    self.recorder = nil;
    //结束定时器
    //[timer invalidate];
    //timer = nil;

}

-(BOOL) prepareRecord{
    __block BOOL bCanRecord = YES;
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 6.0 )
    {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession requestRecordPermission:^(BOOL granted) {
            if (granted) {
                bCanRecord = YES;
            }
            else {
                bCanRecord = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:nil
                                                message:@"app需要访问您的麦克风。\n请启用麦克风-设置/隐私/麦克风"
                                               delegate:nil
                                      cancelButtonTitle:@"关闭"
                                      otherButtonTitles:nil] show];
                                    });
            }
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    self.recorderSettingsDict =[[NSDictionary alloc] initWithObjectsAndKeys:
                           [NSNumber numberWithInt:kAudioFormatMPEG4AAC],AVFormatIDKey,
                           [NSNumber numberWithInt:1000.0],AVSampleRateKey,
                           [NSNumber numberWithInt:2],AVNumberOfChannelsKey,
                           [NSNumber numberWithInt:8],AVLinearPCMBitDepthKey,
                           [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                           [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                           nil];
    return bCanRecord;
}

/* 存储时使用这个path，读取信息时字节用msg.msg做path */
-(NSString *)msgDataSavePath{
    NSString *savePath;
    NSDate *dateToRecord = [NSDate date];
    NSDateFormatter *fmDate = [[NSDateFormatter alloc] init];
    [fmDate setDateFormat:@"YYYY-MM-DD-HH-MM-SS"];
    self.dateToRecordStr = [fmDate stringFromDate:dateToRecord];
    savePath = [NSString stringWithFormat:@"%@/%@/recent/%@%@.aac", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [RuntimeStatus instance].usrSelf.UID, self.toChatUsr.UID, self.dateToRecordStr];
    NSError *err;
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm createDirectoryAtPath:[savePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&err];
    if(err){
        NSLog(@"recordSavePath dir create err: %@",err);
    }
    return savePath;
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.toChatUsr.msgs count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatMessage *msg = [self.toChatUsr.msgs objectAtIndex:[indexPath row]];
    if ( NSOrderedSame == [msg.owner compare:@"1"] ) {//other message
        OtherMsgTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"otherMsgCell" forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[OtherMsgTableViewCell alloc] init];
        }
        cell.headImg.image = [UIImage imageNamed:@"5.png"];
        cell.headImg.layer.cornerRadius = 5.0f;
        cell.labelMsg.text = msg.msg;
        
        return cell;
    }
    else {//self message
        SelfMsgTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selfMsgCell" forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[SelfMsgTableViewCell alloc] init];
        }
        cell.headImg.image = [UIImage imageNamed:@"head.jpg"];
        cell.headImg.layer.cornerRadius = 5.0f;
        cell.labelMsg.text = msg.msg;
        
        return cell;
    }
}

- (void)configCell:(UITableViewCell *)cell{
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatMessage *msg =  [self.toChatUsr.msgs objectAtIndex:[indexPath row]];
    if ( NSOrderedSame == [msg.type compare:MSG_TYPE_SOUND]) {
        NSError *playerError;
        self.player = nil;
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:[self msgDataReadPath:msg]] error:&playerError];
        if (self.player == nil)
        {
            NSLog(@"ERror creating player: %@", [playerError description]);
        }else{
            [self.player play];
        }
    }
}
                       
- (NSString *)msgDataReadPath:(ChatMessage *)msg{
    return [NSString stringWithFormat:@"%@/%@/recent/%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [RuntimeStatus instance].usrSelf.UID, msg.msg];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end
