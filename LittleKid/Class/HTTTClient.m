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
+ (void)sendData:(NSDictionary *)data withProtocol:(NET_PROTOCOL)protocol{
    NSData *jsonData = [[NSData alloc] init];
    if ( data != nil ) {
        NSError *err;
        jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&err];
        if (err) {
            NSLog(@"data err: %@",err);
        }
    }
    httpResponseHandler httpHandler;
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    NSString *selfUID = [RuntimeStatus instance].usrSelf.UID;
    NSString *urlStr;
    switch (protocol) {
        case RECENT_MSG_GET:
            httpHandler = handleRecentMsg;
            urlStr = [NSString stringWithFormat:@"%@/message/%@",HTTP_SERVER_ROOT_URL_STR, selfUID];
            [urlRequest setURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
            [urlRequest setHTTPMethod:@"GET"];
            
            break;
        case FRIEND_LIST_GET:
            httpHandler = handleFriendListGet;
            urlStr = [NSString stringWithFormat:@"%@/friend/%@",HTTP_SERVER_ROOT_URL_STR, selfUID];
            [urlRequest setURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
            [urlRequest setHTTPMethod:@"GET"];
            break;
        case SIGN_IN:
        {
            httpHandler = handleSignIn;
            urlStr = [NSString stringWithFormat:@"%@/user/%@", HTTP_SERVER_ROOT_URL_STR, [RuntimeStatus instance].signAccountUID];
            [urlRequest setURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
            [urlRequest setHTTPMethod:@"GET"];
            break;
        }
        case SIGN_UP:
        {
            httpHandler = handleSignUp;
            urlStr = [NSString stringWithFormat:@"%@/user", HTTP_SERVER_ROOT_URL_STR];
            [urlRequest setURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
            [urlRequest setHTTPMethod:@"POST"];
            [urlRequest setHTTPBody:jsonData];
            break;
        }
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
            [urlRequest setHTTPBody:jsonData];
            break;
        case RECENT_MSG_POST:
            httpHandler = handleSendMsg;
            urlStr = [NSString stringWithFormat:@"%@/message/%@",HTTP_SERVER_ROOT_URL_STR, selfUID];
            [urlRequest setURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
            [urlRequest setHTTPMethod:@"POST"];
            [urlRequest setHTTPBody:jsonData];
            break;
        case SELF_MSG_GET:
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
        NSError *err;
        NSArray *recentMsgList = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&err];
        if(err){
            NSLog(@"err recent msg list json : %@",err);
        }
        [[RuntimeStatus instance] loadServerRecentMsg:recentMsgList];
        [HTTTClient notify:NOTIFI_GET_RECENT_MSG withdataDict:[HTTTClient dictWithData:[NSData dataWithBytes:"hello world" length:11]]];
    }
};

httpResponseHandler handleFriendListGet = ^(NSURLResponse *response, NSData *data, NSError *connectionError){
    if (connectionError) {
        NSLog(@"http err: %@",connectionError.localizedDescription);
    }
    else{
        NSLog(@"handleFriendList connection success");
        NSError *err;
        NSArray *friendList = [[NSArray alloc] initWithArray:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&err]];
        if(err){
            NSLog(@"err friend list json : %@",err);
        }
        [[RuntimeStatus instance].usrSelf loadServerFriendList:friendList];
        [HTTTClient notify:NOTIFI_GET_FRIEND_LIST withdataDict:nil];
    }
};

httpResponseHandler handleSignIn = ^(NSURLResponse *response, NSData *data, NSError *connectionError){
    if (connectionError) {
        NSLog(@"http err: %@",connectionError.localizedDescription);
    }
    else{
        NSLog(@"handleSignIn connection success");
        NSLog(@"%@",response);
        NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSError *err;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
        if(err){
            NSLog(@"err json : %@",err);
        }
        NSLog(@"%@",dict);
        [HTTTClient notify:NOTIFI_SIGN_IN withdataDict:dict];
    }
    
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
            return;
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
        NSError *err;
        NSDictionary *friendDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
        if(err){
            NSLog(@"not json friend ack");
            return;
        }
        [[RuntimeStatus instance].usrSelf addFriend:friendDict];
        [HTTTClient notify:NOTIFI_ADD_FRIEND withdataDict:nil];
    }
};

httpResponseHandler handleSendMsg = ^(NSURLResponse *response, NSData *data, NSError *connectionError){
    if (connectionError) {
        NSLog(@"http err: %@",connectionError.localizedDescription);
    }
    else{
        NSLog(@"handleSendMsg connection success");
        
        
        
        
        [HTTTClient notify:NOTIFI_MSG_POST withdataDict:nil];
    }
};

httpResponseHandler handleSelfMsg = ^(NSURLResponse *response, NSData *data, NSError *connectionError){
    if (connectionError) {
        NSLog(@"http err: %@",connectionError.localizedDescription);
    }
    else{
        NSLog(@"handleSelfMsg connection success");
        NSError *err;
        NSDictionary *selfInfoDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
        if(err){
            NSLog(@"not self info ack");
            return;
        }

        [[RuntimeStatus instance].usrSelf loadServerSelfInfo:selfInfoDict];
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
        [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(remindServer) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] run];
    });
}

- (void)remindServer{
//    [HTTTClient sendData:nil withProtocol:HEART_BEAT];
}



@end
