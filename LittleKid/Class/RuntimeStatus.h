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

@property (strong, nonatomic) UserSelf *usrSelf;
@property (strong, nonatomic) NSMutableArray *recentUsrList;/* UsrOther */
@property (strong, nonatomic) GCDAsyncUdpSocket *udpP2P;
@property (strong, nonatomic) NSString *signAccountUID;

+ (instancetype)instance;
- (void)loadLocalInfo;
- (void)loadServerRecentMsg:(NSData *)serverJsonData;
- (void)procNewChatMsg:(NSData *)newChatMsgData;

@end
