//
//  ViewControllerRecent.m
//  LittleKid
//
//  Created by 李允恺 on 12/19/14.
//  Copyright (c) 2014 李允恺. All rights reserved.
//

#import "ViewControllerRecent.h"
#import "RecentTableViewCell.h"
#import "ViewControllerChat.h"

@interface ViewControllerRecent ()

@property (weak, nonatomic) IBOutlet UITableView *recentTableView;
@property (strong, nonatomic) UIImage *headImage;
@property( strong, nonatomic) UIImage *iconImage;
@property(strong, nonatomic) NSString *str;
@property NSInteger toChatUsrIndex;

@end

@implementation ViewControllerRecent

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(freshRecentContacts:) name:NOTIFI_GET_RECENT_MSG object:nil];
    self.headImage = [UIImage imageNamed:@"head.jpg"];
    self.iconImage = [UIImage imageNamed:@"5.png"];
    
    [self waitStatus];
    //get info from server
    [HTTTClient sendData:nil withProtocol:SELF_MSG_GET];
    [HTTTClient sendData:nil withProtocol:RECENT_MSG_GET];
    [HTTTClient sendData:nil withProtocol:GET_FRIEND_LIST];
}

- (void)setUI{
    self.recentTableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zuijin_background.png"]];
}

/* display a waiting indictor */
- (void)waitStatus{
    
}


- (void)viewWillDisappear:(BOOL)animated{
    NSLog(@"");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)freshRecentContacts:(NSNotification *)notification{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.recentTableView reloadData];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[RuntimeStatus instance].recentUsrList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RecentTableViewCell *cell;
    cell = (RecentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cellRecentMsg" forIndexPath:indexPath];
    //[[tableView tableHeaderView] setNeedsUpdateConstraints];
    if (cell == nil) {
        cell = [[RecentTableViewCell alloc] init];
    }
    UserOther *recent1Usr = [[RuntimeStatus instance].recentUsrList objectAtIndex:[indexPath row]];
    if (recent1Usr == nil) {
        return cell;
    }
    cell.nickName.text = recent1Usr.nickName;
    cell.headPicture.image = self.headImage;
    cell.msgIcon.image = self.iconImage;
    cell.share.text = @"empty";
    ChatMessage *lastMsg = [recent1Usr.msgs lastObject];
    if (lastMsg == nil) {
        return cell;
    }
    /* 根据不同类型消息显示不同 */
    cell.lastMsg.text = lastMsg.msg;
    

    
    
    return cell;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    return @"最近的";
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //hit the index of the row to get the recentMsg in runtimestatus
    self.toChatUsrIndex = [indexPath row];
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


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     ViewControllerChat *desVC = segue.destinationViewController;
     [desVC setHidesBottomBarWhenPushed:YES];
     desVC.toChatUsrIndex = self.toChatUsrIndex;
 }



@end
