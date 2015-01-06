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

#pragma mark - User Class
@interface User : NSObject <NSCoding>

@property(nonatomic, strong) NSString *UID;
@property(nonatomic, strong) NSString *nickName;
@property(nonatomic, strong) NSString *headPicture;
@property(nonatomic, strong) NSString *signature;
@property(nonatomic, strong) NSString *address;
@property(nonatomic, strong) NSString *age;
@property(nonatomic, strong) NSString *gender;
@property(nonatomic) NSString* state;/* 0,不在线，1，在线 */

@end

#pragma mark - UserSelf Class
@interface UserSelf : User <NSCoding>

@property(strong, nonatomic)NSMutableArray *friends;

- (id)init;
- (id)initWithUID:(NSString *)UID;
- (BOOL)save;
- (NSString *)usrDataPathWithUID:(NSString *)UID;
- (void)loadServerData;

@end


#pragma mark - UserOther Class
@interface UserOther : User <NSCoding>

@property(nonatomic, strong)NSString *usrIP;
@property(nonatomic, strong)NSString *usrPort;
@property(nonatomic, strong)NSMutableArray *msgs;


- (id)initWithPath:(NSString *)path;
- (BOOL)save;
- (NSString *)usrDataPath;
- (void)loadServerData;
- (NSData *)packetLastChatMsg;
- (void)saveNewMsgData:(NSData *)msgData;

@end
