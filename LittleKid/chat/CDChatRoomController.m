//
//  CDChatRoomController.m
//  AVOSChatDemo
//
//  Created by Qihe Bian on 7/28/14.
//  Copyright (c) 2014 AVOS. All rights reserved.
//

#import "CDChatRoomController.h"
#import "CDSessionManager.h"
#import "CDChatDetailController.h"
#import "QBImagePickerController.h"
#import "UIImage+Resize.h"
#import "User.h"
#import <AVFoundation/AVFoundation.h>

@interface CDChatRoomController () <JSMessagesViewDelegate, JSMessagesViewDataSource, QBImagePickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate> {
    NSMutableArray *_timestampArray;
    NSDate *_lastTime;
    NSMutableDictionary *_loadedData;
}
@property (nonatomic, strong) NSArray *messages;
@property(strong, atomic) AVAudioRecorder *recorder;
@property(strong, atomic) AVAudioPlayer *player;
@property(strong, atomic) NSDictionary *recorderSettingsDict;
@property (strong, nonatomic) NSString *dateToRecordStr;
@property(strong, nonatomic) UserOther *toChatUsr;/* @property设置 */
@property(strong, nonatomic)AVAudioSession *session;
@property NSInteger cellcount;
@end

@implementation CDChatRoomController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    if ((self = [super init])) {
        self.hidesBottomBarWhenPushed = YES;
        _loadedData = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _session = [AVAudioSession sharedInstance];
    self.toChatUsr = [[UserOther alloc]init];
    self.toChatUsr.UID = self.otherId;
    //   self.toChatUsr = [[RuntimeStatus instance].recentUsrList objectAtIndex:self.toChatUsrIndex];
    //    [self testCode];
    [self prepareRecord];
    if (self.type == CDChatRoomTypeGroup) {
        NSString *title = @"group";
        if (self.group.groupId) {
            title = [NSString stringWithFormat:@"group:%@", self.group.groupId];
        }
        self.title = title;
    } else {
        self.title = self.otherId;
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showDetail:)];
    UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"liaotian_background.png"]];
    [self.tableView setBackgroundView:imgView];
    [self setBackgroundColor:[UIColor clearColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageUpdated:) name:NOTIFICATION_MESSAGE_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionUpdated:) name:NOTIFICATION_SESSION_UPDATED object:nil];
    
    self.delegate = self;
    self.dataSource = self;
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RESET_UNREADMSG object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self messageUpdated:nil];
//    [AVAnalytics event:@"likebutton" attributes:@{@"source":@{@"view": @"week"}, @"do":@"unfollow"}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshTimestampArray {
    NSDate *lastDate = nil;
    NSMutableArray *hasTimestampArray = [NSMutableArray array];
    for (NSDictionary *dict in self.messages) {
        NSDate *date = [dict objectForKey:@"time"];
        if (!lastDate) {
            lastDate = date;
            [hasTimestampArray addObject:[NSNumber numberWithBool:YES]];
        } else {
            if ([date timeIntervalSinceDate:lastDate] > 60) {
                [hasTimestampArray addObject:[NSNumber numberWithBool:YES]];
                lastDate = date;
            } else {
                [hasTimestampArray addObject:[NSNumber numberWithBool:NO]];
            }
        }
    }
    _timestampArray = hasTimestampArray;
}

- (void)showDetail:(id)sender {
    CDChatDetailController *controller = [[CDChatDetailController alloc] init];
    controller.type = self.type;
    if (self.type == CDChatRoomTypeSingle) {
        controller.otherId = self.otherId;
    } else if (self.type == CDChatRoomTypeGroup) {
        controller.otherId = self.group.groupId;
    }
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger i= self.messages.count;
    if (i>10) {
        self.cellcount = 10;
    }
    else
    {
        self.cellcount = self.messages.count;
    }
    return self.cellcount;
    
}

#pragma mark - Messages view delegate
- (void)sendPressed:(UIButton *)sender withText:(NSString *)text {
    if (self.type == CDChatRoomTypeGroup) {
        if (!self.group.groupId) {
            return;
        }
        [[CDSessionManager sharedInstance] sendMessage:text toGroup:self.group.groupId];
    } else {
        [[CDSessionManager sharedInstance] sendMessage:text toPeerId:self.otherId];
    }
    [self refreshTimestampArray];
    [self finishSend];
}

- (void)sendAttachment:(AVObject *)object {
    if (self.type == CDChatRoomTypeGroup) {
        if (!self.group.groupId) {
            return;
        }
        [[CDSessionManager sharedInstance] sendAttachment:object toGroup:self.group.groupId];
    } else {
        [[CDSessionManager sharedInstance] sendAttachment:object toPeerId:self.otherId];
    }
    [self refreshTimestampArray];
    [self finishSend];

}

- (void)cameraPressed:(id)sender{
    
    [self.inputToolBarView.textView resignFirstResponder];

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
    [actionSheet showInView:self.view];
}
- (void)soundTouchDoun:(id)sender
{
    NSError *error = nil;
    NSString * file = [self msgDataSavePath];
    NSURL *url = [NSURL fileURLWithPath:file];
    [self.session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:self.recorderSettingsDict error:&error];
    if (error) {
        NSLog(@"recorder error: %@",error);
    }
    if (self.recorder) {
        self.recorder.meteringEnabled = YES;
        if([self.recorder prepareToRecord])
        {
            NSLog(@"Prepare successful");
        }
        [self.recorder record];
        //启动定时器
        //        timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(levelTimer:) userInfo:nil repeats:YES];
    } else{
        NSLog(@"%@", error);
    }
}
- (void)soundTouchUp:(id)sender
{
    [self.session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [self.recorder stop];
    //send the record
    [self updateMsg];
    //    [self sendMsg];
    self.recorder = nil;
//    [self.toChatUsr packetLastChatMsg];
    ;
    ChatMessage *msg = [self.toChatUsr.msgs lastObject];
    NSString *file = [self msgDataReadPath:msg];
    NSData *imageData = [NSData dataWithContentsOfFile:file];
    NSLog(@"image size %lu", (unsigned long)[imageData length]);
    AVFile *imageFile = [AVFile fileWithName:@"image.png" data:imageData];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            AVObject *object = [AVObject objectWithClassName:@"Attachments"];
            [object setObject:@"image" forKey:@"type"];
            [object setObject:imageFile forKey:@"image"];
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [self sendAttachment:object];
                }
            }];
        }
    }];
    [self refreshTimestampArray];
    [self finishSend];
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *fromid = [[self.messages objectAtIndex:indexPath.row] objectForKey:@"fromid"];
    
    return (![fromid isEqualToString:[AVUser currentUser].username]) ? JSBubbleMessageTypeIncoming : JSBubbleMessageTypeOutgoing;
}

- (JSBubbleMessageStyle)messageStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return JSBubbleMessageStyleFlat;
}

- (JSBubbleMediaType)messageMediaTypeForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *type = [[self.messages objectAtIndex:indexPath.row] objectForKey:@"type"];

    if ([type isEqualToString:@"text"]) {
        return JSBubbleMediaTypeText;
    } else if ([type isEqualToString:@"image"]) {
        return JSBubbleMediaTypeImage;
    }
    else if ([type isEqualToString:@"sound"])
    {
        return JSBubbleMediaTypeText;
    }
    return JSBubbleMediaTypeText;

//    if([[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Text"]){
//        return JSBubbleMediaTypeText;
//    }else if ([[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Image"]){
//        return JSBubbleMediaTypeImage;
//    }
//    
//    return -1;
}

- (UIButton *)sendButton
{
    return [UIButton defaultSendButton];
}

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
    /*
     JSMessagesViewTimestampPolicyAll = 0,
     JSMessagesViewTimestampPolicyAlternating,
     JSMessagesViewTimestampPolicyEveryThree,
     JSMessagesViewTimestampPolicyEveryFive,
     JSMessagesViewTimestampPolicyCustom
     */
    return JSMessagesViewTimestampPolicyCustom;
}

- (JSMessagesViewAvatarPolicy)avatarPolicy
{
    /*
     JSMessagesViewAvatarPolicyIncomingOnly = 0,
     JSMessagesViewAvatarPolicyBoth,
     JSMessagesViewAvatarPolicyNone
     */
    return JSMessagesViewAvatarPolicyNone;
}

- (JSAvatarStyle)avatarStyle
{
    /*
     JSAvatarStyleCircle = 0,
     JSAvatarStyleSquare,
     JSAvatarStyleNone
     */
    return JSAvatarStyleNone;
}

- (JSInputBarStyle)inputBarStyle
{
    /*
     JSInputBarStyleDefault,
     JSInputBarStyleFlat
     
     */
    return JSInputBarStyleFlat;
}

//  Optional delegate method
//  Required if using `JSMessagesViewTimestampPolicyCustom`
//
- (BOOL)hasTimestampForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[_timestampArray objectAtIndex:indexPath.row] boolValue];
}

- (BOOL)hasNameForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.type == CDChatRoomTypeGroup) {
        return YES;
    }
    return NO;
}

#pragma mark - Messages view data source
- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if([[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Text"]){
//        return [[self.messageArray objectAtIndex:indexPath.row] objectForKey:@"Text"];
//    }
    return [[self.messages objectAtIndex:indexPath.row] objectForKey:@"message"];
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDate *time = [[self.messages objectAtIndex:indexPath.row] objectForKey:@"time"];
    return time;
}

- (NSString *)nameForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *name = [[self.messages objectAtIndex:indexPath.row] objectForKey:@"fromid"];
    return name;
}

- (UIImage *)avatarImageForIncomingMessage {
    return [UIImage imageNamed:@"demo-avatar-jobs"];
}

- (SEL)avatarImageForIncomingMessageAction {
    return @selector(onInComingAvatarImageClick);
}

- (void)onInComingAvatarImageClick {
    NSLog(@"__%s__",__func__);
}

- (SEL)avatarImageForOutgoingMessageAction {
    return @selector(onOutgoingAvatarImageClick);
}

- (void)onOutgoingAvatarImageClick {
    NSLog(@"__%s__",__func__);
}

- (UIImage *)avatarImageForOutgoingMessage
{
    return [UIImage imageNamed:@"demo-avatar-woz"];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSNumber *i = @(indexPath.row);
    AVFile *file = [_loadedData objectForKey:i];
    if (file) {
        NSData *data = [file getData];
        NSError *playerError;
        self.player = nil;
        self.player = [[AVAudioPlayer alloc] initWithData:data error:&playerError];
        self.player.numberOfLoops = 0;
        if (self.player == nil)
        {
            NSLog(@"ERror creating player: %@", playerError);
        }else{
            [self.player play];
        }
    }
  
}
- (id)dataForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger i = self.messages.count - self.cellcount + indexPath.row;
    NSNumber *r = @(i);
    AVFile *file = [_loadedData objectForKey:r];
    if (file) {
        NSData *data = [file getData];
        UIImage *image = [[UIImage alloc] initWithData:data];
        return image;
    } else {
        NSString *objectId = [[self.messages objectAtIndex:i] objectForKey:@"object"];
        NSString *type = [[self.messages objectAtIndex:i] objectForKey:@"type"];
        AVObject *object = [AVObject objectWithoutDataWithClassName:@"Attachments" objectId:objectId];
        [object fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
            AVFile *file = [object objectForKey:type];
            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                [_loadedData setObject:file forKey:r];
                [self.tableView reloadData];
            }];
        }];
        UIImage *image = [UIImage imageNamed:@"image_placeholder"];
        return image;
    }
}

- (void)messageUpdated:(NSNotification *)notification {
    NSArray *messages = nil;
    if (self.type == CDChatRoomTypeGroup) {
        NSString *groupId = self.group.groupId;
        if (!groupId) {
            return;
        }
        messages = [[CDSessionManager sharedInstance] getMessagesForGroup:groupId];
    } else {
        messages = [[CDSessionManager sharedInstance] getMessagesForPeerId:self.otherId];
    }
    self.messages = messages;
    [self refreshTimestampArray];
    [self.tableView reloadData];
    [self scrollToBottomAnimated:YES];
}

- (void)sessionUpdated:(NSNotification *)notification {
    if (self.type == CDChatRoomTypeGroup) {
        NSString *title = @"group";
        if (self.group.groupId) {
            title = [NSString stringWithFormat:@"group:%@", self.group.groupId];
        }
        self.title = title;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
        {
            @try {
                UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                imagePickerController.delegate = self;
                imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:imagePickerController animated:YES completion:^{
                    
                }];
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
        }
            break;
        case 1:
        {
            QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.allowsMultipleSelection = NO;
            //            imagePickerController.minimumNumberOfSelection = 3;
            
            //                [self.navigationController pushViewController:imagePickerController animated:YES];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
            [self presentViewController:navigationController animated:YES completion:^{
                
            }];

        }
            break;
        default:
            break;
    }
}

- (void)dismissImagePickerController
{
    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    } else {
        [self.navigationController popToViewController:self animated:YES];
    }
}

#pragma mark - QBImagePickerControllerDelegate

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset
{
    NSLog(@"*** qb_imagePickerController:didSelectAsset:");
    NSLog(@"%@", asset);
    ALAssetRepresentation *representation = [asset defaultRepresentation];
    Byte *buffer = (Byte*)malloc((unsigned long)representation.size);
    
    // add error checking here
    NSUInteger buffered = [representation getBytes:buffer fromOffset:0.0 length:(NSUInteger)representation.size error:nil];
    NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
    if (data) {
        AVFile *imageFile = [AVFile fileWithName:@"image.png" data:data];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                AVObject *object = [AVObject objectWithClassName:@"Attachments"];
                [object setObject:@"image" forKey:@"type"];
                [object setObject:imageFile forKey:@"image"];
                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        [self sendAttachment:object];
                    }
                }];
            }
        }];
    }
    [self dismissImagePickerController];
}

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets
{
    NSLog(@"*** qb_imagePickerController:didSelectAssets:");
    NSLog(@"%@", assets);
    
    [self dismissImagePickerController];
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    NSLog(@"*** qb_imagePickerControllerDidCancel:");
    
    [self dismissImagePickerController];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    if (image) {
        UIImage *scaledImage = [image resizedImageToFitInSize:CGSizeMake(1080, 1920) scaleIfSmaller:NO];

        NSData *imageData = UIImageJPEGRepresentation(scaledImage, 0.6);
        NSLog(@"image size %lu", (unsigned long)[imageData length]);
        AVFile *imageFile = [AVFile fileWithName:@"image.png" data:imageData];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                AVObject *object = [AVObject objectWithClassName:@"Attachments"];
                [object setObject:@"image" forKey:@"type"];
                [object setObject:imageFile forKey:@"image"];
                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        [self sendAttachment:object];
                    }
                }];
            }
        }];
    }
    [self dismissImagePickerController];
}

#pragma mark copy from viewcontrollchat

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
    savePath = [NSString stringWithFormat:@"%@/%@/recent/%@%@.aac", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [AVUser currentUser].username, self.toChatUsr.UID, self.dateToRecordStr];
    NSError *err;
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm createDirectoryAtPath:[savePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&err]){
        NSLog(@"recordSavePath dir create err: %@",err);
    }
    return savePath;
}
- (NSString *)msgDataReadPath:(ChatMessage *)msg{
    return [NSString stringWithFormat:@"%@/%@/recent/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [AVUser currentUser].username,msg.msg];
}
-(BOOL)sendMsg{
    //if p2p is OK, go to p2p, else go to http
    
//    [[RuntimeStatus instance].udpP2P sendDict:[self.toChatUsr packetLastChatMsg] toUser:self.toChatUsr withProtocol:RECENT_MSG_POST];
    return YES;
}
/* 保存自己产生的消息。这里的消息更新是会对runtime有刷新效果的。 */
-(BOOL)updateMsg{
    ChatMessage *newMsg = [[ChatMessage alloc] init];
//    newMsg.ownerUID = [RuntimeStatus instance].usrSelf.UID;
    newMsg.type = MSG_TYPE_SOUND;
    newMsg.timeStamp = self.dateToRecordStr;
    newMsg.msg = [NSString stringWithFormat:@"%@%@.aac", self.toChatUsr.UID, newMsg.timeStamp];
    [self.toChatUsr.msgs addObject:newMsg];
    return YES;
}

@end
