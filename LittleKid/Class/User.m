//
//  User.m
//  LittleKid
//
//  Created by 李允恺 on 12/25/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import "User.h"
#import "RuntimeStatus.h"

#pragma mark - User Class
@implementation User

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.UID forKey:USR_UID];
    [aCoder encodeObject:self.nickName forKey:USR_NICKNAME];
    [aCoder encodeObject:self.headPicture forKey:USR_HEAD_PICTURE];
    [aCoder encodeObject:self.signature forKey:USR_SIGNATURE];
    [aCoder encodeObject:self.address forKey:USR_ADDRESS];
    [aCoder encodeObject:self.birthday forKey:USR_BIRTHDAY];
    [aCoder encodeObject:self.gender forKey:USR_GENDER];
    [aCoder encodeObject:self.state forKey:USR_STATE];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.UID = [aDecoder decodeObjectForKey:USR_UID];
        self.nickName = [aDecoder decodeObjectForKey:USR_NICKNAME];
        self.headPicture = [aDecoder decodeObjectForKey:USR_HEAD_PICTURE];
        self.signature = [aDecoder decodeObjectForKey:USR_SIGNATURE];
        self.address = [aDecoder decodeObjectForKey:USR_ADDRESS];
        self.birthday = [aDecoder decodeObjectForKey:USR_BIRTHDAY];
        self.gender = [aDecoder decodeObjectForKey:USR_GENDER];
        self.state = [aDecoder decodeObjectForKey:USR_STATE];
    }
    return self;
}

- (id)init{
    self = [super init];
    if (self) {
        self.UID = [[NSString alloc] init];
        self.nickName = [[NSString alloc] init];
        self.headPicture = [[NSString alloc] init];
        self.signature = [[NSString alloc] init];
        self.address = [[NSString alloc] init];
        self.birthday = [[NSString alloc] init];
        self.gender = [[NSString alloc] init];
        self.state = [[NSString alloc] init];
    }
    return self;
}


@end


#pragma mark - UserSelf Class
@implementation UserSelf

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.pwd forKey:USR_PWD];
    NSArray *fixedFriendsArr = [NSArray arrayWithArray:self.friends];
    [aCoder encodeObject:fixedFriendsArr forKey:USR_FRIENDS];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        self.pwd = [[NSString alloc] initWithString:[aDecoder decodeObjectForKey:USR_PWD]];
        self.friends = [[NSMutableArray alloc] initWithArray:[aDecoder decodeObjectForKey:USR_FRIENDS]];
    }
    return self;
}

- (id)init{
    self = [super init];
    if (self) {
        self.pwd = [[NSString alloc] init];
        self.friends = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithUID:(NSString *)UID{
    NSError *err;
    NSData *usrData = [NSData dataWithContentsOfFile:[self usrDataPathWithUID:UID] options:NSDataReadingUncached error:&err];//keep options in mind
    if (err) {
        NSLog(@"no selfUser data, read data error: %@",err);
        self = [[UserSelf alloc] init];
        self.UID = UID;
        return self;
    }
    self = [NSKeyedUnarchiver unarchiveObjectWithData:usrData];
    if (self) {
    }
    else{
        NSLog(@"self no data");
        self = [[UserSelf alloc] init];
        self.UID = UID;
    }
    return  self;
}

- (NSString *)usrDataPathWithUID:(NSString *)UID{
    NSString *str = [NSString stringWithFormat:@"%@/%@/%@.xcui", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], UID, UID];
    NSLog(@"user directory path: %@",str);
    return str;
}

- (BOOL)save{
    NSData *usrData = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSError *err;
    NSString *savePath = [self usrDataPathWithUID:self.UID];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (NO == [fm fileExistsAtPath:savePath]) {
        [fm createDirectoryAtPath:[savePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&err];
    }
    if (err) {
        NSLog(@"%@, %@, create dir error",usrData, err);
    }
    err = nil;
    [usrData writeToFile:savePath options:NSDataWritingFileProtectionNone error:&err];
    if (err) {
        NSLog(@"%@, %@, write usrData error",usrData, err);
    }
    
    return YES;
}
/* 服务器数据一律用stringwithformat赋值，不要直接等于，因为服务器数据不可控 */
- (void)loadServerSelfInfo:(NSDictionary *)serverSelfInfoDict{
    self.nickName = [NSString stringWithFormat:@"%@",[serverSelfInfoDict objectForKey:USR_NICKNAME]];
    self.birthday = [NSString stringWithFormat:@"%@",[serverSelfInfoDict objectForKey:USR_BIRTHDAY]];
    self.signature = [NSString stringWithFormat:@"%@",[serverSelfInfoDict objectForKey:USR_SIGNATURE]];
//    self.state
    self.gender = [NSString stringWithFormat:@"%@",[serverSelfInfoDict objectForKey:USR_GENDER]];
//    self.headPicture =
    self.address = [NSString stringWithFormat:@"%@",[serverSelfInfoDict objectForKey:USR_ADDRESS]];
}

- (void)loadServerFriendList:(NSArray *)serverFriendList{
    //update friendslist
    if ( serverFriendList == nil ) {
        return;
    }
    if ([serverFriendList count] == 0) {
        return;
    }
    //正常情况下应该是用服务器好友列表替换掉本地列表，不过现在还是都添加到后面的好
    if (self.friends == nil) {
        self.friends = [[NSMutableArray alloc] init];
    }
    //    [self.friends removeAllObjects];//先注释掉这段
    for (NSDictionary *server1FriendDict in serverFriendList) {
        UserOther *friend = [[UserOther alloc] init];
        friend.UID = [NSString stringWithFormat:@"%@",[server1FriendDict objectForKey:USR_UID]];
        friend.nickName = [NSString stringWithFormat:@"%@",[server1FriendDict objectForKey:USR_NICKNAME]];
        friend.signature = [NSString stringWithFormat:@"%@",[server1FriendDict objectForKey:USR_SIGNATURE]];
        friend.address = [NSString stringWithFormat:@"%@",[server1FriendDict objectForKey:USR_ADDRESS]];
        friend.birthday = [NSString stringWithFormat:@"%@",[server1FriendDict objectForKey:USR_BIRTHDAY]];
        friend.gender = [NSString stringWithFormat:@"%@",[server1FriendDict objectForKey:USR_GENDER]];
        friend.state = [NSString stringWithFormat:@"%@",[server1FriendDict objectForKey:USR_STATE]];
//        friend.headPicture
        friend.usrIP = [NSString stringWithFormat:@"%@",[server1FriendDict objectForKey:USR_IP]];
        friend.usrPort = [NSString stringWithFormat:@"%@",[server1FriendDict objectForKey:USR_PORT]];
        [self.friends addObject:friend];
    }
}

- (void)addFriend:(NSDictionary *)serverAddFriendAck{

}

- (void)addSignUpMsgToUsrselfWithUID:(NSString *)uid pwd:(NSString *)pwd{
    self.UID = uid;
    self.pwd = pwd;
}

/* 打包signUp数据, return nil when err */
- (NSDictionary *)packetSignUpDict{
    NSDictionary *signUpDict = [[NSDictionary alloc] initWithObjectsAndKeys:self.UID, USR_UID, self.pwd, USR_PWD, @"nickname", @"nickname", nil];
    return signUpDict;
}

@end



#pragma mark - UserOther class
@implementation UserOther

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.usrIP forKey:USR_IP];
    [aCoder encodeObject:self.usrPort forKey:USR_PORT];
    if (self.msgs == nil) {
        return;
    }
    else{
        NSArray *fixedmsgArr = [NSArray arrayWithArray:self.msgs];
        [aCoder encodeObject:fixedmsgArr forKey:USR_MSG];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder{//mutable的初始化方法一定要注意
    if (self = [super initWithCoder:aDecoder]) {
        self.usrIP = [aDecoder decodeObjectForKey:USR_IP];
        self.usrPort = [aDecoder decodeObjectForKey:USR_PORT];
        self.msgs = [[NSMutableArray alloc] initWithArray:[aDecoder decodeObjectForKey:USR_MSG]];
    }
    return self;
}

- (id)init{
    self = [super init];
    if (self) {
        self.usrIP = [[NSString alloc] init];
        self.usrPort = [[NSString alloc] init];
        self.msgs = [[NSMutableArray alloc] init];
    }
    return self;
}

/* This method is special for recentMsgList creating */
- (id)initWithPath:(NSString *)path{
    NSError *err;
    NSData *usrData = [NSData dataWithContentsOfFile:path options:NSDataReadingUncached error:&err];//keep options in mind
    if (err) {
        NSLog(@"Other no data, read data error: %@",err);
        self = [[UserOther alloc] init];
        return self;
    }
    self = [NSKeyedUnarchiver unarchiveObjectWithData:usrData];
    if (self) {
        //
    }
    else{
        self = [[UserOther alloc] init];
        NSLog(@"others unarchieve failed");
    }
    return  self;
}

- (NSString *)usrDataPath{
    return [NSString stringWithFormat:@"%@/%@/recent/%@.xcui", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [RuntimeStatus instance].usrSelf.UID, self.UID];
}

/* 该函数只保存chatmsg，而不保存msg对应的音频等数据，这些数据在接收到新消息时由消息自行保存. */
- (BOOL)save{
    NSData *usrData = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSError *err;
    NSString *savePath = [self usrDataPath];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (NO == [fm fileExistsAtPath:savePath]) {
        [fm createDirectoryAtPath:[savePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&err];
    }
    if (err) {
        NSLog(@"%@, %@, create dir error",usrData, err);
    }
    err = nil;
    [usrData writeToFile:savePath options:NSDataWritingFileProtectionNone error:&err];
    if (err) {
        NSLog(@"%@, %@, write usrData error",usrData, err);
    }
    
    return YES;
}


/*
 目前协议规则:
 字典
 
 */
- (NSDictionary *)packetLastChatMsg{
    ChatMessage *lastMsg = [self.msgs lastObject];
    NSData *data;
    if ( [lastMsg.type compare:MSG_TYPE_SOUND] == NSOrderedSame ) {
        //sound data转成string才能转json
        data = [[NSData alloc] initWithContentsOfFile:[self soundPathWithMsg:lastMsg]];
        if (data == nil) {
            NSLog(@"data == nil ");
        }
    }
    NSDictionary *dictToSent = [[NSDictionary alloc] initWithObjectsAndKeys:[NSKeyedArchiver archivedDataWithRootObject:lastMsg], CHATMSG_KEY_CHATMSG, data, CHATMSG_KEY_DATA, nil];
    return dictToSent;
}

- (NSString *)soundPathWithMsg:(ChatMessage *)msg{
    return [NSString stringWithFormat:@"%@/%@/recent/%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [RuntimeStatus instance].usrSelf.UID, msg.msg];
}

/* 收到新消息数组，调用此函数 */
- (void)procNewChatMsgWithDict:(NSDictionary *)newChatMsgDict{
    ChatMessage *newMsg = [NSKeyedUnarchiver unarchiveObjectWithData:[newChatMsgDict objectForKey:CHATMSG_KEY_CHATMSG]];
    //处理消息
    NSData *newMsgData = [newChatMsgDict objectForKey:CHATMSG_KEY_DATA];
    [self.msgs addObject:newMsg];
    //保存消息数据
    if ( NSOrderedSame == [newMsg.type compare:MSG_TYPE_SOUND] ) {
        NSError *err;
        [newMsgData writeToFile:[self soundPathWithMsg:newMsg] options:NSDataWritingAtomic error:&err];
        if (err) {
            NSLog(@"%@",err);
        }
    }
    //保存该最近联系人的最新消息
    [self save];
}

- (void)procServerNewChatMsgWithDict:(NSDictionary *)newSercerChatMsgDict{

    
    
    //保存该最近联系人的最近消息
}

@end




