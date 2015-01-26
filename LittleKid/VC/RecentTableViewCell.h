//
//  RecentTableViewCell.h
//  LittleKid
//
//  Created by 李允恺 on 12/26/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headPicture;
@property (weak, nonatomic) IBOutlet UILabel *nickName;
@property (weak, nonatomic) IBOutlet UILabel *lastMsg;
@end
