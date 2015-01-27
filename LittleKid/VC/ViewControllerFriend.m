//
//  ViewControllerFriend.m
//  LittleKid
//
//  Created by 李允恺 on 1/9/15.
//  Copyright (c) 2015 李允恺. All rights reserved.
//

#import "ViewControllerFriend.h"
#import "FriendTableViewCell.h"
#import "RuntimeStatus.h"

@interface ViewControllerFriend ()

@property (weak, nonatomic) IBOutlet UITableView *friendTableView;


@end

@implementation ViewControllerFriend

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(freshTable) name:NOTIFI_GET_FRIEND_LIST object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUI{
    
}

- (void)freshTable{
    [self.friendTableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1+3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath.row == 0 ) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellToAddFriend" forIndexPath:indexPath];
        return cell;
    }
    else{// 一个BUG，加载friendCell老是挂掉，还没找到原因
        //you must minus 1 as cell number is 1 more than array count
        FriendTableViewCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellFriend" forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[FriendTableViewCell alloc] init];
        }
        cell.nickName.text = @"nickname";
        cell.state.text = @"state";
        cell.starNumber.text = @"5";
        cell.signature.text = @"signature";
        return  cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {//这个segue在mainstoryboard中完成了，此处直接退出即可
        return;
    }
    //根据indexPath加载响应好友信息
    
    
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
