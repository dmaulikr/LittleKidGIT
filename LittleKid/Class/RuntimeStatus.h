//
//  RuntimeStatus.h
//  LittleKid
//
//  Created by 李允恺 on 12/19/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "typedef.h"
#import "HTTTClient.h"
#import "GCDAsyncUdpSocket.h"

@interface RuntimeStatus : NSObject

@property (strong, nonatomic) NSString *realTalkServerIP;
@property (strong, nonatomic) NSString *realTalkServerPort;
@property (strong, nonatomic) NSString *realTalkUsrName;
@property (strong, nonatomic) NSString *realTalkUsrPwd;
@property (strong, nonatomic) NSString *realTalkUsrID;
@property (strong, nonatomic) NSString *realTalkRemoteUsrID;
@property (strong, nonatomic) NSString *realTalkRoomNumber;
@property (strong, nonatomic) NSString *realTalkRoomPwd;
@property (strong, nonatomic) NSMutableArray *realTalkOnlineUsrList;
@property (strong, nonatomic) UserSelf *usrSelf;
@property (strong, nonatomic) NSMutableArray *recentUsrList;/* UsrOther */
@property (strong, nonatomic) GCDAsyncUdpSocket *udpP2P;
@property (strong, nonatomic) NSString *signAccountUID;

+ (instancetype)instance;
- (void)loadLocalInfo;
@end
