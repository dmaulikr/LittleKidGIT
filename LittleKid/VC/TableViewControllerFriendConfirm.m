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
    self.headImageView.image = [UIImage imageNamed:@"head.jpg"];
    self.nicknameLabel.text = [self.toAddFriendInfoDict objectForKey:@"nickname"];
    self.uidLabel.text = [self.toAddFriendInfoDict objectForKey:@"uid"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addFriendBtnTouchDown:(id)sender {
    for (AVUser *usr in [RuntimeStatus instance].friends) {
        if([usr.username isEqualToString:self.uidLabel.text]){
            [[[UIAlertView alloc] initWithTitle:@"已经加为好友" message:@"提示原因" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil , nil] show];
            
            return;
        }
    }


    [self sendAddFriendMsg:self.uidLabel.text];

    [[[UIAlertView alloc] initWithTitle:nil message:@"好友请求已发送\n请耐心等待" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] show];
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
