//
//  InvitePlayViewController.h
//  LittleKid
//
//  Created by XC on 15-1-29.
//  Copyright (c) 2015年 李允恺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InvitePlayViewController : UIViewController
@property(strong, nonatomic) NSString * otherId;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UIImageView *userPhoto;
- (instancetype)initWithUser:(NSString *)otherid;
@end
