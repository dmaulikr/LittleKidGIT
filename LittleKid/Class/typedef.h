//
//  typedef.h
//  LittleKid
//
//  Created by 李允恺 on 12/27/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#ifndef LittleKid_typedef_h
#define LittleKid_typedef_h

/* net communication order define */
typedef enum NET_PROTOCOL{
    RECENT_MSG_GET = 0X01,
    RECENT_MSG_POST,
    GET_FRIEND_LIST,
    SIGN_IN,
    SIGN_UP,
    GET_CHECK_CODE,
    RETRIEVE_PASSWORD,
    ADD_FRIEND,
    SERVER_REQUEST,
    SELF_MSG_GET,
    SELF_MSG_POST,
    HEART_BEAT,
    P2P_ACK,
    CHESS,
}NET_PROTOCOL;

/* notification defination */

#define NOTIFI_GET_RECENT_MSG       @"NOTIFI_GET_RECENT_MSG"
#define NOTIFI_GET_FRIEND_LIST      @"NOTIFI_GET_FRIEND_LIST"
#define NOTIFI_SIGN_IN              @"NOTIFI_SIGN_IN"
#define NOTIFI_SIGN_UP              @"NOTIFI_SIGN_UP"
#define NOTIFI_GET_CHECK_CODE       @"NOTIFI_GET_CHECK_CODE"
#define NOTIFI_RETRIEVE_PASSWORD    @"NOTIFI_RETRIEVE_PASSWORD"
#define NOTIFI_ADD_FRIEND           @"NOTIFI_ADD_FRIEND"
#define NOTIFI_MSG_POST             @"NOTIFI_MSG_POST"
#define NOTIFI_SERVER_REQUEST       @"NOTIFI_SERVER_REQUEST"
#define NOTIFI_GET_SELF_MSG         @"NOTIFI_GET_SELF_MSG"
#define NOTIFI_GET_NEW_MSG          @"NOTIFI_GET_NEW_MSG"

/* dict keys defination */
#define CHATMSG_KEY_SOUND_DATA  @"CHATMSG_KEY_SOUND_DATA"
#define CHATMSG_KEY_CHATMSG     @"CHATMSG_KEY_CHATMSG"
#define CHATMSG_KEY_UID         @"CHATMSG_KEY_UID"


#endif
