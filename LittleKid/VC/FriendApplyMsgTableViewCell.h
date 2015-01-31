//
//  FriendApplyMsgTableViewCell.h
//  LittleKid
//
//  Created by 李允恺 on 1/31/15.
//  Copyright (c) 2015 李允恺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendApplyMsgTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UISegmentedControl *acceptApplySegCtrl;
@property (weak, nonatomic) IBOutlet UIImageView *headPictureView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellNumberLabel;



@end
