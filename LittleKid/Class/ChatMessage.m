//
//  ChatMessage.m
//  LittleKid
//
//  Created by 李允恺 on 12/25/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import "ChatMessage.h"

#define MSG_OWNER   @"owner"
#define MSG_TYPE    @"type"
#define MSG_TIME    @"timeStamp"
#define MSG_MSG     @"msg"

@implementation ChatMessage

- (id)init{
    self = [super init];
    if (self) {
        //
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.owner forKey:MSG_OWNER];
    [aCoder encodeObject:self.type forKey:MSG_TYPE];
    [aCoder encodeObject:self.timeStamp forKey:MSG_TIME];
    [aCoder encodeObject:self.msg forKey:MSG_MSG];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.owner = [aDecoder decodeObjectForKey:MSG_OWNER];
        self.type = [aDecoder decodeObjectForKey:MSG_TYPE];
        self.timeStamp = [aDecoder decodeObjectForKey:MSG_TIME];
        self.msg = [aDecoder decodeObjectForKey:MSG_MSG];
    }
    return self;
}


@end
