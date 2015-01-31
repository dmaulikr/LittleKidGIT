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

@interface ViewControllerFriend ()

@property (weak, nonatomic) IBOutlet UITableView *friendTableView;
@property (strong, nonatomic) NSMutableArray *friendList;
@property (strong, nonatomic) NSMutableArray *friendAddMsg;


@end

@implementation ViewControllerFriend

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUI];
    [self testCode];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(freshTable) name:NOTIFI_GET_FRIEND_LIST object:nil];
    
}

- (void)testCode{
    self.friendList = [[NSMutableArray alloc] init];
    self.friendAddMsg = [[NSMutableArray alloc] init];
    NSString *UID1 = @"15527913002";
    NSString *UID2 = @"12423423132";
    NSString *UID3 = @"124e2312312";
    [self.friendList addObject:UID1];
    [self.friendList addObject:UID2];
    [self.friendList addObject:UID3];
    [self.friendAddMsg addObject:UID1];
    [self.friendAddMsg addObject:UID1];
    [self.friendAddMsg addObject:UID1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUI{
    self.friendTableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"friend_bg.png"]];
}

- (void)freshTable{
    [self.friendTableView reloadData];
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
        return [self.friendList count];
    }
    if (section == SECTION_FRIEND_APPLY_MSG) {
        return [self.friendAddMsg count];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == SECTION_ADD_FRIEND){
        return @"找朋友";
    }
    else if (section == SECTION_FRIEND_APPLY_MSG){
        return @"好友申请";
    }
    else{
        return @"我的小伙伴";
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath.section == SECTION_ADD_FRIEND ) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellToAddFriend" forIndexPath:indexPath];
        return cell;
    }
    else if (indexPath.section == SECTION_FRIEND_APPLY_MSG) {
        FriendApplyMsgTableViewCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellFriendApplyMsg" forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[FriendApplyMsgTableViewCell alloc] init];
        }
        cell.cellNumberLabel.text = [self.friendAddMsg objectAtIndex:indexPath.row];//用此index方式定位数据
        return cell;
    }
    else{//section_friend_list
        FriendTableViewCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellFriend" forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[FriendTableViewCell alloc] init];
        }
        cell.nickName.text = @"nickname";
        cell.state.text = @"state";
        cell.starNumber.text = @"5";
        cell.signature.text = [self.friendList objectAtIndex:indexPath.row];//用此index方式定位数据
        return  cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == SECTION_ADD_FRIEND) {//这个segue在mainstoryboard中完成了，此处直接退出即可
        return;
    }
    if (indexPath.section == SECTION_FRIEND_LIST) {
        //根据indexPath加载响应好友信息
        
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
