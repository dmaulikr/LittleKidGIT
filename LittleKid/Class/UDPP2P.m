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
@property(strong, nonatomic) NSString *date;

- (id)initWithData:(NSData *)data user:(UserOther *)user dateStr:(NSString *)dateStr;

@end



#define P2P_TIMEOUT             5
#define P2P_SENT_TIMESTAMP      @"P2P_SENT_TIMESTAMP"
#define P2P_SENT_DATA           @"P2P_SENT_DATA"
#define P2P_SENT_PROTOCOL       @"P2P_SENT_PROTOCOL"
#define P2P_SENT_MSG_POOL_SIZE  5

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
        if (![self.udpSocket bindToPort:P2P_PORT error:&err] ) {
            NSLog(@"bind error, %@",err);
        }
        err = nil;
        [self.udpSocket beginReceiving:&err];
        self.resendInfoList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)sendDict:(NSDictionary *)data toUser:(UserOther *)user withProtocol:(NET_PROTOCOL)protocol{
    if ( data == nil ) {
        return;
    }
    NSDate *sendTime = [NSDate date];
    NSDateFormatter *fmDate = [[NSDateFormatter alloc] init];
    [fmDate setDateFormat:@"YYYY-MM-DD-HH-MM-SS"];
    NSString *sendTimeStr = [fmDate stringFromDate:sendTime];
    NSDictionary *sentdict = [[NSDictionary alloc]
                              initWithObjectsAndKeys:sendTimeStr, P2P_SENT_TIMESTAMP,
                                                     data, P2P_SENT_DATA,
                                                     [NSNumber numberWithInt:protocol], P2P_SENT_PROTOCOL,
                                                     nil];
    NSString *hostIP = user.usrIP;
    uint16_t hostPort = [user.usrPort intValue];
    NSData *sentData = [NSKeyedArchiver archivedDataWithRootObject:sentdict];
    [self.udpSocket sendData:sentData toHost:hostIP port:hostPort withTimeout:3 tag:12];
    //重传处理
    ResendClass *resendMsg = [[ResendClass alloc] initWithData:sentData user:user dateStr:sendTimeStr];
    [self.resendInfoList addObject:resendMsg];
    if ( [self.resendInfoList count] >= P2P_SENT_MSG_POOL_SIZE ) {//最多同时保存5个数据，超过则丢掉最早的包
        [self.resendInfoList removeObjectAtIndex:0];
    }
    [NSTimer scheduledTimerWithTimeInterval:P2P_TIMEOUT target:self selector:@selector(resend) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] run];
}

- (void)resend{
    //重传最早的一个数据
    if ( [self.resendInfoList count] == 0 || self.resendInfoList == nil) {
        return;
    }
    ResendClass *firstMsg = [self.resendInfoList firstObject];
    NSString *hostIP = firstMsg.user.usrIP;
    uint16_t hostPort = [firstMsg.user.usrPort intValue];
    [self.udpSocket sendData:firstMsg.data toHost:hostIP port:hostPort withTimeout:P2P_TIMEOUT tag:P2P_TAG_CHATMSG];
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
 * 目前如果发的包如果解析不了或者丢了，都是靠超时处理的
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext{
    NSDictionary *rcvdDict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if ( rcvdDict == nil ) {//协议包不合格式
        return;//丢掉
    }
    //1.判断是否是ack
    //2.如果不是，判断协议，处理数据，返回ack
    //2.如果是，做重传的临时信息删除处理
    NET_PROTOCOL protocol = ((NSNumber *)([rcvdDict objectForKey:P2P_SENT_PROTOCOL])).integerValue;
    if ( protocol == P2P_ACK ) {//如果是一个ack包，删除重传数据
        NSString *timestamp = [rcvdDict objectForKey:P2P_SENT_TIMESTAMP];
        for ( ResendClass* temp1Msg in self.resendInfoList ) {
            if ( NSOrderedSame == [temp1Msg.date compare:timestamp] ) {
                [self.resendInfoList removeObject:temp1Msg];
            }
        }
        return;
    }
    else{//接收到消息包
        NSDictionary *rcvdDataDict = [rcvdDict objectForKey:P2P_SENT_DATA];//消息包主体必然为Dict类型
        switch (protocol) {
            case RECENT_MSG_POST:
//                [[RuntimeStatus instance] procNewP2PChatMsg:rcvdDataDict];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFI_GET_RECENT_MSG object:nil userInfo:nil];
                
                break;
            case CHESS:
                
                break;
            default:
                break;
        }
        //返回ack,包含ack协议，timestamp，用底层函数做
        NSString *rcvdTimestamp = [rcvdDict objectForKey:P2P_SENT_TIMESTAMP];
        NSDictionary *ackDict = [[NSDictionary alloc] initWithObjectsAndKeys:rcvdTimestamp, P2P_SENT_TIMESTAMP,
                                                                             [NSNumber numberWithInteger:P2P_ACK], P2P_SENT_PROTOCOL,
                                                                             nil];
        NSData *ackData = [NSKeyedArchiver archivedDataWithRootObject:ackDict];
        if ( ackData == nil ) {
            NSLog(@"packet ack err");
            return;
        }
        static int i =0;
        i++;
        if (i==5) {
            [self.udpSocket sendData:ackData toAddress:address withTimeout:P2P_TIMEOUT tag:P2P_TAG_ACK];
            i = 0;
        }
    }
}
/**
 * Called when the socket is closed.
 **/
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    NSLog(@"socket did close");
    //some processing
    NSError *err;
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    if (![self.udpSocket bindToPort:P2P_PORT error:&err] ) {
        NSLog(@"bind error, %@",err);
    }
    err = nil;
    [self.udpSocket beginReceiving:&err];
}

@end



@implementation ResendClass

- (id)initWithData:(NSData *)data user:(UserOther *)user dateStr:(NSString *)dateStr{
    self = [super init];
    if (self) {
        self.data = data;
        self.user = user;
        self.date = dateStr;
    }
    return self;
}

@end


