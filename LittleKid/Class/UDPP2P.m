//
//  UDPP2P.m
//  LittleKid
//
//  Created by 李允恺 on 1/13/15.
//  Copyright (c) 2015 李允恺. All rights reserved.
//

#import "UDPP2P.h"
#import "RuntimeStatus.h"
#import "GCDAsyncUdpSocket.h"

@interface UDPP2P()

@property(strong, nonatomic)GCDAsyncUdpSocket *udpSocket;

@end

@implementation UDPP2P

- (id)init{
    self = [super init];
    if (self) {
        NSError *err;
        self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
        if (![self.udpSocket bindToPort:20107 error:&err] ) {
            NSLog(@"bind error, %@",err);
        }
        err = nil;
        [self.udpSocket beginReceiving:&err];
    }
    return self;
}

- (void)sendData:(NSData *)data toUser:(UserOther *)user{
    NSString *hostIP = user.usrIP;
    uint16_t hostPort = [user.usrPort intValue];
    [self.udpSocket sendData:data toHost:hostIP port:hostPort withTimeout:3 tag:12];
}


#pragma mark - UDPP2P

/**
 * Called when the datagram with the given tag has been sent.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    NSLog(@"send data success");
}

/**
 * Called if an error occurs while trying to send a datagram.
 * This could be due to a timeout, or something more serious such as the data being too large to fit in a sigle packet.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    NSLog(@"send data err: %@",error);
    //重传机制
}

/**
 * Called when the socket has received the requested datagram.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext{
    
    [[RuntimeStatus instance] procNewChatMsg:data];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFI_GET_RECENT_MSG object:nil userInfo:nil];
}

/**
 * Called when the socket is closed.
 **/
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    NSLog(@"socket did close");
    //some processing
    
}

@end
