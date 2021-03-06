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
#import "CDCommon.h"
#import "FMDatabase.h"

@interface UserInfo : NSObject
@property (strong, nonatomic) NSString *objID;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSDate *birthday;
@property (strong, nonatomic) NSString* gender;
@property (strong, nonatomic) NSNumber *level;
@property (strong, nonatomic) NSNumber *score;
@property (strong, nonatomic) UIImage *headImage;
@property (strong, nonatomic) NSDate *updatedAt;
@end


@interface RuntimeStatus : NSObject

@property (strong, nonatomic) UserSelf *usrSelf;
@property (strong, nonatomic) NSMutableArray *recentUsrList;/* UsrOther */
@property (strong, nonatomic) NSString *signAccountUID;
@property (strong, nonatomic) HTTTClient *httpClient;
@property (strong, nonatomic) UDPP2P *udpP2P;

@property (strong, nonatomic) AVUser *currentUser;
@property (strong, nonatomic) UserInfo *userInfo;

@property (strong, nonatomic) NSMutableArray *friends;
//@property (strong, nonatomic) NSMutableArray *friendUserInfo;
@property (strong, nonatomic) NSMutableArray *friendsToBeConfirm;

@property (strong, nonatomic) NSString *peerId; //for temp use

@property(nonatomic,strong)FMDatabase *db;


+ (instancetype)instance;
- (void)loadLocalInfo;
- (void)loadServerRecentMsg:(NSArray *)serverRecentMsgList;
- (void)procNewP2PChatMsg:(NSDictionary *)newChatMsgDict;

- (void)initial;
- (void) saveUserInfo;
- (void) setNickName: (NSString*) nickname;
- (void) setBirthday: (NSDate*) birthday;
- (void) setHeadImage: (UIImage*) image;

- (void)addFriendsToBeConfirm:(NSString *)oneFriend;
- (void)removeFriendsToBeConfirm:(NSString *)oneFriend;

- (NSString *)getLevelString:(NSNumber *)number;//0-12
- (UserInfo*)getFriendUserInfo:(NSString*)userName;

-(UIImage*) circleImage:(UIImage*) image withParam:(CGFloat) inset;
- (AVUser *) searchForUsername:(NSString *)oneFriend;

- (UserInfo *) getUserInfoForUsername:(NSString *)oneFriend;


@end
