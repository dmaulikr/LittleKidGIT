//
//  ChatMessage.h
//  LittleKid
//
//  Created by 李允恺 on 12/25/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MSG_OWNER_SELF      @"0"
#define MSG_OWNER_OTHER     @"1"
#define MSG_TYPE_TXT        @"0"
#define MSG_TYPE_SOUND      @"1"
#define MSG_TYPE_IMG        @"2"

/* dict keys defination */
#define CHATMSG_KEY_SOUND_DATA  @"CHATMSG_KEY_SOUND_DATA"
#define CHATMSG_KEY_CHATMSG     @"CHATMSG_KEY_CHATMSG"
#define CHATMSG_KEY_UID         @"CHATMSG_KEY_UID"
#define CHATMSG_KEY_TIMESTAMP   @"CHATMSG_KEY_TIMESTAMP"


@interface ChatMessage : NSObject <NSCoding>

@property(nonatomic, strong)NSString *owner;//0,self;1,other
@property(nonatomic, strong)NSString *type;//0,text;1,sound;2,image
@property(nonatomic, strong)NSString *timeStamp;
@property(nonatomic, strong)NSString *msg;

- (id)init;


@end
