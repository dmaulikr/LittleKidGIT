//
//  ViewControllerFriend.m
//  LittleKid
//
//  Created by 李允恺 on 1/9/15.
//  Copyright (c) 2015 李允恺. All rights reserved.
//

#import "ViewControllerFriend.h"
#import "FriendTableViewCell.h"
#import "FriendApplyMsgTableViewCell.h"
#import "RuntimeStatus.h"
#import "CDChatRoomController.h"
#import "CDBaseNavigationController.h"
#import "CDSessionManager.h"

@interface ViewControllerFriend ()

@property (weak, nonatomic) IBOutlet UITableView *friendTableView;


@end

@implementation ViewControllerFriend

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUI];
//    [[RuntimeStatus instance] initial];//加好友更新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(freshTable) name:NOTIFI_GET_FRIEND_LIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveAddFriendRequest:) name:NOTIFICATION_ADD_FRIEND_UPDATED object:nil]; //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveAddFriendRequestAck:) name:NOTIFICATION_ADD_FRIEND_ACK_UPDATED object:nil]; //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receveStatus:) name:NOTIFICATION_ReceiveStatus object:nil]; //注册通知
    
}

- (void) receveStatus:(NSNotification *)notification
{
    [self freshTable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUI{
    self.friendTableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zhuce_0030_图层-14_01.png"]];
}
- (void)receiveAddFriendRequest:(NSNotification *)notification {
    NSDictionary *dict = notification.userInfo;
    
    NSString *peerID = [dict objectForKey:@"fromid"];
    dict = [dict objectForKey:@"cmd"];
    NSString *str = [dict objectForKey:@"cmd_type"];
    if ([str isEqualToString:ADD_FRIEND_CMD] ) {
        [RuntimeStatus instance].peerId = peerID;
        [[RuntimeStatus instance] addFriendsToBeConfirm:peerID];
        [self freshTable];
    }
}

- (void)receiveAddFriendRequestAck:(NSNotification *)notification
{
    AVQuery * query = [AVUser query];
    [query whereKey:@"username" equalTo:notification.userInfo];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil) {
            AVUser  *peerUser = [objects firstObject];
            
            if (peerUser == nil) {
                //TODO
                return;
            }
            
            [[AVUser currentUser] follow:peerUser.objectId andCallback:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Add friend %@ successful", [RuntimeStatus instance].peerId);
                    //TODO: just need to add one user to friend list, no need to call initial
                    [[RuntimeStatus instance] initial];//加好友更新
                    [self freshTable];
                } else {
                    NSLog(@"Add friend %@ error %@", [RuntimeStatus instance].peerId, error);
                }
            }];
        } else {
            
        }
    }];
}
//{
//    NSDictionary *dict = notification.userInfo;
//    NSString *peerid = [dict objectForKey:@"fromid"];
//    dict = [dict objectForKey:@"cmd"];
//    NSString *str = [dict objectForKey:@"cmd_type"];
//    if ([str isEqualToString:ADD_FRIEND_CMD_ACK] ) {
//        str = [dict objectForKey:@"ack_value"];
//        if ([str isEqualToString:@"OK"])
//        {
//            AVQuery * query = [AVUser query];
//            [query whereKey:@"username" equalTo:peerid];
//            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//                if (error == nil) {
//                    AVUser  *peerUser = [objects firstObject];
//                    
//                    if (peerUser == nil) {
//                        //TODO
//                        return;
//                    }
//                    
//                    [[AVUser currentUser] follow:peerUser.objectId andCallback:^(BOOL succeeded, NSError *error) {
//                        if (succeeded) {
//                            NSLog(@"Add friend %@ successful", [RuntimeStatus instance].peerId);
//                            //TODO: just need to add one user to friend list, no need to call initial
//                            [[RuntimeStatus instance] initial];//加好友更新
//                            [self freshTable];
//                        } else {
//                            NSLog(@"Add friend %@ error %@", [RuntimeStatus instance].peerId, error);
//                        }
//                    }];
//                } else {
//                    
//                }
//            }];
//        }
//    }
//    
//}


- (void)freshTable{
    [self.friendTableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}
- (void) accpectAddFriend
{
    AVQuery * query = [AVUser query];
    [query whereKey:@"username" equalTo:[RuntimeStatus instance].peerId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil) {
            AVUser  *peerUser = [objects firstObject];
            
            if (peerUser == nil) {
                //TODO
                [[RuntimeStatus instance] removeFriendsToBeConfirm:[RuntimeStatus instance].peerId];
                [self freshTable];
                return;
            }
            
            [[AVUser currentUser] follow:peerUser.objectId andCallback:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    //TODO
                    NSLog(@"Add friend %@ successful", [RuntimeStatus instance].peerId);
                    [[RuntimeStatus instance] removeFriendsToBeConfirm:[RuntimeStatus instance].peerId];
                    //TODO: just need to add one friend, no need to call initial
                    [[RuntimeStatus instance] initial];//加好友更新
                    [self freshTable];
                } else {
                    [[RuntimeStatus instance] removeFriendsToBeConfirm:[RuntimeStatus instance].peerId];
                    [self freshTable];
                    NSLog(@"Add friend %@ error %@", [RuntimeStatus instance].peerId, error);
                }
            }];
        } else {
            [[RuntimeStatus instance] removeFriendsToBeConfirm:[RuntimeStatus instance].peerId];
            [self freshTable];
            
        }
        
    }];
    
//    [[CDSessionManager sharedInstance] sendAddFriendRequestAck:@"OK" toPeerId:[RuntimeStatus instance].peerId];
    
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

#define  SECTION_ADD_FRIEND 0
#define  SECTION_FRIEND_LIST 2
#define  SECTION_FRIEND_APPLY_MSG 1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == SECTION_ADD_FRIEND) {
        return 1;
    }
    if (section == SECTION_FRIEND_LIST) {
        NSInteger i = [[RuntimeStatus instance].friends count];
        return  i;
    }
    if (section == SECTION_FRIEND_APPLY_MSG) {
        NSInteger i = [[RuntimeStatus instance].friendsToBeConfirm count];
        return i;
    }
    return 0;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger indexsection = indexPath.section;
    if ( indexsection == SECTION_ADD_FRIEND ) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellToAddFriend" forIndexPath:indexPath];
        UIImageView *imageview = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"好友_02"]];
        cell.backgroundView = imageview;
        cell.backgroundView.alpha = 1;
        return cell;
    }
    else if (indexsection == SECTION_FRIEND_APPLY_MSG) {
        FriendApplyMsgTableViewCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellFriendApplyMsg" forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[FriendApplyMsgTableViewCell alloc] init];
        }
        cell.cellNumberLabel.text = [[RuntimeStatus instance].friendsToBeConfirm objectAtIndex:indexPath.row];//用此index方式定位数据
        UIImageView *imageview = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"liaotiankuang"]];
        cell.backgroundView = imageview;
        UserInfo * userinfo = [[RuntimeStatus instance].friendsToBeConfirm objectAtIndex:indexPath.row];
        cell.nicknameLabel.text = userinfo.nickname;
        cell.headPictureView.image = [[RuntimeStatus instance] circleImage:userinfo.headImage withParam:0];
        cell.backgroundView.alpha = 0.8;
        cell.delegate = self;
        return cell;
    }
    else{//section_friend_list
        FriendTableViewCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellFriend" forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[FriendTableViewCell alloc] init];
        }
//        AVUser *user = [[RuntimeStatus instance].friends objectAtIndex:indexPath.row];
        UserInfo *userInfo = [[RuntimeStatus instance].friends objectAtIndex:indexPath.row];
        
        
        cell.nickName.text = userInfo.nickname;
        cell.state.text = @"state";
        cell.starNumber.text = @"5";
        if ([[CDSessionManager sharedInstance] peerIdIsOnline:userInfo.userName] == YES)
        {
            cell.online.text = @"在线";
        }
        else
        {
            cell.online.text = @"不在线";
        }
        cell.signature.text = [[RuntimeStatus instance] getLevelString:userInfo.score];
        UIImage *headImage;
        headImage = userInfo.headImage;
        cell.headPicture.image = [[RuntimeStatus instance] circleImage:headImage withParam:0];
       
        headImage = [UIImage imageNamed:@"liaotiankuang"];
        UIImageView *imageview = [[UIImageView alloc]initWithImage:headImage];
        cell.backgroundView = imageview;
        cell.backgroundView.alpha = 0.9;
        return  cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == SECTION_ADD_FRIEND) {//这个segue在mainstoryboard中完成了，此处直接退出即可
        return;
    }
    if (indexPath.section == SECTION_FRIEND_LIST) {
        //根据indexPath加载响应好友信息
       UserInfo *user = [[RuntimeStatus instance].friends objectAtIndex:indexPath.row];
//        CDBaseNavigationController *nav = self.tabBarController.childViewControllers.firstObject ;
        CDChatRoomController *controller = [[CDChatRoomController alloc] init];
        [[CDSessionManager sharedInstance] addChatWithPeerId:user.userName];
        controller.otherId = user.userName;
        controller.type = CDChatRoomTypeSingle;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ADD_CHATROOM object:nil userInfo:nil];
 //       self.tabBarController.selectedIndex = 0;
///        [nav popToRootViewControllerAnimated:NO];
        
 //       [self.tabBarController.childViewControllers.firstObject pushViewController:controller animated:YES];
 //       [self.navigationController popToRootViewControllerAnimated:NO];
        [self.navigationController pushViewController:controller animated:NO];
        
    }
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
