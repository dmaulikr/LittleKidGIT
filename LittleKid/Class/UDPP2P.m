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

@interface ResendClass : NSObject

@property(strong, nonatomic) NSData *data;
@property(strong, nonatomic) UserOther *user;
@property(strong, nonatomic) NSDate *date;

- (id)initWithData:(NSData *)data user:(UserOther *)user date:(NSDate *)date;

@end



#define P2P_TIMEOUT 3
#define P2P_SENT_TIMESTAMP  @"P2P_SENT_TIMESTAMP"
#define P2P_SENT_DATA @"P2P_SENT_DATA"

@interface UDPP2P()

@property(strong, nonatomic)GCDAsyncUdpSocket *udpSocket;
@property(strong, nonatomic)NSMutableArray *resendInfoList;

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
        self.resendInfoList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)sendData:(NSData *)data toUser:(UserOther *)user{
    //对发送数据作包装
    NSDate *sendTime = [[NSDate alloc] init];
    NSDictionary *sentdict = [[NSDictionary alloc] initWithObjectsAndKeys:sendTime, P2P_SENT_TIMESTAMP, data, P2P_SENT_DATA, nil];
    NSError *err;
    NSData *sentjsonData = [NSJSONSerialization dataWithJSONObject:sentdict options:NSJSONWritingPrettyPrinted error:&err];
    if (err) {
        NSLog(@"jsondata error: %@",err);
    }
    NSString *hostIP = user.usrIP;
    uint16_t hostPort = [user.usrPort intValue];
    [self.udpSocket sendData:sentjsonData toHost:hostIP port:hostPort withTimeout:3 tag:12];
    //重传处理
    ResendClass *resendMsg = [[ResendClass alloc] initWithData:sentjsonData user:user date:sendTime];
    [self.resendInfoList addObject:resendMsg];
    [NSTimer scheduledTimerWithTimeInterval:P2P_TIMEOUT target:self selector:@selector(resend) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] run];
}

- (void)resend{
    //判断何组数据重传
    
    //重传
//    NSString *hostIP = self.tempUsrToResend.usrIP;
//    uint16_t hostPort = [self.tempUsrToResend.usrPort intValue];
//    [self.udpSocket sendData:self.tempDataToResend toHost:hostIP port:hostPort withTimeout:3 tag:12];
    [NSTimer scheduledTimerWithTimeInterval:P2P_TIMEOUT target:self selector:@selector(resend) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] run];

}


#pragma mark - UDPP2P

/**
 * Called when the datagram with the given tag has been sent.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    NSLog(@"did send data with tag");
}

/**
 * Called if an error occurs while trying to send a datagram.
 * This could be due to a timeout, or something more serious such as the data being too large to fit in a sigle packet.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    NSLog(@"didn't send data with tag. err: %@",error);
    //重传机制
}

/**
 * Called when the socket has received the requested datagram.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext{
    //1.判断ack及时间戳，以判断某条信息接收是否成功，如失败，则重传，如成功，则清楚该条消息的temp数组
    NSError *err;
    NSDictionary *rcvdDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
    if (err) {
        //返回失败的ack，让对方重传
        
        
//        return;
    }
    
    NSData *rcvdData = [rcvdDict objectForKey:P2P_SENT_DATA];
    [[RuntimeStatus instance] procNewChatMsg:rcvdData];
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

@implementation ResendClass

- (id)initWithData:(NSData *)data user:(UserOther *)user date:(NSDate *)date{
    self = [super init];
    if (self) {
        self.data = data;
        self.user = user;
        self.date = date;
    }
    return self;
}

@end


