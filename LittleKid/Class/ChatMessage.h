//
//  ChatMessage.h
//  LittleKid
//
//  Created by 李允恺 on 12/25/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatMessage : NSObject <NSCoding>

@property(nonatomic, strong)NSString *owner;//0,self;1,other
@property(nonatomic, strong)NSString *type;//0,text;1,sound;2,image
@property(nonatomic, strong)NSString *timeStamp;
@property(nonatomic, strong)NSString *msg;

- (id)init;


@end
