//
//  CDSessionManager.h
//  AVOSChatDemo
//
//  Created by Qihe Bian on 7/29/14.
//  Copyright (c) 2014 AVOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDCommon.h"

typedef enum : NSUInteger {
    CDChatRoomTypeSingle = 1,
    CDChatRoomTypeGroup,
} CDChatRoomType;

@interface CDSessionManager : NSObject <AVSessionDelegate, AVSignatureDelegate, AVGroupDelegate>
+ (instancetype)sharedInstance;
//- (void)startSession;
//- (void)addSession:(AVSession *)session;
//- (NSArray *)sessions;
- (NSArray *)chatRooms;
- (void)addChatWithPeerId:(NSString *)peerId;
- (AVGroup *)joinGroup:(NSString *)groupId;
- (void)startNewGroup:(AVGroupResultBlock)callback;
- (void)sendMessage:(NSString *)message toPeerId:(NSString *)peerId;
- (void)sendMessage:(NSString *)message toGroup:(NSString *)groupId;
- (void)sendCmd:(NSDictionary *)cmd toPeerId:(NSString *)peerId;
- (void)sendAttachment:(AVObject *)object toPeerId:(NSString *)peerId;
- (void)sendAttachment:(AVObject *)object toGroup:(NSString *)groupId;
- (void)sendAttachment:(AVObject *)object avfile:(AVFile *)file toGroup:(NSString *)groupId;
- (void)sendAttachment:(AVObject *)object avfile:(AVFile *)file toPeerId:(NSString *)peerId;
- (NSArray *)getMessagesForPeerId:(NSString *)peerId;
- (NSArray *)getMessagesForGroup:(NSString *)groupId;
- (void)getHistoryMessagesForPeerId:(NSString *)peerId callback:(AVArrayResultBlock)callback;
- (void)getHistoryMessagesForGroup:(NSString *)groupId callback:(AVArrayResultBlock)callback;
- (void)clearData;
/*
 *  发送加好友命令
 *  @param peerId 对方的peer id
 */
- (void)sendAddFriendRequest:(NSString *)peerId;
/*
 *  邀请下象棋命令
 *  @param peerId 对方的peer id
 */
- (void)invitePlayChess:(NSString *)peerId;
/*
 *  发送下象棋命令
 *  @param chessCmd 象棋命令
 *  @param peerId 对方的peer id
 */
- (void) sendPlayChess:(NSDictionary *) chessCmd toPeerId:(NSString *) peerId;
/*
 *  发送加好友应答
 *  @param ack @“同意” @“不同意”
 *  @param peerId 对方的peer id
 */
- (void) sendAddFriendRequestAck:(NSString *)ack toPeerId:(NSString *)peerId;
/*
 *  发送邀请下棋应答
 *  @param ack @“同意” @“不同意”
 *  @param peerId 对方的peer id
 */
- (void) invitePlayChessAck:(NSString *)ack toPeerId:(NSString *)peerId;
@end
