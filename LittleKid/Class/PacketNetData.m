//
//  PacketNetData.m
//  LittleKid
//
//  Created by 李允恺 on 12/27/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import "PacketNetData.h"

@implementation PacketNetData

+ (NSData *)packetWithData:(NSData *)data{
    if (data==nil) {
        return nil;
    }
    NSData *rtData;
    rtData = data;
    return rtData;
}

@end
