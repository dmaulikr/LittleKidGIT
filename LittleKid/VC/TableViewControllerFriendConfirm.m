//
//  TableViewControllerFriendConfirm.m
//  LittleKid
//
//  Created by 李允恺 on 1/27/15.
//  Copyright (c) 2015 李允恺. All rights reserved.
//

#import "TableViewControllerFriendConfirm.h"
#import "CDSessionManager.h"
#import "RuntimeStatus.h"

@interface TableViewControllerFriendConfirm ()

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *uidLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;

@property (weak, nonatomic) IBOutlet UILabel *level;

@end

@implementation TableViewControllerFriendConfirm

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self loadFriendInfo];
    
    
}

- (void)loadFriendInfo{
    if ( self.toAddFriendInfoDict == nil ){
        return;
    }
    self.uidLabel.text = [self.toAddFriendInfoDict objectForKey:@"uid"];
    UserInfo *otheruserinfo = [[RuntimeStatus instance] getUserInfoForUsername:self.uidLabel.text];
    self.headImageView.image = [[RuntimeStatus instance] circleImage:otheruserinfo.headImage withParam:0];
    self.nicknameLabel.text = otheruserinfo.nickname;
    self.level.text = [[RuntimeStatus instance] getLevelString:otheruserinfo.score];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addFriendBtnTouchDown:(id)sender {
    self.btnAdd.enabled = false;
 //   for (UserInfo *usr in [RuntimeStatus instance].friends) {
//        if([usr.userName isEqualToString:self.uidLabel.text]){
//            [[[UIAlertView alloc] initWithTitle:@"已经加为好友" message:@"提示原因" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil , nil] show];
//            
//            return;
//        }
        if ([self.uidLabel.text isEqual:[AVUser currentUser].username]) {
            [[[UIAlertView alloc] initWithTitle:@"不能加自己为好友" message:@"提示原因" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil , nil] show];
            
            return;
        }
//    }

    
    [self sendAddFriendMsg:self.uidLabel.text];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_ADD_FRIEND_ACK_UPDATED object:nil userInfo:self.uidLabel.text];
    [[[UIAlertView alloc] initWithTitle:nil message:@"已经加对方为好友" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] show];
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(BOOL)sendAddFriendMsg:(NSString*) uid{
    
    [[CDSessionManager sharedInstance] sendAddFriendRequest:uid];

    return YES;
}


#pragma mark - Table view data source

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
