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
#import "UDPP2P.h"

@interface RuntimeStatus : NSObject

@property (strong, nonatomic) UserSelf *usrSelf;
@property (strong, nonatomic) NSMutableArray *recentUsrList;/* UsrOther */
@property (strong, nonatomic) NSString *signAccountUID;
@property (strong, nonatomic) HTTTClient *httpClient;
@property (strong, nonatomic) UDPP2P *udpP2P;

+ (instancetype)instance;
- (void)loadLocalInfo;
- (void)loadServerRecentMsg:(NSArray *)serverRecentMsgList;
- (void)procNewChatMsg:(NSArray *)newChatMsgList;

@end
