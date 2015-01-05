//
//  PacketNetData.h
//  LittleKid
//
//  Created by 李允恺 on 12/27/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "typedef.h"

@interface PacketNetData : NSObject

+ (NSData *)packetWithData:(NSData *)data;
@end
