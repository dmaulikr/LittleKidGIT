//
//  HTTTClient.h
//  LittleKid
//
//  Created by 李允恺 on 12/27/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "typedef.h"
@class RuntimeStatus;

#define HTTP_SERVER_ROOT_URL_STR   @"http://childrensns.sinaapp.com/User"
#define TIME_OUT_MAX 10

@interface HTTTClient : NSObject

+ (void)sendData:(NSData *)data withProtocol:(NET_PROTOCOL)protocol;

@end
