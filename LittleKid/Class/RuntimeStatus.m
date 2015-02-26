//
//  RuntimeStatus.m
//  LittleKid
//
//  Created by 李允恺 on 12/19/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import "RuntimeStatus.h"

@implementation UserInfo
- (instancetype)init
{
    self = [super init];
    if (self) {
        //TODO
        self.score = @0;
    }
    return self;
}
@end

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
        self.userInfo = [[UserInfo alloc] init];
        self.friends = [NSMutableArray array];
        //TODO
        self.friendsToBeConfirm = [NSMutableArray array];
    }
    return self;
}

//{
//    //    [self initialDb];
//    AVQuery * query = [AVUser query];
//    query.cachePolicy = kAVCachePolicyIgnoreCache;
//    NSError *error;
//    NSArray *objects =[query findObjects];//(NSArray *objects, NSError *error) {
//    if (objects) {
//        for (AVUser *user in objects) {
//            AVObject * userInfo = [user objectForKey:@"userInfo"];
//            [userInfo fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
//                if (error) {
//                    NSLog(@"修改失败");
//                }
//                else {
//                    NSData *headImage = [object objectForKey:@"headImage"];
//                    if (headImage == nil) {
//                        self.userInfo.headImage = [self circleImage:[UIImage imageNamed:@"touxiang"] withParam:0];
//                    }
//                    else
//                        self.userInfo.headImage = [self circleImage:[UIImage imageWithData:headImage] withParam:0];
//                    if (self.userInfo.headImage.size.height>75) {
//                        self.userInfo.headImage = [self scaleToSize:self.userInfo.headImage size:CGSizeMake(70, 70)];
//                    }
//                    [userInfo setObject:UIImageJPEGRepresentation(self.userInfo.headImage, 1.0) forKey:@"headImage"];
//                    
//                    [userInfo saveInBackground];
//                    NSLog(@"修改成功一个");
//                }
//            }];
//        }
//        
//    } else {
//        NSLog(@"error:%@", error);
//    }
//    
//    
//    
//}
- (void) initial {
    self.friends = [NSMutableArray array];
    [self initialDb];
    self.currentUser = [AVUser currentUser];
    AVObject* userInfo = [self.currentUser objectForKey:@"userInfo"];
    [userInfo fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        if (error) {
            NSLog(@"fetch user info error: %@", error);
        }
        else {
            NSData *headImage = [object objectForKey:@"headImage"];
            self.userInfo.headImage = [self circleImage:[UIImage imageWithData:headImage] withParam:0];
            self.userInfo.nickname = [userInfo objectForKey:@"nickname"];
            self.userInfo.birthday = [userInfo objectForKey:@"birthday"];
            self.userInfo.gender = [userInfo objectForKey:@"gender"];
            self.userInfo.level = [userInfo objectForKey:@"level"];
            self.userInfo.score = [userInfo objectForKey:@"score"];
        }
    }];
    
    [self.currentUser getFollowees:^(NSArray *objects, NSError *error) {
        [self updateLoaclFriendList:objects];
    }];
    
    
}


- (void) updateLoaclFriendList: (NSArray *)friends {
    //TODO: 暂时未考虑好友删除的情况
    
    //update local friend info
    for (UserInfo *userInfo in self.friends) {
        [friends enumerateObjectsUsingBlock:^(AVUser *obj, NSUInteger idx, BOOL *stop) {
            if ([userInfo.objID isEqualToString:obj.objectId]) {
                *stop = YES;
                
                AVObject *u = [obj objectForKey:@"userInfo"];
                [u fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
                    NSDate *updatedAt = object.updatedAt;
                    if ([updatedAt laterDate:userInfo.updatedAt]) {
                        userInfo.updatedAt = updatedAt;
                        
                        NSData *headImage = [object objectForKey:@"headImage"];
                        userInfo.headImage = [UIImage imageWithData:headImage];
                        userInfo.nickname = [object objectForKey:@"nickname"];
                        userInfo.birthday = [object objectForKey:@"birthday"];
                        userInfo.gender = [object objectForKey:@"gender"];
                        userInfo.level = [object objectForKey:@"level"];
                        userInfo.score = [object objectForKey:@"score"];
                        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFI_GET_FRIEND_LIST object:nil userInfo:nil];
                        [self updateLocalFriend:userInfo byObjId:u.objectId];
                    }
                }];
            }
        }];
    }
    
    //add new friend info
    for (AVUser* friend in friends) {
        __block BOOL found = NO;
        [self.friends enumerateObjectsUsingBlock:^(UserInfo *obj, NSUInteger idx, BOOL *stop) {
            if ([obj.objID isEqualToString:friend.objectId]) {
                *stop = YES;
                found = YES;
            }
        }];
        if (!found) {
            UserInfo *user = [[UserInfo alloc] init];
            user.objID = friend.objectId;
            user.userName = friend.username;
            
//            [friend fetch];
            
            AVObject *userInfo = [friend objectForKey:@"userInfo"];
            [userInfo fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
                if (error) {
                    NSLog(@"fetch userInfo error");
                }
                else
                {
                    user.nickname = [object objectForKey:@"nickname"];
                    user.birthday = [object objectForKey:@"birthday"];
                    
                    user.nickname = [object objectForKey:@"nickname"];
                    user.birthday = [object objectForKey:@"birthday"];
                    user.gender = [object objectForKey:@"gender"];
                    user.level = [object objectForKey:@"level"];
                    user.score = [object objectForKey:@"score"];
                    
                    NSData *headImage = [object objectForKey:@"headImage"];
                    user.headImage = [UIImage imageWithData:headImage];
                    
                    user.updatedAt = object.updatedAt;
                    
                    [self updateLocalFriend:user byObjId:friend.objectId];
                    NSLog(@"fetch userInfo succes");
                    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFI_GET_FRIEND_LIST object:nil userInfo:nil];
                }

            }];
            
            [self.friends addObject:user];
            [self addLocalFriend:friend];
        }
    }
}

- (void) updateLocalFriend: (UserInfo *)userInfo byObjId: (NSString*)friendObjID {
    [self.db executeUpdateWithFormat:@"UPDATE friends SET nickname = %@, birthday = %@, updatedAt = %@, gender = %@, level = %@, score = %@, headImage = %@ WHERE friendId = %@",
     userInfo.nickname,
     userInfo.birthday,
     userInfo.updatedAt,
     userInfo.gender,
     userInfo.level,
     userInfo.score,
     userInfo.headImage,
     friendObjID];
}

- (void) addLocalFriend: (AVUser*) user {
    [self.db executeUpdateWithFormat:@"INSERT INTO friends (friendId, friendName) VALUES(%@, %@)", user.objectId, user.username];
}



- (void) initialDb {
    NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [NSString stringWithFormat:@"%@.sqlite", [AVUser currentUser].username];
    NSString *dbFileName =[dbPath stringByAppendingPathComponent:fileName];
    
    self.db = [FMDatabase databaseWithPath:dbFileName];
    
    if (![self.db open]) {
        NSLog(@"local database open error!");
        return;
    }
    
    //create the friend table if not exists
    BOOL result = [self.db executeUpdateWithFormat:@"CREATE TABLE IF NOT EXISTS friends (friendId text NOT NULL PRIMARY KEY, friendName text NOT NULL, nickname text, birthday text, gender text, level integer default 0, score integer default 0, headImage blob, updatedAt text);"];
    
    if (!result) {
        NSLog(@"Create table friends error!");
        return;
    }
    
    //get all the friend user info
    FMResultSet *resultSet = [self.db executeQuery:@"select friendId, friendName, nickname, birthday, gender, level, score, headImage, updatedAt from friends"];

    
    while ([resultSet next]) {
        UserInfo *userInfo = [[UserInfo alloc] init];
        userInfo.objID = [resultSet stringForColumn:@"friendId"];
        userInfo.userName = [resultSet stringForColumn:@"friendName"];
        userInfo.nickname = [resultSet stringForColumn:@"nickname"];
        userInfo.birthday = [resultSet dateForColumn:@"birthday"];
        userInfo.gender = [resultSet stringForColumn:@"gender"];
        userInfo.level = [NSNumber numberWithInt:[resultSet intForColumn:@"level"]];
        userInfo.score = [NSNumber numberWithInt:[resultSet intForColumn:@"score"]];
        userInfo.headImage = [UIImage imageWithData:[resultSet dataForColumn:@"headImage"]];
        userInfo.updatedAt = [resultSet dateForColumn:@"updatedAt"];
        
        [self.friends addObject:userInfo];
    }
}
-(UIImage*) circleImage:(UIImage*) image withParam:(CGFloat) inset {
    
    UIGraphicsBeginImageContext(image.size);
    
    CGContextRef context =UIGraphicsGetCurrentContext();
    
    //圆的边框宽度为2，颜色为红色
    
    CGContextSetLineWidth(context,0);
    
    CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
    
    CGRect rect = CGRectMake(inset, inset, image.size.width - inset *2.0f, image.size.height - inset *2.0f);
    
    CGContextAddEllipseInRect(context, rect);
    
    CGContextClip(context);
    
    //在圆区域内画出image原图
    
    [image drawInRect:rect];
    
    CGContextAddEllipseInRect(context, rect);
    
    CGContextStrokePath(context);
    
    //生成新的image
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newimg;
    
}
-(NSString *)getLevelString:(NSNumber *)number//0-12
{
    NSInteger i = number.integerValue;
    NSString *levelstr = [[NSString alloc]initWithFormat:@"九级棋士"];
    if (i<10000) {
        levelstr = @"九级棋士";
    }
    else if (i<12000)
    {
        levelstr = @"八级棋士";
    }
    else if (i<15000)
    {
        levelstr = @"七级棋士";
    }
    else if (i<19000)
    {
        levelstr = @"六级棋士";
    }
    else if (i<24000)
    {
        levelstr = @"五级棋士";
    }
    else if (i<30000)
    {
        levelstr = @"四级棋士";
    }
    else if (i<37000)
    {
        levelstr = @"三级棋士";
    }
    else if (i<45000)
    {
        levelstr = @"二级棋士";
    }
    else if (i<54000)
    {
        levelstr = @"一级棋士";
    }
    else if (i<64000)
    {
        levelstr = @"三级大师";
    }
    else if (i<75000)
    {
        levelstr = @"二级大师";
    }
    else if (i<87000)
    {
        levelstr = @"一级大师";
    }
    else if (i<100000)
    {
        levelstr = @"特级大师";
    }
    else if (i>=100000)
    {
        levelstr = @"国手";
    }
    return levelstr;
}
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}
- (void) saveUserInfo {
    AVObject* userInfo = [self.currentUser objectForKey:@"userInfo"];
    if (self.userInfo.headImage.size.height>75) {
        self.userInfo.headImage = [self scaleToSize:self.userInfo.headImage size:CGSizeMake(70, 70)];
    }
    [userInfo setObject:UIImageJPEGRepresentation(self.userInfo.headImage, 1.0) forKey:@"headImage"];
    [userInfo setObject:self.userInfo.nickname forKey:@"nickname"];
    [userInfo setObject:self.userInfo.birthday forKey:@"birthday"];
    [userInfo setObject:(self.userInfo.gender) forKey:@"gender"];
    [userInfo setObject:(self.userInfo.score) forKey:@"score"];
    //TODO
    
//    [self.currentUser saveInBackground];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFI_INFO_UPDATE object:nil userInfo:nil];
    [userInfo saveInBackground];
}

- (void) setNickName:(NSString *)nickname {
    self.userInfo.nickname = nickname;
    [self saveUserInfo];
}

- (void) setBirthday:(NSDate *)birthday {
    self.userInfo.birthday = birthday;
    [self saveUserInfo];
}

- (void) setHeadImage:(UIImage *)image {
    self.userInfo.headImage = image;
    [self saveUserInfo];
}

- (UserInfo*)getFriendUserInfo:(NSString *)userName {
    __block UserInfo *userInfo;
    [self.friends enumerateObjectsUsingBlock:^(UserInfo *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.userName isEqualToString:userName]) {
            *stop = YES;
            userInfo = [self.friends objectAtIndex:idx];
            return;
        }
    }];
    
    return userInfo;
}
//查找服务器上是否有改用户
- (AVUser *) searchForUsername:(NSString *)oneFriend {
    AVQuery * query = [AVUser query];
    [query whereKey:@"username" equalTo:oneFriend];
    NSArray *objects =[query findObjects];//(NSArray *objects, NSError *error) {
    if (objects) {
        AVUser *peerUser = [objects firstObject];
        return peerUser;
    }
   return nil;
}

//用username从服务器上获取userinfo
- (UserInfo *) getUserInfoForUsername:(NSString *)oneFriend
{
    AVQuery * query = [AVUser query];
    [query whereKey:@"username" equalTo:oneFriend];
    NSArray *objects =[query findObjects];//(NSArray *objects, NSError *error) {
    if (objects) {
        AVUser  *peerUser = [objects firstObject];
        
        if (peerUser == nil) {
            //TODO
            return nil;
        }
        UserInfo *user = [[UserInfo alloc] init];
        user.objID = peerUser.objectId;
        user.userName = peerUser.username;
        AVObject *userInfo = [peerUser objectForKey:@"userInfo"];
        [userInfo fetch];
        user.nickname = [userInfo objectForKey:@"nickname"];
        user.birthday = [userInfo objectForKey:@"birthday"];
        
        user.nickname = [userInfo objectForKey:@"nickname"];
        user.birthday = [userInfo objectForKey:@"birthday"];
        user.gender = [userInfo objectForKey:@"gender"];
        user.level = [userInfo objectForKey:@"level"];
        user.score = [userInfo objectForKey:@"score"];
        
        NSData *headImage = [userInfo objectForKey:@"headImage"];
        user.headImage = [UIImage imageWithData:headImage];
        
        user.updatedAt = userInfo.updatedAt;
        return user;
    
    }
    return  nil;
    
}

- (void) addFriendsToBeConfirm:(NSString *)oneFriend {
    //不允许重复
    for (UserInfo *userinfo in self.friendsToBeConfirm)
    {
        if ([userinfo.userName isEqualToString:oneFriend]) {
            return;
        }
    }
    for(UserInfo *userinfo in self.friends)
    {
        if ([userinfo.userName isEqualToString:oneFriend]) {
            return;
        }
    }
    AVQuery * query = [AVUser query];
    [query whereKey:@"username" equalTo:oneFriend];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil) {
            AVUser  *peerUser = [objects firstObject];
            
            if (peerUser == nil) {
                //TODO
                return;
            }
            UserInfo *user = [[UserInfo alloc] init];
            user.objID = peerUser.objectId;
            user.userName = peerUser.username;
            AVObject *userInfo = [peerUser objectForKey:@"userInfo"];
            [userInfo fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
                if (error) {
                    NSLog(@"fetch tobeConfirmuserInfo error");
                }
                else
                {
                    user.nickname = [object objectForKey:@"nickname"];
                    user.birthday = [object objectForKey:@"birthday"];
                    
                    user.nickname = [object objectForKey:@"nickname"];
                    user.birthday = [object objectForKey:@"birthday"];
                    user.gender = [object objectForKey:@"gender"];
                    user.level = [object objectForKey:@"level"];
                    user.score = [object objectForKey:@"score"];
                    
                    NSData *headImage = [object objectForKey:@"headImage"];
                    user.headImage = [UIImage imageWithData:headImage];
                    
                    user.updatedAt = object.updatedAt;
                    NSLog(@"fetch tobeConfirmuserInfo succes");
                    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFI_GET_FRIEND_LIST object:nil userInfo:nil];
                }
                
            }];
            
            [self.friendsToBeConfirm addObject:user];
            ;
        } else {
            
        }
    }];
    
}
- (void)removeFriendsToBeConfirm:(NSString *)oneFriend
{
    [self.friendsToBeConfirm enumerateObjectsUsingBlock:^(UserInfo *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.userName isEqualToString:oneFriend]) {
            *stop = YES;
            [self.friendsToBeConfirm removeObject:obj];
            return;
        }
    }];
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
