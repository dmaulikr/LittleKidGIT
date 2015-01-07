//
//  RuntimeStatus.m
//  LittleKid
//
//  Created by 李允恺 on 12/19/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import "RuntimeStatus.h"

@implementation RuntimeStatus

+ (instancetype)instance
{
    static RuntimeStatus* g_runtimeState;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_runtimeState = [[RuntimeStatus alloc] init];
        
    });
    return g_runtimeState;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.realTalkServerIP = @"demo.anychat.cn";
        self.realTalkServerPort = @"8906";
        self.realTalkUsrName = @"self_iOS";
        self.realTalkUsrPwd = @"";
        self.realTalkRoomNumber = @"1";
        self.realTalkRoomPwd = @"";
        self.realTalkOnlineUsrList = [[NSMutableArray alloc] init];
        self.usrSelf = [[UserSelf alloc] init];
        self.recentUsrList = [[NSMutableArray alloc] init];
        self.signAccountUID = [[NSString alloc] init];
    }
    return self;
}

- (void)loadLocalInfo{
    self.usrSelf = [[UserSelf alloc] initWithUID:self.signAccountUID];
    [self loadLocalRecent];
    //[self testCode];
    
}

- (void)testCode{
    //self.usrSelf.UID = @"0000";
    self.usrSelf.nickName = @"lyon";
    self.usrSelf.headPicture = @"head.jpg";
    //self.usrSelf.signature = @"小钱长老了老钱";
    //self.usrSelf.address = @"启明704";
    self.usrSelf.age = @"20";
    self.usrSelf.gender = @"男";
    self.usrSelf.state = @"1";
    if(self.usrSelf.friends == nil){
        self.usrSelf.friends = [[NSMutableArray alloc] init];
    }
    UserOther *friend = [[UserOther alloc] init];
    friend.UID = @"15926305768";
    friend.nickName = @"吴相鑫";
    friend.headPicture = @"head.jpg";
    friend.signature = @"相信男神";
    friend.address = @"启明704";
    friend.age = @"22";
    friend.gender = @"男";
    friend.state = @"1";
    friend.usrIP = @"127.0.0.1";
    friend.usrPort = @"20107";
    ChatMessage *msg = [[ChatMessage alloc] init];
    msg.owner = @"1";
    msg.type = @"whatever";
    msg.msg = @"do it or not?";
    msg.timeStamp = @"时间先用string类型";
    friend.msgs = [[NSMutableArray alloc] init];
    [friend.msgs addObject:msg];
    [self.usrSelf.friends addObject:friend];
    friend.signature = @"第二个朋友";
    [self.usrSelf.friends addObject:friend];
    [self.recentUsrList addObject:friend];
    friend.UID = @"13164696487";
    friend.nickName = @"自己";
    friend.usrIP = @"127.0.0.1";
    friend.usrPort = @"20107";
    [self.recentUsrList addObject:friend];
}

/* must called after load the usrself */
- (NSString *)recentDir{
    return [NSString stringWithFormat:@"%@/%@/recent", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], self.usrSelf.UID];
}

- (void)loadLocalRecent{
    NSError *err;
    NSString *recentUsrsRootPath = [self recentDir];
    NSArray *recentUsrsPathArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:recentUsrsRootPath error:&err];
    if (err) {
        return;
    }
    if ( [recentUsrsPathArr count] == 0 ) {// decide if it's an empty array
        return;
    }
    UserOther *recent1Usr;
    for (NSString *recentUsrPath in recentUsrsPathArr) {
        if ([recentUsrPath containsString:@".xcui"]) {
            recent1Usr = [[UserOther alloc] initWithPath:[recentUsrsRootPath stringByAppendingPathComponent:recentUsrPath]];
            if (recent1Usr) {
                [self.recentUsrList addObject:recent1Usr];
            }
            recent1Usr = nil;
        }
    }
}

- (void)procNewChatMsg:(NSData *)newChatMsgData{
    NSDictionary *dictRcvdMsg = [NSKeyedUnarchiver unarchiveObjectWithData:newChatMsgData];
    if (dictRcvdMsg == nil) {
        return;
    }
    NSString *chatMsgUID = [dictRcvdMsg objectForKey:CHATMSG_KEY_UID];
    ChatMessage *newChatMsg = [dictRcvdMsg objectForKey:CHATMSG_KEY_CHATMSG];
    NSData *msgData = [dictRcvdMsg objectForKey:CHATMSG_KEY_SOUND_DATA];
    if (chatMsgUID == nil || newChatMsg == nil || msgData == nil) {
        return;
    }
    NSInteger flag = 0;
    for (UserOther *recent1Usr in self.recentUsrList) {
        if ( [recent1Usr.UID compare:chatMsgUID] == NSOrderedSame ) {
            flag = 1;
            [recent1Usr.msgs addObject:newChatMsg];
            [recent1Usr saveNewMsgData:msgData];
            [recent1Usr save];
        }
    }
    if (flag == 1) {
        UserOther *newRecentUser = [[UserOther alloc] init];
        newRecentUser.msgs = [[NSMutableArray alloc] initWithObjects:newChatMsg, nil];
        [newRecentUser saveNewMsgData:msgData];
        [newRecentUser save];
        [[RuntimeStatus instance].recentUsrList addObject:newRecentUser];
    }
    
    
}



@end
