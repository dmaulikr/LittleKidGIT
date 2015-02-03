//
//  FriendApplyMsgTableViewCell.h
//  LittleKid
//
//  Created by 李允恺 on 1/31/15.
//  Copyright (c) 2015 李允恺. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FriendApplyMsgTableViewCellDelegate <NSObject>

- (void) accpectAddFriend;

@end
@interface FriendApplyMsgTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *accept;
@property (nonatomic, weak) id<FriendApplyMsgTableViewCellDelegate> delegate;
-(void)accpectAddFriend;
@property (weak, nonatomic) IBOutlet UIImageView *headPictureView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellNumberLabel;



@end
