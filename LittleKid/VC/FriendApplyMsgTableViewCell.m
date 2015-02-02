//
//  FriendApplyMsgTableViewCell.m
//  LittleKid
//
//  Created by 李允恺 on 1/31/15.
//  Copyright (c) 2015 李允恺. All rights reserved.
//

#import "FriendApplyMsgTableViewCell.h"

@implementation FriendApplyMsgTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundView.alpha = 0.2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
