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
- (NSArray *)getMessagesForPeerId:(NSString *)peerId;
- (NSArray *)getMessagesForGroup:(NSString *)groupId;
- (void)getHistoryMessagesForPeerId:(NSString *)peerId callback:(AVArrayResultBlock)callback;
- (void)getHistoryMessagesForGroup:(NSString *)groupId callback:(AVArrayResultBlock)callback;
- (void)clearData;
/*!
 *  发送加好友命令
 *  @param peerId 用户自己的peer id
 *  @param peerIds 关注的peer id 数组
 */
- (void)sendAddFriendRequest:(NSString *)peerId;
- (void)invitePlayChess:(NSString *)peerId;
- (void) sendPlayChess:(NSDictionary *) chessCmd toPeerId:(NSString *) peerId;
- (void) sendAddFriendRequestAck:(NSString *)ack toPeerId:(NSString *)peerId;
- (void) invitePlayChessAck:(NSString *)ack toPeerId:(NSString *)peerId;
@end
