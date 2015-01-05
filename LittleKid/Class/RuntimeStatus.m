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
    }
    return self;
}

- (void)loadLocalInfo{
    self.usrSelf = [[UserSelf alloc] initWithUID:self.signAccountUID];
    [self loadLocalRecent];
    //[self testCode];
    
}

- (void)testCode{
    self.usrSelf.UID = @"0000";
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
    friend.UID = @"13164696487";
    friend.nickName = @"lyon";
    friend.headPicture = @"head.jpg";
    friend.signature = @"小钱长老了老钱";
    friend.address = @"启明704";
    friend.age = @"20";
    friend.gender = @"男";
    friend.state = @"1";
    friend.usrIP = @"127.0.0.1";
    friend.usrPort = @"8888";
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
}

/* must called after load the usrself */
- (NSString *)recentDir{
    return [NSString stringWithFormat:@"%@/%@/recent", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], self.usrSelf.UID];
}

- (void)loadLocalRecent{
    self.recentUsrList = [[NSMutableArray alloc] init];
    NSArray *recentUsrsArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self recentDir] error:nil];
    for (UserOther *recentUsr in recentUsrsArr) {
        [self.recentUsrList addObject:recentUsr];
    }
}


@end
