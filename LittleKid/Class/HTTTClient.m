//
//  HTTTClient.m
//  LittleKid
//
//  Created by 李允恺 on 12/27/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import "HTTTClient.h"

typedef void(^httpResponseHandler)(NSURLResponse *response, NSData *data, NSError *connectionError);


@implementation HTTTClient

+ (void)sendData:(NSData *)data withProtocol:(NET_PROTOCOL)protocol{
    NSData *pkt = [PacketNetData packetWithData:data];
    httpResponseHandler httpHandler = [HTTTClient handlerWithProtocol:protocol];
    if (httpHandler == NULL) {
        NSLog(@"http handler err");
        return;
    }
    [NSURLConnection sendAsynchronousRequest:[HTTTClient requestWithPkt2Sent:pkt] queue:[[NSOperationQueue alloc]init] completionHandler:httpHandler];
}

/* http handler FSM */
+ (httpResponseHandler) handlerWithProtocol:(NET_PROTOCOL)protocol{
    switch (protocol) {
        case GET_RECENT_MSG:
            return handleRecentMsg;
            break;
        case GET_FRIEND_LIST:
            return handleFriendList;
            break;
        case SIGN_IN:
            return handleSignIn;
            break;
        case SIGN_UP:
            return handleSignUp;
            break;
        case GET_CHECK_CODE:
            return handleCheckCode;
            break;
        case RETRIEVE_PASSWORD:
            return handleRetrievePwd;
            break;
        case ADD_FRIEND:
            return handleAddFriend;
            break;
        case SEND_MSG:
            return handleSendMsg;
            break;
        case GET_SELF_MSG:
            return handleSelfMsg;
            break;
        default:
            return NULL;
            break;
    }
}

+ (NSMutableURLRequest *)requestWithPkt2Sent:(NSData *)Pkt{
    NSURL *serverUrl = [NSURL URLWithString:[SERVER_URL_STRING stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:serverUrl];
    [request setHTTPMethod:HTTP_METHOD];
    [request setHTTPBody:Pkt];
    [request setTimeoutInterval:TIME_OUT_MAX];
    return request;
}

+ (void)notify:(NSString *)notifiStr withdataDict:(NSDictionary *)dataDict{
    [[NSNotificationCenter defaultCenter] postNotificationName:notifiStr object:nil userInfo:dataDict];
}

+ (NSDictionary *)dictWithData:(NSData *)data{
    return [NSDictionary dictionaryWithObject:data forKey:@"key"];
}

#pragma mark - http callback define


httpResponseHandler handleRecentMsg = ^(NSURLResponse *response, NSData *data, NSError *connectionError){
    if (connectionError) {
        NSLog(@"http err: %@",connectionError.localizedDescription);
    }
    else{
        NSLog(@"handleRecentMsg connection success");
    }
    
    
    [HTTTClient notify:NOTIFI_GET_RECENT_MSG withdataDict:[HTTTClient dictWithData:[NSData dataWithBytes:"hello world" length:11]]];
    
};

httpResponseHandler handleFriendList = ^(NSURLResponse *response, NSData *data, NSError *connectionError){
    if (connectionError) {
        NSLog(@"http err: %@",connectionError.localizedDescription);
    }
    else{
        NSLog(@"handleFriendList connection success");
    }
    
    
    [HTTTClient notify:NOTIFI_GET_FRIEND_LIST withdataDict:nil];
    
};

httpResponseHandler handleSignIn = ^(NSURLResponse *response, NSData *data, NSError *connectionError){
    if (connectionError) {
        NSLog(@"http err: %@",connectionError.localizedDescription);
    }
    else{
        NSLog(@"handleSignIn connection success");
    }
    
    
    [HTTTClient notify:NOTIFI_SIGN_IN withdataDict:[HTTTClient dictWithData:[NSData dataWithBytes:"hello world" length:11]]];
    
};

httpResponseHandler handleSignUp = ^(NSURLResponse *response, NSData *data, NSError *connectionError){
    if (connectionError) {
        NSLog(@"http err: %@",connectionError.localizedDescription);
    }
    else{
        NSLog(@"handleSignUp connection success");
    }
    
    
    [HTTTClient notify:NOTIFI_SIGN_UP withdataDict:nil];
    
};

httpResponseHandler handleRetrievePwd = ^(NSURLResponse *response, NSData *data, NSError *connectionError){
    if (connectionError) {
        NSLog(@"http err: %@",connectionError.localizedDescription);
    }
    else{
        NSLog(@"handleRetrievePwd connection success");
    }
    
    [HTTTClient notify:NOTIFI_RETRIEVE_PASSWORD withdataDict:nil];
    
};

httpResponseHandler handleCheckCode = ^(NSURLResponse *response, NSData *data, NSError *connectionError){
    if (connectionError) {
        NSLog(@"http err: %@",connectionError.localizedDescription);
    }
    else{
        NSLog(@"handleCheckCode connection success");
    }
    
    
    [HTTTClient notify:NOTIFI_GET_CHECK_CODE withdataDict:nil];
    
};

httpResponseHandler handleAddFriend = ^(NSURLResponse *response, NSData *data, NSError *connectionError){
    if (connectionError) {
        NSLog(@"http err: %@",connectionError.localizedDescription);
    }
    else{
        NSLog(@"handleAddFriend connection success");
    }
    
    
    [HTTTClient notify:NOTIFI_ADD_FRIEND withdataDict:nil];
    
};

httpResponseHandler handleSendMsg = ^(NSURLResponse *response, NSData *data, NSError *connectionError){
    if (connectionError) {
        NSLog(@"http err: %@",connectionError.localizedDescription);
    }
    else{
        NSLog(@"handleSendMsg connection success");
    }
    
    
    
    [HTTTClient notify:NOTIFI_SEND_MSG withdataDict:nil];
};

httpResponseHandler handleSelfMsg = ^(NSURLResponse *response, NSData *data, NSError *connectionError){
    if (connectionError) {
        NSLog(@"http err: %@",connectionError.localizedDescription);
    }
    else{
        NSLog(@"handleSelfMsg connection success");
    }
    
    
    
    [HTTTClient notify:NOTIFI_GET_SELF_MSG withdataDict:nil];
};

@end
