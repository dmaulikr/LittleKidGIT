//
//  HTTTClient.m
//  LittleKid
//
//  Created by 李允恺 on 12/27/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import "HTTTClient.h"
#import "RuntimeStatus.h"

typedef void(^httpResponseHandler)(NSURLResponse *response, NSData *data, NSError *connectionError);

@interface HTTTClient ()

+ (void)remindServer;

@end


@implementation HTTTClient

- (id)init{
    self = [super init];
    if (self) {
    [self heartBeat];
    }
    return self;
}

/* http handler FSM */
+ (void)sendData:(NSData *)data withProtocol:(NET_PROTOCOL)protocol{
    //NSData *pkt = data;//每个类自己打包数据
    httpResponseHandler httpHandler;
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    NSString *selfUID = [RuntimeStatus instance].usrSelf.UID;
    NSString *urlStr;
    switch (protocol) {
        case GET_RECENT_MSG:
            httpHandler = handleRecentMsg;
            urlStr = [NSString stringWithFormat:@"%@/message/%@",HTTP_SERVER_ROOT_URL_STR, selfUID];
            [urlRequest setURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
            [urlRequest setHTTPMethod:@"GET"];
            break;
        case GET_FRIEND_LIST:
            httpHandler = handleFriendList;
            urlStr = [NSString stringWithFormat:@"%@/friend/%@",HTTP_SERVER_ROOT_URL_STR, selfUID];
            [urlRequest setURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
            [urlRequest setHTTPMethod:@"GET"];
            break;
        case SIGN_IN:
            httpHandler = handleSignIn;
            urlStr = [NSString stringWithFormat:@"%@",HTTP_SERVER_ROOT_URL_STR];
            [urlRequest setURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
            [urlRequest setHTTPMethod:@"GET"];
            //setbody
            break;
        case SIGN_UP:
            httpHandler = handleSignUp;
            urlStr = [NSString stringWithFormat:@"%@/user", HTTP_SERVER_ROOT_URL_STR];
            [urlRequest setURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
            [urlRequest setHTTPMethod:@"POST"];
            [urlRequest setHTTPBody:data];
            break;
        case GET_CHECK_CODE:
            httpHandler = handleCheckCode;
            urlStr = [NSString stringWithFormat:@"%@",HTTP_SERVER_ROOT_URL_STR];
            [urlRequest setURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
            [urlRequest setHTTPMethod:@"GET"];
            
            break;
        case RETRIEVE_PASSWORD:
            httpHandler = handleRetrievePwd;
            urlStr = [NSString stringWithFormat:@"%@",HTTP_SERVER_ROOT_URL_STR];
            [urlRequest setURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
            [urlRequest setHTTPMethod:@"POST"];
            
            break;
        case ADD_FRIEND:
            httpHandler = handleAddFriend;
            urlStr = [NSString stringWithFormat:@"%@/friend/%@", HTTP_SERVER_ROOT_URL_STR, selfUID];
            [urlRequest setURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
            [urlRequest setHTTPMethod:@"POST"];
            [urlRequest setHTTPBody:data];
            break;
        case SEND_MSG:
            httpHandler = handleSendMsg;
            urlStr = [NSString stringWithFormat:@"%@/message/%@",HTTP_SERVER_ROOT_URL_STR, selfUID];
            [urlRequest setURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
            [urlRequest setHTTPMethod:@"POST"];
            [urlRequest setHTTPBody:data];
            break;
        case GET_SELF_MSG:
            httpHandler = handleSelfMsg;
            urlStr = [NSString stringWithFormat:@"%@/user/%@",HTTP_SERVER_ROOT_URL_STR, selfUID];
            [urlRequest setURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
            [urlRequest setHTTPMethod:@"GET"];
            break;
        case HEART_BEAT:
            httpHandler = handleHeartBeat;
            urlStr = [NSString stringWithFormat:@"%@/heartbeat/%@",HTTP_SERVER_ROOT_URL_STR, selfUID];
            [urlRequest setURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
            [urlRequest setHTTPMethod:@"GET"];
            break;
        default:
            NSLog(@"no this protocol, pCode:%d",protocol);
            return;
            break;
    }
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[[NSOperationQueue alloc] init] completionHandler:httpHandler];
}

+ (void)notify:(NSString *)notifiStr withdataDict:(NSDictionary *)dataDict{
    [[NSNotificationCenter defaultCenter] postNotificationName:notifiStr object:nil userInfo:dataDict];
}

+ (NSDictionary *)dictWithData:(NSData *)data{
    if (data == nil) {
        return nil;
    }
    return [NSDictionary dictionaryWithObject:data forKey:@"key"];
}

#pragma mark - http callback define


httpResponseHandler handleRecentMsg = ^(NSURLResponse *response, NSData *data, NSError *connectionError){
    if (connectionError) {
        NSLog(@"http err: %@",connectionError.localizedDescription);
    }
    else{
        NSLog(@"handleRecentMsg connection success");
        [[RuntimeStatus instance] loadServerRecentMsg:data];
        [HTTTClient notify:NOTIFI_GET_RECENT_MSG withdataDict:[HTTTClient dictWithData:[NSData dataWithBytes:"hello world" length:11]]];
    }
};

httpResponseHandler handleFriendList = ^(NSURLResponse *response, NSData *data, NSError *connectionError){
    if (connectionError) {
        NSLog(@"http err: %@",connectionError.localizedDescription);
    }
    else{
        NSLog(@"handleFriendList connection success");
        [[RuntimeStatus instance].usrSelf loadServerFriendList:data];
        [HTTTClient notify:NOTIFI_GET_FRIEND_LIST withdataDict:nil];
    }
};

httpResponseHandler handleSignIn = ^(NSURLResponse *response, NSData *data, NSError *connectionError){
    if (connectionError) {
        NSLog(@"http err: %@",connectionError.localizedDescription);
    }
    else{
        NSLog(@"handleSignIn connection success");
        NSError *err;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&err];
        if(err){
            NSLog(@"err json : %@",err);
        }
        NSLog(@"%@",dict);
    }
    [HTTTClient notify:NOTIFI_SIGN_IN withdataDict:[HTTTClient dictWithData:[NSData dataWithBytes:"hello world" length:11]]];   
};

httpResponseHandler handleSignUp = ^(NSURLResponse *response, NSData *data, NSError *connectionError){
    if (connectionError) {
        NSLog(@"http err: %@",connectionError.localizedDescription);
    }
    else{
        NSLog(@"handleSignUp connection success");
        NSLog(@"%@",response);
        NSError *err;
        NSDictionary *signUpResData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
        if(err){
            NSLog(@"signup jsonData error: %@", err);
        }
        // keep in mind that data content havn't been decided
        [HTTTClient notify:NOTIFI_SIGN_UP withdataDict:signUpResData];
    }
};

httpResponseHandler handleRetrievePwd = ^(NSURLResponse *response, NSData *data, NSError *connectionError){
    if (connectionError) {
        NSLog(@"http err: %@",connectionError.localizedDescription);
    }
    else{
        NSLog(@"handleRetrievePwd connection success");
        
        
        
        
        [HTTTClient notify:NOTIFI_RETRIEVE_PASSWORD withdataDict:nil];
    }
};

httpResponseHandler handleCheckCode = ^(NSURLResponse *response, NSData *data, NSError *connectionError){
    if (connectionError) {
        NSLog(@"http err: %@",connectionError.localizedDescription);
    }
    else{
        NSLog(@"handleCheckCode connection success");
        
        
        
        [HTTTClient notify:NOTIFI_GET_CHECK_CODE withdataDict:nil];
    }
};

httpResponseHandler handleAddFriend = ^(NSURLResponse *response, NSData *data, NSError *connectionError){
    if (connectionError) {
        NSLog(@"http err: %@",connectionError.localizedDescription);
    }
    else{
        NSLog(@"handleAddFriend connection success");
        [[RuntimeStatus instance].usrSelf addFriend:data];
        [HTTTClient notify:NOTIFI_ADD_FRIEND withdataDict:nil];
    }
};

httpResponseHandler handleSendMsg = ^(NSURLResponse *response, NSData *data, NSError *connectionError){
    if (connectionError) {
        NSLog(@"http err: %@",connectionError.localizedDescription);
    }
    else{
        NSLog(@"handleSendMsg connection success");
        
        
        
        
        [HTTTClient notify:NOTIFI_SEND_MSG withdataDict:nil];
    }
};

httpResponseHandler handleSelfMsg = ^(NSURLResponse *response, NSData *data, NSError *connectionError){
    if (connectionError) {
        NSLog(@"http err: %@",connectionError.localizedDescription);
    }
    else{
        NSLog(@"handleSelfMsg connection success");
        [[RuntimeStatus instance].usrSelf loadServerSelfInfo:data];
        [HTTTClient notify:NOTIFI_GET_SELF_MSG withdataDict:nil];
    }
};

httpResponseHandler handleHeartBeat = ^(NSURLResponse *response, NSData *data, NSError *connectionError){
    if (connectionError) {
        NSLog(@"http err: %@",connectionError.localizedDescription);
        //失败重建措施
        //[HTTTClient remidServer];
    }
    else{
        NSLog(@"handleheatBeat connection success");
        NSLog(@"%@",response);
        //resolve response IP,Port,etc
        
    }
};

/* 内网穿透心跳包 */
- (void)heartBeat{//not in the main queue
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSTimer *heartBeatTimer = [NSTimer timerWithTimeInterval:20 target:self selector:@selector(remindServer) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] run];
    });
}

+ (void)remindServer{
    [HTTTClient sendData:nil withProtocol:HEART_BEAT];
}



@end
