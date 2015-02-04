//
//  CDSessionManager.m
//  AVOSChatDemo
//
//  Created by Qihe Bian on 7/29/14.
//  Copyright (c) 2014 AVOS. All rights reserved.
//

#import "CDSessionManager.h"
#import "FMDB.h"
#import "CDCommon.h"

@interface CDSessionManager () {
    FMDatabase *_database;
    AVSession *_session;
    NSMutableArray *_chatRooms;
}

@end

static id instance = nil;
static BOOL initialized = NO;

@implementation CDSessionManager
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    if (!initialized) {
        [instance commonInit];
    }
    return instance;
}

- (NSString *)databasePath {
    static NSString *databasePath = nil;
    if (!databasePath) {
        NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        databasePath = [cacheDirectory stringByAppendingPathComponent:@"chat.db"];
    }
    return databasePath;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (instancetype)init {
    if ((self = [super init])) {
        _chatRooms = [[NSMutableArray alloc] init];
        
        AVSession *session = [[AVSession alloc] init];
        session.sessionDelegate = self;
        session.signatureDelegate = self;
        _session = session;

        NSLog(@"database path:%@", [self databasePath]);
        _database = [FMDatabase databaseWithPath:[self databasePath]];
        [_database open];
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    if (![_database tableExists:@"messages"]) {
        if ([_database executeUpdate:@"create table \"messages\" (\"fromid\" text, \"toid\" text, \"type\" text, \"message\" text, \"object\" text, \"time\" integer, \"avfile\" blob)"]) {
            NSLog(@"creat success");
        }
    }
    if (![_database tableExists:@"addfriend"]) {
        [_database executeUpdate:@"create table \"addfriend\" (\"fromid\" text,\"toid\" text, \"message\" text, \"time\" integer)"];
    }
    if (![_database tableExists:@"sessions"]) {
        [_database executeUpdate:@"create table \"sessions\" (\"type\" integer, \"otherid\" text)"];
    }
    [_session openWithPeerId:[AVUser currentUser].username];

    FMResultSet *rs = [_database executeQuery:@"select \"type\", \"otherid\" from \"sessions\""];
    NSMutableArray *peerIds = [[NSMutableArray alloc] init];
    while ([rs next]) {
        NSInteger type = [rs intForColumn:@"type"];
        NSString *otherid = [rs stringForColumn:@"otherid"];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[NSNumber numberWithInteger:type] forKey:@"type"];
        [dict setObject:otherid forKey:@"otherid"];
        if (type == CDChatRoomTypeSingle) {
            [peerIds addObject:otherid];
        } else if (type == CDChatRoomTypeGroup) {
            [dict setObject:[NSNumber numberWithInteger:type] forKey:@"type"];
            [dict setObject:otherid forKey:@"otherid"];
            
            AVGroup *group = [AVGroup getGroupWithGroupId:otherid session:_session];
            group.delegate = self;
            [group join];
        }
        [_chatRooms addObject:dict];
    }
    
    [_session watchPeerIds:peerIds];
   
    
    initialized = YES;
}

- (void)clearData {
    [_database executeUpdate:@"DROP TABLE IF EXISTS messages"];
    [_database executeUpdate:@"DROP TABLE IF EXISTS sessions"];
    [_database executeUpdate:@"DROP TABLE IF EXISTS addfriend"];
    [_chatRooms removeAllObjects];
    [_session close];
    initialized = NO;
}

- (NSArray *)chatRooms {
    return _chatRooms;
}
- (void)addChatWithPeerId:(NSString *)peerId {
    BOOL exist = NO;
    for (NSDictionary *dict in _chatRooms) {
        CDChatRoomType type = [[dict objectForKey:@"type"] integerValue];
        NSString *otherid = [dict objectForKey:@"otherid"];
        if (type == CDChatRoomTypeSingle && [peerId isEqualToString:otherid]) {
            exist = YES;
            break;
        }
    }
    if (!exist) {
        [_session watchPeerIds:@[peerId]];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[NSNumber numberWithInteger:CDChatRoomTypeSingle] forKey:@"type"];
        [dict setObject:peerId forKey:@"otherid"];
        [_chatRooms addObject:dict];
        [_database executeUpdate:@"insert into \"sessions\" (\"type\", \"otherid\") values (?, ?)" withArgumentsInArray:@[[NSNumber numberWithInteger:CDChatRoomTypeSingle], peerId]];
    }
}

- (AVGroup *)joinGroup:(NSString *)groupId {
    BOOL exist = NO;
    for (NSDictionary *dict in _chatRooms) {
        CDChatRoomType type = [[dict objectForKey:@"type"] integerValue];
        NSString *otherid = [dict objectForKey:@"otherid"];
        if (type == CDChatRoomTypeGroup && [groupId isEqualToString:otherid]) {
            exist = YES;
            break;
        }
    }
    if (!exist) {
        AVGroup *group = [AVGroup getGroupWithGroupId:groupId session:_session];
        group.delegate = self;
        [group join];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[NSNumber numberWithInteger:CDChatRoomTypeGroup] forKey:@"type"];
        [dict setObject:groupId forKey:@"otherid"];
        [_chatRooms addObject:dict];
        [_database executeUpdate:@"insert into \"sessions\" (\"type\", \"otherid\") values (?, ?)" withArgumentsInArray:@[[NSNumber numberWithInteger:CDChatRoomTypeGroup], groupId]];
    }
    return [AVGroup getGroupWithGroupId:groupId session:_session];;
}
- (void)startNewGroup:(AVGroupResultBlock)callback {
    [AVGroup createGroupWithSession:_session groupDelegate:self callback:^(AVGroup *group, NSError *error) {
        if (!error) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[NSNumber numberWithInteger:CDChatRoomTypeGroup] forKey:@"type"];
            [dict setObject:group.groupId forKey:@"otherid"];
            [_chatRooms addObject:dict];
            [_database executeUpdate:@"insert into \"sessions\" (\"type\", \"otherid\") values (?, ?)" withArgumentsInArray:@[[NSNumber numberWithInteger:CDChatRoomTypeGroup], group.groupId]];
            if (callback) {
                callback(group, error);
            }
        } else {
            NSLog(@"error:%@", error);
        }
    }];
}

- (void)sendAddFriendRequest:(NSString *)peerId
{
    [self addChatWithPeerId:peerId];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:ADD_FRIEND_CMD forKey:@"cmd_type"];
    [self sendCmd:dict toPeerId:peerId];
}
- (void)invitePlayChess:(NSString *)peerId
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:INVITE_PLAY_CHESS_CMD  forKey:@"cmd_type"];
    [self sendCmd:dict toPeerId:peerId];
}
- (void) sendPlayChess:(NSDictionary *) chessCmd toPeerId:(NSString *) peerId
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:PLAY_CHESS_CMD  forKey:@"cmd_type"];
    [dict addEntriesFromDictionary:chessCmd];
    [self sendCmd:dict toPeerId:peerId];
    
}
- (void) sendAddFriendRequestAck:(NSString *)ack toPeerId:(NSString *)peerId
{
    [self addChatWithPeerId:peerId];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:ADD_FRIEND_CMD_ACK  forKey:@"cmd_type"];
    [dict setObject:ack forKey:@"ack_value"];
    [self sendCmd:dict toPeerId:peerId];
}
- (void) invitePlayChessAck:(NSString *)ack toPeerId:(NSString *)peerId
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:INVITE_PLAY_CHESS_CMD_ACK  forKey:@"cmd_type"];
    [dict setObject:ack forKey:@"ack_value"];
    [self sendCmd:dict toPeerId:peerId];
}
/*
 *  发送命令@“dn”  @"type" @"cmd"  cmd的object 为dictionary  cmd_dictionary @"cmd_type" @""ack_value"
 *  @param ack @“同意” @“不同意”
 *  @param peerId 对方的peer id
 */
- (void)sendCmd:(NSDictionary *)cmd toPeerId:(NSString *)peerId {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:_session.peerId forKey:@"dn"];
    [dict setObject:@"cmd" forKey:@"type"];
    [dict setObject:cmd forKey:@"cmd"];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString *payload = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    AVMessage *messageObject = [AVMessage messageForPeerWithSession:_session toPeerId:peerId payload:payload];
    [_session sendMessage:messageObject transient:NO];
//    
//    dict = [NSMutableDictionary dictionary];
//    [dict setObject:_session.peerId forKey:@"fromid"];
//    [dict setObject:peerId forKey:@"toid"];
//    [dict setObject:@"cmd" forKey:@"type"];
//    [dict setObject:cmd forKey:@"cmd"];
//    [dict setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"time"];
//    [_database executeUpdate:@"insert into \"cmd\" (\"fromid\", \"toid\", \"type\", \"cmd\", \"time\") values (:fromid, :toid, :type, :cmd, :time)" withParameterDictionary:dict];
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGE_UPDATED object:nil userInfo:dict];
    
}


- (void)sendMessage:(NSString *)message toPeerId:(NSString *)peerId {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:_session.peerId forKey:@"dn"];
    [dict setObject:@"text" forKey:@"type"];
    [dict setObject:message forKey:@"msg"];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString *payload = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    AVMessage *messageObject = [AVMessage messageForPeerWithSession:_session toPeerId:peerId payload:payload];
    [_session sendMessage:messageObject transient:NO];
    
    dict = [NSMutableDictionary dictionary];
    [dict setObject:_session.peerId forKey:@"fromid"];
    [dict setObject:peerId forKey:@"toid"];
    [dict setObject:@"text" forKey:@"type"];
    [dict setObject:message forKey:@"message"];
    [dict setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"time"];
//    [_database executeUpdate:@"insert into \"messages\" (\"fromid\", \"toid\", \"type\", \"message\", \"time\") values (:fromid, :toid, :type, :message, :time)" withParameterDictionary:dict];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGE_UPDATED object:nil userInfo:dict];
    
}

- (void)sendMessage:(NSString *)message toGroup:(NSString *)groupId {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:_session.peerId forKey:@"dn"];
    [dict setObject:@"text" forKey:@"type"];
    [dict setObject:message forKey:@"msg"];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString *payload = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    AVGroup *group = [AVGroup getGroupWithGroupId:groupId session:_session];
    AVMessage *messageObject = [AVMessage messageForGroup:group payload:payload];
    [group sendMessage:messageObject transient:NO];
    
    dict = [NSMutableDictionary dictionary];
    [dict setObject:_session.peerId forKey:@"fromid"];
    [dict setObject:groupId forKey:@"toid"];
    [dict setObject:@"text" forKey:@"type"];
    [dict setObject:message forKey:@"message"];
    [dict setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"time"];
//    [_database executeUpdate:@"insert into \"messages\" (\"fromid\", \"toid\", \"type\", \"message\", \"time\") values (:fromid, :toid, :type, :message, :time)" withParameterDictionary:dict];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGE_UPDATED object:nil userInfo:dict];
    
}

- (void)sendAttachment:(AVObject *)object toPeerId:(NSString *)peerId {
    NSString *type = [object objectForKey:@"type"];
//    AVFile *file = [object objectForKey:type];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:_session.peerId forKey:@"dn"];
    [dict setObject:type forKey:@"type"];
    [dict setObject:object.objectId forKey:@"object"];
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString *payload = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    AVMessage *messageObject = [AVMessage messageForPeerWithSession:_session toPeerId:peerId payload:payload];
    [_session sendMessage:messageObject transient:NO];
    //    [_session sendMessage:payload isTransient:NO toPeerIds:@[peerId]];
    
    dict = [NSMutableDictionary dictionary];
    [dict setObject:_session.peerId forKey:@"fromid"];
    [dict setObject:peerId forKey:@"toid"];
    [dict setObject:type forKey:@"type"];
    [dict setObject:object.objectId forKey:@"object"];
    [dict setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"time"];
//    [_database executeUpdate:@"insert into \"messages\" (\"fromid\", \"toid\", \"type\", \"object\", \"time\") values (:fromid, :toid, :type, :object, :time)" withParameterDictionary:dict];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGE_UPDATED object:nil userInfo:dict];
    
}

- (void)sendAttachment:(AVObject *)object avfile:(AVFile *)file toPeerId:(NSString *)peerId {
    NSString *type = [object objectForKey:@"type"];
    //    AVFile *file = [object objectForKey:type];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:_session.peerId forKey:@"dn"];
    [dict setObject:type forKey:@"type"];
    [dict setObject:object.objectId forKey:@"object"];
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString *payload = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    AVMessage *messageObject = [AVMessage messageForPeerWithSession:_session toPeerId:peerId payload:payload];
    [_session sendMessage:messageObject transient:NO];
    //    [_session sendMessage:payload isTransient:NO toPeerIds:@[peerId]];
    
    dict = [NSMutableDictionary dictionary];
    [dict setObject:_session.peerId forKey:@"fromid"];
    [dict setObject:peerId forKey:@"toid"];
    [dict setObject:type forKey:@"type"];
    [dict setObject:object.objectId forKey:@"object"];
    NSData *filedata = [file getData];
    [dict setObject:filedata forKey:@"filedata"];
    [dict setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"time"];
    if ([_database executeUpdate:@"insert into \"messages\" (\"fromid\", \"toid\", \"type\", \"object\", \"time\", \"avfile\") values (:fromid, :toid, :type, :object, :time, :filedata)" withParameterDictionary:dict]) {
        NSLog(@"database insert sucess");
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGE_UPDATED object:nil userInfo:dict];
    
}
- (void)sendAttachment:(AVObject *)object avfile:(AVFile *)file toGroup:(NSString *)groupId {
    NSString *type = [object objectForKey:@"type"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:_session.peerId forKey:@"dn"];
    [dict setObject:type forKey:@"type"];
    [dict setObject:object.objectId forKey:@"object"];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString *payload = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    AVGroup *group = [AVGroup getGroupWithGroupId:groupId session:_session];
    AVMessage *messageObject = [AVMessage messageForGroup:group payload:payload];
    [group sendMessage:messageObject transient:NO];
    
    dict = [NSMutableDictionary dictionary];
    [dict setObject:_session.peerId forKey:@"fromid"];
    [dict setObject:groupId forKey:@"toid"];
    [dict setObject:type forKey:@"type"];
    [dict setObject:object.objectId forKey:@"object"];
    [dict setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"time"];
//    if ([_database executeUpdate:@"insert into \"messages\" (\"fromid\", \"toid\", \"type\", \"object\", \"time\", \"avfile\") values (:fromid, :toid, :type, :object, :time, :filedata)" withParameterDictionary:dict]) {
//        NSLog(@"database insert sucess");
//    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGE_UPDATED object:nil userInfo:dict];
    
}
- (void)sendAttachment:(AVObject *)object toGroup:(NSString *)groupId {
    NSString *type = [object objectForKey:@"type"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:_session.peerId forKey:@"dn"];
    [dict setObject:type forKey:@"type"];
    [dict setObject:object.objectId forKey:@"object"];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString *payload = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    AVGroup *group = [AVGroup getGroupWithGroupId:groupId session:_session];
    AVMessage *messageObject = [AVMessage messageForGroup:group payload:payload];
    [group sendMessage:messageObject transient:NO];
    
    dict = [NSMutableDictionary dictionary];
    [dict setObject:_session.peerId forKey:@"fromid"];
    [dict setObject:groupId forKey:@"toid"];
    [dict setObject:type forKey:@"type"];
    [dict setObject:object.objectId forKey:@"object"];
    [dict setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"time"];
//    [_database executeUpdate:@"insert into \"messages\" (\"fromid\", \"toid\", \"type\", \"object\", \"time\") values (:fromid, :toid, :type, :object, :time)" withParameterDictionary:dict];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGE_UPDATED object:nil userInfo:dict];

}

- (NSArray *)getMessagesForPeerId:(NSString *)peerId {
    NSString *selfId = _session.peerId;
    FMResultSet *rs = [_database executeQuery:@"select \"fromid\", \"toid\", \"type\", \"message\", \"object\", \"time\", \"avfile\" from \"messages\" where (\"fromid\"=? and \"toid\"=?) or (\"fromid\"=? and \"toid\"=?)" withArgumentsInArray:@[selfId, peerId, peerId, selfId]];
    NSMutableArray *result = [NSMutableArray array];
    while ([rs next]) {
        NSString *fromid = [rs stringForColumn:@"fromid"];
        NSString *toid = [rs stringForColumn:@"toid"];
        double time = [rs doubleForColumn:@"time"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
        NSString *type = [rs stringForColumn:@"type"];
        NSData *data = [rs dataForColumn:@"avfile"];
        AVFile *file = [AVFile fileWithData:data];
        if ([type isEqualToString:@"text"]) {
            NSString *message = [rs stringForColumn:@"message"];
            NSDictionary *dict = @{@"fromid":fromid, @"toid":toid, @"type":type, @"message":message, @"time":date};
            [result addObject:dict];
        } else {
            NSString *object = [rs stringForColumn:@"object"];
            NSDictionary *dict = @{@"fromid":fromid, @"toid":toid, @"type":type, @"object":object, @"time":date,@"avfile":file};
            [result addObject:dict];
        }
    }
    return result;
}
//@"create table \"addfriend\" (\"fromid\" text,\"toid\" text, \"message\" text, \"time\" integer)"];
- (NSArray *)getAddFriendForPeerId:(NSString *)peerId {
//    NSString *selfId = _session.peerId;
    FMResultSet *rs = [_database executeQuery:@"select \"fromid\", \"message\", \"time\" from \"addfriend\" where (\"toid\"=?)" withArgumentsInArray:@[peerId]];
    NSMutableArray *result = [NSMutableArray array];
    while ([rs next]) {
        NSString *fromid = [rs stringForColumn:@"fromid"];
        double time = [rs doubleForColumn:@"time"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
        NSString *message = [rs stringForColumn:@"message"];
        
        NSDictionary *dict = @{@"fromid":fromid, @"message":message, @"time":date};
        [result addObject:dict];
        
      
    }
    return result;
}

- (NSArray *)getMessagesForGroup:(NSString *)groupId {
    FMResultSet *rs = [_database executeQuery:@"select \"fromid\", \"toid\", \"type\", \"message\", \"object\", \"time\" from \"messages\" where \"toid\"=?" withArgumentsInArray:@[groupId]];
    NSMutableArray *result = [NSMutableArray array];
    while ([rs next]) {
        NSString *fromid = [rs stringForColumn:@"fromid"];
        NSString *toid = [rs stringForColumn:@"toid"];
        double time = [rs doubleForColumn:@"time"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
        NSString *type = [rs stringForColumn:@"type"];
        if ([type isEqualToString:@"text"]) {
            NSString *message = [rs stringForColumn:@"message"];
            NSDictionary *dict = @{@"fromid":fromid, @"toid":toid, @"type":type, @"message":message, @"time":date};
            [result addObject:dict];
        } else {
            NSString *object = [rs stringForColumn:@"object"];
            NSDictionary *dict = @{@"fromid":fromid, @"toid":toid, @"type":type, @"object":object, @"time":date};
            [result addObject:dict];
        }
    }
    return result;
}

- (void)getHistoryMessagesForPeerId:(NSString *)peerId callback:(AVArrayResultBlock)callback {
    AVHistoryMessageQuery *query = [AVHistoryMessageQuery queryWithFirstPeerId:_session.peerId secondPeerId:peerId];
    [query findInBackgroundWithCallback:^(NSArray *objects, NSError *error) {
        callback(objects, error);
    }];
}

- (void)getHistoryMessagesForGroup:(NSString *)groupId callback:(AVArrayResultBlock)callback {
    AVHistoryMessageQuery *query = [AVHistoryMessageQuery queryWithGroupId:groupId];
    [query findInBackgroundWithCallback:^(NSArray *objects, NSError *error) {
        callback(objects, error);
    }];
}
#pragma mark - AVSessionDelegate
- (void)sessionOpened:(AVSession *)session {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"session:%@", session.peerId);
}

- (void)sessionPaused:(AVSession *)session {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"session:%@", session.peerId);
}

- (void)sessionResumed:(AVSession *)session {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"session:%@", session.peerId);
}

- (void)session:(AVSession *)session didReceiveMessage:(AVMessage *)message {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"session:%@ message:%@ fromPeerId:%@", session.peerId, message, message.fromPeerId);
    NSError *error;
    NSData *data = [message.payload dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSLog(@"%@", jsonDict);
    NSString *type = [jsonDict objectForKey:@"type"];
    NSString *msg = [jsonDict objectForKey:@"msg"];
    NSString *object = [jsonDict objectForKey:@"object"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:message.fromPeerId forKey:@"fromid"];
    [dict setObject:session.peerId forKey:@"toid"];
    [dict setObject:@(message.timestamp/1000) forKey:@"time"];
    [dict setObject:type forKey:@"type"];
    if ([type isEqualToString:@"text"])
    {
        [dict setObject:msg forKey:@"message"];
//        [_database executeUpdate:@"insert into \"messages\" (\"fromid\", \"toid\", \"type\", \"message\", \"time\") values (:fromid, :toid, :type, :message, :time)" withParameterDictionary:dict];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGE_UPDATED object:session userInfo:dict];
    }
    else if([type isEqualToString:@"cmd"])
    {
        NSDictionary *cmddict = [jsonDict objectForKey:@"cmd"];
        NSString *cmd_type = [cmddict objectForKey:@"cmd_type"];
        //@"create table \"addfriend\" (\"otherid\" text,\"toid\" text, \"message\" text, \"time\" integer)"];
        if([cmd_type isEqualToString:ADD_FRIEND_CMD])
        {
            NSDictionary * cmdDict = [jsonDict objectForKey:@"cmd"];
            [dict setObject:cmdDict forKey:@"cmd"];
             [_database executeUpdate:@"insert into \"addfriend\" (\"fromid\",\"toid\", \"message\", \"time\") values (:fromid, :toid :message, :time)" withParameterDictionary:dict];
            [[NSNotificationCenter defaultCenter] postNotificationName:          NOTIFICATION_ADD_FRIEND_UPDATED object:session userInfo:dict];
            return;
        }
        else if ([cmd_type isEqualToString:INVITE_PLAY_CHESS_CMD])
        {
            NSDictionary * cmdDict = [jsonDict objectForKey:@"cmd"];
            [dict setObject:cmdDict forKey:@"cmd"];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_INVITE_PLAY_CHESS_UPDATED object:session userInfo:dict];
            return;
        }
        else if ([cmd_type isEqualToString:PLAY_CHESS_CMD])
        {
            NSDictionary * cmdDict = [jsonDict objectForKey:@"cmd"];
            [dict setObject:cmdDict forKey:@"cmd"];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PLAY_CHESS_UPDATED object:session userInfo:dict];
            return;
        }
        else if ([cmd_type isEqualToString:ADD_FRIEND_CMD_ACK])
        {
            NSDictionary * cmdDict = [jsonDict objectForKey:@"cmd"];
            [dict setObject:cmdDict forKey:@"cmd"];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ADD_FRIEND_ACK_UPDATED object:session userInfo:dict];
            return;
        }
        else if ([cmd_type isEqualToString:INVITE_PLAY_CHESS_CMD_ACK])
        {
            NSDictionary * cmdDict = [jsonDict objectForKey:@"cmd"];
            [dict setObject:cmdDict forKey:@"cmd"];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_INVITE_PLAY_CHESS_ACK_UPDATED object:session userInfo:dict];
            return;
        }
    }
    else if([type isEqualToString:@"image"])
    {
        [dict setObject:object forKey:@"object"];
        NSString *objectId = object;
        AVObject *avobject = [AVObject objectWithoutDataWithClassName:@"Attachments" objectId:objectId];
        [avobject fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
            AVFile *avfile = [object objectForKey:type];
            [avfile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                
                NSData *filedata = [avfile getData];
                [dict setObject:filedata forKey:@"avfile"];
                [_database executeUpdate:@"insert into \"messages\" (\"fromid\", \"toid\", \"type\", \"object\", \"time\", \"avfile\") values (:fromid, :toid, :type, :object, :time, :avfile)" withParameterDictionary:dict];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGE_UPDATED object:session userInfo:dict];
                return ;
            }];
        }];

        
    }
    
    BOOL exist = NO;
    for (NSDictionary *dict in _chatRooms) {
        CDChatRoomType type = [[dict objectForKey:@"type"] integerValue];
        NSString *otherid = [dict objectForKey:@"otherid"];
        if (type == CDChatRoomTypeSingle && [message.fromPeerId isEqualToString:otherid]) {
            exist = YES;
            break;
        }
    }
    if (!exist) {
        [self addChatWithPeerId:message.fromPeerId];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SESSION_UPDATED object:session userInfo:nil];
    }
    
    //    NSError *error;
    //    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    //    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    //
    //    if (error == nil) {
    //        KAMessage *chatMessage = nil;
    //        if ([jsonDict objectForKey:@"st"]) {
    //            NSString *displayName = [jsonDict objectForKey:@"dn"];
    //            NSString *status = [jsonDict objectForKey:@"st"];
    //            if ([status isEqualToString:@"on"]) {
    //                chatMessage = [[KAMessage alloc] initWithDisplayName:displayName Message:@"上线了" fromMe:YES];
    //            } else {
    //                chatMessage = [[KAMessage alloc] initWithDisplayName:displayName Message:@"下线了" fromMe:YES];
    //            }
    //            chatMessage.isStatus = YES;
    //        } else {
    //            NSString *displayName = [jsonDict objectForKey:@"dn"];
    //            NSString *message = [jsonDict objectForKey:@"msg"];
    //            if ([displayName isEqualToString:MY_NAME]) {
    //                chatMessage = [[KAMessage alloc] initWithDisplayName:displayName Message:message fromMe:YES];
    //            } else {
    //                chatMessage = [[KAMessage alloc] initWithDisplayName:displayName Message:message fromMe:NO];
    //            }
    //        }
    //
    //        if (chatMessage) {
    //            [_messages addObject:chatMessage];
    //            //            [self.tableView beginUpdates];
    //            [self.tableView reloadData];
    //            //            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_messages.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    //            [self.tableView scrollRectToVisible:self.tableView.tableFooterView.frame animated:YES];
    //            //            [self.tableView endUpdates];
    //        }
    //    }
}

- (void)session:(AVSession *)session messageSendFailed:(AVMessage *)message error:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"session:%@ message:%@ toPeerId:%@ error:%@", session.peerId, message, message.toPeerId, error);
}

- (void)session:(AVSession *)session messageSendFinished:(AVMessage *)message {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"session:%@ message:%@ toPeerId:%@", session.peerId, message, message.toPeerId);
}

- (void)session:(AVSession *)session didReceiveStatus:(AVPeerStatus)status peerIds:(NSArray *)peerIds {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"session:%@ peerIds:%@ status:%@", session.peerId, peerIds, status==AVPeerStatusOffline?@"offline":@"online");
}

- (void)sessionFailed:(AVSession *)session error:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"session:%@ error:%@", session.peerId, error);
}

#pragma mark - AVGroupDelegate
- (void)group:(AVGroup *)group didReceiveMessage:(AVMessage *)message {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"group:%@ message:%@ fromPeerId:%@", group.groupId, message, message.fromPeerId);
    NSError *error;
    NSData *data = [message.payload dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSLog(@"%@", jsonDict);
    
    NSString *type = [jsonDict objectForKey:@"type"];
    NSString *msg = [jsonDict objectForKey:@"msg"];
    NSString *object = [jsonDict objectForKey:@"object"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:message.fromPeerId forKey:@"fromid"];
    [dict setObject:group.groupId forKey:@"toid"];
    [dict setObject:@(message.timestamp/1000) forKey:@"time"];
    [dict setObject:type forKey:@"type"];
    if ([type isEqualToString:@"text"]) {
        [dict setObject:msg forKey:@"message"];
//        [_database executeUpdate:@"insert into \"messages\" (\"fromid\", \"toid\", \"type\", \"message\", \"time\") values (:fromid, :toid, :type, :message, :time)" withParameterDictionary:dict];
    } else {
        [dict setObject:object forKey:@"object"];
//        [_database executeUpdate:@"insert into \"messages\" (\"fromid\", \"toid\", \"type\", \"object\", \"time\") values (:fromid, :toid, :type, :object, :time)" withParameterDictionary:dict];
    }

    BOOL exist = NO;
    for (NSDictionary *dict in _chatRooms) {
        CDChatRoomType type = [[dict objectForKey:@"type"] integerValue];
        NSString *otherid = [dict objectForKey:@"otherid"];
        if (type == CDChatRoomTypeGroup && [group.groupId isEqualToString:otherid]) {
            exist = YES;
            break;
        }
    }
    if (!exist) {
        [self joinGroup:group.groupId];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SESSION_UPDATED object:group.session userInfo:nil];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGE_UPDATED object:group.session userInfo:dict];
}

- (void)group:(AVGroup *)group didReceiveEvent:(AVGroupEvent)event peerIds:(NSArray *)peerIds {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"group:%@ event:%lu peerIds:%@", group.groupId, event, peerIds);
    if (event == AVGroupEventSelfJoined) {
        BOOL exist = NO;
        for (NSDictionary *dict in _chatRooms) {
            CDChatRoomType type = [[dict objectForKey:@"type"] integerValue];
            NSString *otherid = [dict objectForKey:@"otherid"];
            if (type == CDChatRoomTypeGroup && [group.groupId isEqualToString:otherid]) {
                exist = YES;
                break;
            }
        }
        if (!exist) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[NSNumber numberWithInteger:CDChatRoomTypeGroup] forKey:@"type"];
            [dict setObject:group.groupId forKey:@"otherid"];
            [_chatRooms addObject:dict];
            [_database executeUpdate:@"insert into \"sessions\" (\"type\", \"otherid\") values (?, ?)" withArgumentsInArray:@[[NSNumber numberWithInteger:CDChatRoomTypeGroup], group.groupId]];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SESSION_UPDATED object:group.session userInfo:nil];
        }
    }
}

- (void)group:(AVGroup *)group messageSendFinished:(AVMessage *)message {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"group:%@ message:%@", group.groupId, message.payload);

}

- (void)group:(AVGroup *)group messageSendFailed:(AVMessage *)message error:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"group:%@ message:%@ error:%@", group.groupId, message.payload, error);

}

- (void)session:(AVSession *)session group:(AVGroup *)group messageSent:(NSString *)message success:(BOOL)success {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"group:%@ message:%@ success:%d", group.groupId, message, success);
}

@end
