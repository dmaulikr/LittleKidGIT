//
//  UDPP2P.h
//  LittleKid
//
//  Created by 李允恺 on 1/13/15.
//  Copyright (c) 2015 李允恺. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RuntimeStatus;
@class UserOther;

/* UDPP2P tag defination */
#define TAG_CHATMSG 5
#define TAG_CHESS   10

@interface UDPP2P : NSObject

- (id)init;
- (void)sendData:(NSData *)data toUser:(UserOther *)user;

@end
