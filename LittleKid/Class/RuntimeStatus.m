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
        self.usrSelf = [[UserSelf alloc] init];
        self.recentUsrList = [[NSMutableArray alloc] init];
        self.signAccountUID = [[NSString alloc] init];
        self.httpClient = [[HTTTClient alloc] init];
        self.udpP2P = [[UDPP2P alloc] init];
    }
    return self;
}

- (void) initial {
    self.currentUser = [AVUser currentUser];
    
    [self.currentUser getFollowees:^(NSArray *objects, NSError *error) {
        NSMutableArray *friends = [NSMutableArray array];
        for (AVUser *user in objects) {
            if (![user isEqual:self.currentUser]) {
                [friends addObject:user];
            }
        }
        
        self.friends = friends;
    }];
    
    //TODO
    self.friendsToBeConfirm = [NSMutableArray array];
}

- (void)loadLocalInfo{
    self.usrSelf = [[UserSelf alloc] initWithUID:self.signAccountUID];
    [self loadLocalRecent];
    
}

- (void)testCode{
    //self.usrSelf.UID = @"0000";
    self.usrSelf.nickName = @"自己";
    self.usrSelf.headPicture = @"head.jpg";
    self.usrSelf.signature = @"小钱长老了老钱";
    self.usrSelf.address = @"启明704";
    self.usrSelf.birthday = @"20";
    self.usrSelf.gender = @"男";
    self.usrSelf.state = @"1";
    if(self.usrSelf.friends == nil){
        self.usrSelf.friends = [[NSMutableArray alloc] init];
    }
    UserOther *friend = [[UserOther alloc] init];
    friend.UID = @"15926305768";
    friend.nickName = @"第二个朋友";
    friend.headPicture = @"head.jpg";
    friend.signature = @"相信男神";
    friend.address = @"启明704";
    friend.birthday = @"22";
    friend.gender = @"男";
    friend.state = @"1";
    friend.usrIP = @"192.168.3.1";
    friend.usrPort = @"20107";
    ChatMessage *msg = [[ChatMessage alloc] init];
    msg.ownerUID = @"15926305768";
    msg.type = @"whatever";
    msg.msg = @"do it or not?";
    msg.timeStamp = @"时间先用string类型";
    friend.msgs = [[NSMutableArray alloc] init];
    [friend.msgs addObject:msg];
    [self.usrSelf.friends addObject:friend];
    friend.nickName = @"吴相鑫";
    [self.usrSelf.friends addObject:friend];
    [self.recentUsrList addObject:friend];
    friend.UID = @"13164696487";
    friend.nickName = @"自己";
    friend.usrIP = @"127.0.0.1";
    friend.usrPort = @"20107";
    [self.recentUsrList addObject:friend];
    //save
    [self.usrSelf save];
    for (UserOther *recent1Usr in self.recentUsrList) {
        [recent1Usr save];
    }
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
        [self testCode];
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

- (void)procNewP2PChatMsg:(NSDictionary *)newChatMsgDict{
    ChatMessage *newMsg = [NSKeyedUnarchiver unarchiveObjectWithData:[newChatMsgDict objectForKey:CHATMSG_KEY_CHATMSG]];
    for (UserOther *recent1Usr in self.recentUsrList) {
        if ([recent1Usr.UID compare:newMsg.ownerUID]) {
            [recent1Usr procNewChatMsgWithDict:newChatMsgDict];
            return;
        }
    }
    //陌生消息处理
    //new msg for new recentUsr
    UserOther *newRecentUser = [[UserOther alloc] init];
    //首先对该用户的UID赋值
    newRecentUser.UID = [NSString stringWithFormat:@"%@",newMsg.ownerUID];
    [newRecentUser procNewChatMsgWithDict:newChatMsgDict];
    //将新用户加入列表
    [self.recentUsrList addObject:newRecentUser];
}


- (void)loadServerRecentMsg:(NSArray *)serverRecentMsgList{
    if(serverRecentMsgList == nil){
        return;
    }
    if ([serverRecentMsgList count]==0) {
        return;
    }
    for (NSDictionary *recent1MsgDict in serverRecentMsgList) {
        //do something
        NSString *msgOwnerUID = [NSString stringWithFormat:@"%@",[recent1MsgDict objectForKey:CHATMSG_KEY_OWNER_UID]];
        BOOL msgPorcedFlag = NO;
        for (UserOther *recent1Usr in self.recentUsrList) {
            if ([recent1Usr.UID compare:msgOwnerUID]) {
                //the user do proc the msg
                [recent1Usr procServerNewChatMsgWithDict:recent1MsgDict];
                //proc end
                msgPorcedFlag = YES;
                break;
            }
        }
        if (msgPorcedFlag == YES) {
            continue;
        }
        //陌生消息处理
        //new msg for new recentUsr
        UserOther *newRecentUser = [[UserOther alloc] init];
        //首先对新用户UID赋值操作
        newRecentUser.UID = [NSString stringWithFormat:@"%@",[recent1MsgDict objectForKey:CHATMSG_KEY_OWNER_UID]];
        [newRecentUser procServerNewChatMsgWithDict:recent1MsgDict];
        //将新用户加入列表
        [self.recentUsrList addObject:newRecentUser];
    }
}




@end
