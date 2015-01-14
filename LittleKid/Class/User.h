//
//  User.h
//  LittleKid
//
//  Created by 李允恺 on 12/25/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatMessage.h"

@class RuntimeStatus;

#define USR_UID @"uid"
#define USR_PWD @"password"
#define USR_NICKNAME @"nickname"
#define USR_HEAD_PICTURE @"headpicture"
#define USR_SIGNATURE @"signature"
#define USR_ADDRESS @"address"
#define USR_BIRTHDAY @"birthday"
#define USR_GENDER @"gender"
#define USR_STATE @"state"
#define USR_FRIENDS @"friends"
#define USR_IP @"IP"
#define USR_PORT @"PORT"
#define USR_MSG @"MSG"


#pragma mark - User Class
@interface User : NSObject <NSCoding>

@property(nonatomic, strong) NSString *UID;
@property(nonatomic, strong) NSString *nickName;
@property(nonatomic, strong) NSString *headPicture;
@property(nonatomic, strong) NSString *signature;
@property(nonatomic, strong) NSString *address;
@property(nonatomic, strong) NSString *birthday;
@property(nonatomic, strong) NSString *gender;
@property(nonatomic) NSString* state;/* 0,不在线，1，在线, 2, ... */

@end

#pragma mark - UserSelf Class
@interface UserSelf : User <NSCoding>

@property(strong, nonatomic)NSString *pwd;
@property(strong, nonatomic)NSMutableArray *friends;

- (id)init;
- (id)initWithUID:(NSString *)UID;
- (BOOL)save;
- (NSString *)usrDataPathWithUID:(NSString *)UID;
- (void)loadServerSelfInfo:(NSDictionary *)serverSelfInfoDict;
- (void)loadServerFriendList:(NSArray *)serverFriendList;
- (void)addSignUpMsgToUsrselfWithUID:(NSString *)uid pwd:(NSString *)pwd;
- (NSDictionary *)packetSignUpDict;
- (void)addFriend:(NSDictionary *)serverAddFriendAck;

@end


#pragma mark - UserOther Class
@interface UserOther : User <NSCoding>

@property(nonatomic, strong)NSString *usrIP;
@property(nonatomic, strong)NSString *usrPort;
@property(nonatomic, strong)NSMutableArray *msgs;

- (id)init;
- (id)initWithPath:(NSString *)path;
- (BOOL)save;
- (NSString *)usrDataPath;
- (void)loadServerData;
- (NSDictionary *)packetLastChatMsg;
- (void)saveNewMsgData:(NSDictionary *)msgData;

@end
