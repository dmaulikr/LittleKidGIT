//
//  UDPP2P.h
//  LittleKid
//
//  Created by 李允恺 on 1/13/15.
//  Copyright (c) 2015 李允恺. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "typedef.h"
@class RuntimeStatus;
@class UserOther;

/* UDPP2P tag defination */
#define P2P_TAG_CHATMSG 5
#define P2P_TAG_CHESS   10
#define P2P_TAG_ACK     15

@interface UDPP2P : NSObject

- (id)init;
- (void)sendDict:(NSDictionary *)data toUser:(UserOther *)user withProtocol:(NET_PROTOCOL)protocol;

@end
