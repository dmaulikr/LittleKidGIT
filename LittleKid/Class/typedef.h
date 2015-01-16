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
    RECENT_MSG_GET = 0X01,/* 向服务器请求消息，不用在P2P中 */
    RECENT_MSG_POST,    /* P2P协议采用POST，ACK也是 */
    FRIEND_LIST_GET,
    FRIEND_LIST_POST,
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


#endif
