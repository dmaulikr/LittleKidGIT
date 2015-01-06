//
//  HTTTClient.h
//  LittleKid
//
//  Created by 李允恺 on 12/27/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "typedef.h"
#import "PacketNetData.h"

#define SERVER_URL_STRING   @"http:\\www.baidu.com"
#define HTTP_METHOD @"GET"
#define TIME_OUT_MAX 10

@interface HTTTClient : NSObject

+ (void)sendData:(NSData *)data withProtocol:(NET_PROTOCOL)protocol;

@end
