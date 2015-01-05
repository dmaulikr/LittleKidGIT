//
//  ViewControllerContact.h
//  LittleKid
//
//  Created by 李允恺 on 12/19/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactTableViewCell.h"

@interface ViewControllerContact : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic,retain)NSMutableArray*dataArray;
//数组里面保存每个获取Vcard（名片）
@property(nonatomic,retain)NSMutableArray*dataArrayDic;
//字典序保存联系人信息
@property(nonatomic,retain)NSMutableDictionary*index;


@end

/* contact class define */
@interface Contact : NSObject

@property(nonatomic, strong) NSString *firstName;
@property(nonatomic, strong) NSString *lastName;
@property(nonatomic, strong) NSString *phoneNumber;

@end



