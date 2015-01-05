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
#import "ChatMessage.h"

#define OTHER_UID @"12345"

@interface ViewControllerChat ()

@property(strong, atomic) AVAudioRecorder *recorder;
@property(strong, atomic) AVAudioPlayer *player;
@property(strong, atomic) NSDictionary *recorderSettingsDict;
@property(strong, nonatomic) NSString *recordPath;
@property (weak, nonatomic) IBOutlet UITableView *msgTableView;
@property (strong, nonatomic) NSDate *dateToRecord;


@end

@implementation ViewControllerChat

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareRecord];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(freshChat:) name:@"newRemoteMsg" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)freshChat:(NSNotification *)notification{
    NSLog(@"freshChat");
    NSString *nameString = [notification name];
    NSString *objectString = [notification object];
    NSDictionary *dictionary = [notification userInfo];
    NSLog(@"name = %@,object = %@,userInfo = %@",nameString,objectString,[dictionary objectForKey:@"key"]);
}

- (IBAction)touchDownRecord:(id)sender {
    NSError *error = nil;
    self.recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:[self recordPath]] settings:self.recorderSettingsDict error:&error];
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
    [self createMsg];
    [self sendRecord];
    self.recorder = nil;
    //结束定时器
    //[timer invalidate];
    //timer = nil;
}

-(BOOL)sendRecord{
    return YES;
}

-(BOOL)createMsg{
    ChatMessage *newMsg = [[ChatMessage alloc] init];
    newMsg.owner = @"1";
    newMsg.type = @"1";
    newMsg.timeStamp = [NSString stringWithFormat:@"%@",self.dateToRecord];
    newMsg.msg = [NSString stringWithFormat:@"%@%@.aac", OTHER_UID, self.dateToRecord];
    
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

-(NSString *)recordPath{
    NSString *savePath;
    self.dateToRecord = [[NSDate alloc] init];
    savePath = [NSString stringWithFormat:@"%@/%@/recent/%@%@.aac", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [RuntimeStatus instance].usrSelf.UID, self.dateToRecord, OTHER_UID];
    NSError *err;
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm createDirectoryAtPath:[savePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&err];
    return savePath;
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    

    cell = [tableView dequeueReusableCellWithIdentifier:@"otherMsgCell" forIndexPath:indexPath];
    cell = [tableView dequeueReusableCellWithIdentifier:@"selfMsgCell" forIndexPath:indexPath];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSError *playerError;
    self.player = nil;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:self.recordPath] error:&playerError];
    if (self.player == nil)
    {
        NSLog(@"ERror creating player: %@", [playerError description]);
    }else{
        [self.player play];
    }
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
